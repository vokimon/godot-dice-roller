import requests
from pathlib import Path
import subprocess
import configparser
import re
import os
from dotenv import load_dotenv
import yaml
from dataclasses import dataclass, field

def main():

	# Load secrets from environment or .env file
	load_dotenv('.env')
	username = os.environ.get('ASSET_STORE_USER')
	password = os.environ.get('ASSET_STORE_PASSWORD')

	config_yaml = yaml.safe_load(Path('tools/assetlib.yaml').read_text())
	config = Config(**config_yaml)

	api = Api()
	api.login(username, password)

	result = api.get('asset/edit', params=dict(
		asset=3530,
		status='new',
		version_string=config.project_version,
	))

	edit_ids = [
		p['edit_id']
		for p in result.get('result')
		if p['version_string'] == config.project_version
	]
	if edit_ids:
		config.edit_id = max(edit_ids)
		print(f"Detected pending edit {config.edit_id} for version {config.project_version}. Modifiying it.")

	resource = (
		f'asset/edit/{config.edit_id}'
		if config.edit_id else
		f'asset/{config.asset_id}'
	)

	old_data = api.get(resource)
	old_previews = old_data.get('previews', [])
	previews = previews_edit(config.previews, old_previews, config)

	data = {
		"title": config.project_name,
		"description": config.description,
		"category_id": config.category,
		"godot_version": config.godot_version,
		"version_string": config.project_version,
		"cost": config.project_license,
		"download_provider": config.repo_hosting,
		"download_commit": config.git_hash,
		"download_hash": "", # deprecated
		"browse_url": f"{config.repo_url}",
		"issues_url": f"{config.repo_url}/issues",
		"icon_url": f"{config.repo_raw}/icon.svg",
		"previews": previews,
	}

	print("SENT DATA:\n", yaml.dump(data))

	# TODO: previews not working yet
	#data['previews'] = []

	result = api.post(resource, data=data)
	print("RESULT:", result)

class Api:
	def __init__(self, base=None):
		self.base = base or f"https://godotengine.org/asset-library/api/"

	def login(self, username, password):
		r = self.post('/login', data=dict(
			username=username,
			password=password,
		))
		self.token = r['token']

	def _process_response(self, response):
		#print(response.text)
		response.raise_for_status()
		try:
			return response.json()
		except:
			print(response.text)
			raise

	def post(self, url, data={}, *args, **kwds):
		if hasattr(self, 'token'):
			data = dict(data, token=self.token)

		response = requests.post(
			self.base+url,
			data=data,
			*args, **kwds)
		return self._process_response(response)

	def get(self, url, *args, **kwds):
		response = requests.get(
			self.base+url,
			*args, **kwds)
		return self._process_response(response)

@dataclass
class Config:
	asset_id: str
	repo: str
	category: int # = "1" # 2D Tools
	project_license: str
	branch: str = 'main'
	repo_hosting: str = 'GitHub'
	previews: list[dict] = field(default_factory=list)
	description_files: list[str] = field(default_factory=list)

	project_name = from_project('project_name')
	project_version = from_project('project_version')
	config_description = from_project('description')
	godot_version = from_project('godot_version')
	icon = from_project('icon')
	git_hash = get_git_revision_hash()

	@property
	def repo_url(self):
		return f'https://github.com/{self.repo}'

	@property
	def repo_raw(self):
		return f'https://raw.githubusercontent.com/{self.repo}/refs/heads/{self.branch}'

	@property
	def description(self):
		description = '\n'.join((
			Path(f).read_text() for f in self.description_files
		))
		description = remove_md_image_lines(description) # markdown is not redered and they look awful
		description = remove_emojis(description)
		if not description:
			description = self.config_description
		return description

def get_git_revision_hash() -> str:
    return subprocess.check_output(['git', 'rev-parse', 'HEAD']).decode('ascii').strip()

def remove_emojis(description: str):
	for emoji in "✨🐛🏗🧹🔧📝♻️💄":
		description = description.replace(emoji, '')
	return description

def remove_md_image_lines(description: str) -> str:
	return '\n'.join((
		line for line in description.splitlines()
		if not line.startswith("![")
	))

def from_project(field):
	# TODO: This is somewhat fragile
	patterns = dict(
		project_name = r'config/name="([^"]+)"',
		project_version = r'config/version="([^"]+)"',
		description = r'config/description="([^"]+)"',
		godot_version = r'config/features=PackedStringArray[(]"([^"]+)"',
		icon = r'config/icon="res:/([^"]+)"',
	)
	pattern = patterns[field]
	project_content = Path('project.godot').read_text()
	return re.search(pattern, project_content).group(1)

def enhance_preview(preview, context):
	"""
	Enables certain shortcuts for specifying previews.

	>>> class context:
	...     repo_raw = "https://reporaw.com/path"
	...
	>>> enhance_preview({'youtube': 'AD8awHLpFxs'}, context)
	{'type': 'video', 'link': 'https://www.youtube.com/watch?v=AD8awHLpFxs', 'thumbnail': 'https://img.youtube.com/vi/AD8awHLpFxs/maxresdefault.jpg'}
	>>> enhance_preview({'repoimage': 'images/myimage.png'}, context)
	{'type': 'image', 'link': 'https://reporaw.com/path/images/myimage.png'}
	>>> enhance_preview({'repothumb': 'thumbs/myimage.jpg'}, context)
	{'thumbnail': 'https://reporaw.com/path/thumbs/myimage.jpg'}
	"""
	if 'youtube' in preview:
		youtube_id = preview.pop('youtube')
		preview.update(
            type = "video",
            link = f"https://www.youtube.com/watch?v={youtube_id}",
            thumbnail = f"https://img.youtube.com/vi/{youtube_id}/maxresdefault.jpg",
		)
	if 'repoimage' in preview:
		repoimage = preview.pop('repoimage')
		preview.update(
			type = 'image',
			link = f'{context.repo_raw}/{repoimage}',
		)
	if 'repothumb' in preview:
		repothumb = preview.pop('repothumb')
		preview.update(
			thumbnail = f'{context.repo_raw}/{repothumb}',
		)
	return preview

def previews_edit(previews, old_previews, config):
	previews = [
		preview_action(enhance_preview(short, config), old_previews)
		for short in previews
	] 
	previews += to_remove_previews(previews, old_previews)
	return previews

def preview_action(preview, old_previews):
	"""
	Turns a preview in metadata into an action to perform
	(insert, update) with existing previews in the library
	based on matching link field.
	"""
	if 'operation' in preview:
		return preview # alredy an op

	for old in old_previews:
		if old['link'] != preview['link']:
			continue
		return dict(
			preview,
			preview_id=old['preview_id'],
			operation='update',
			enabled=True,
		)

	return dict(
		preview,
		operation='insert',
		preview_id=None,
		enabled=True,
	)

def to_remove_previews(previews, old_previews):
	"""
	Generates delete edition action to those existing
	previews not defined in the new metadata.
	"""
	return [
		dict(
			edit_preview_id=old['preview_id'],
			operation='delete',
			enabled=True,
		)
		for old in old_previews
		if all(
			old['link']!=preview['link']
			for preview in previews
		)
	]


if __name__ == '__main__':
	main()

