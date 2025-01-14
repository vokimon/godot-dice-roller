# generates android metadata from README.md, CHANGES.md and screenshots

from pathlib import Path

def process_chapter(chapter):
    heading, body = chapter.split('\n', 1)
    heading = heading.strip()
    version = heading.split()[0]
    return version, body.strip()

def cp(origin, target):
    target.write_bytes(origin.read_bytes())

def dump(file, content):
    print(f":: \033[34;1m{file}\033[0m\n{content}")
    file.write_text(content)

metadata_path = Path("metadata/en-US")
metadata_path.mkdir(exist_ok=True, parents=True)

readme = Path("README.md").read_text()
readme = readme.split('#',1)[1]
readme_lines = readme.splitlines()
title = readme_lines.pop(0).replace('#', '').strip().replace('-',' ').title()
readme_lines = [ line for line in readme_lines if not line.strip().startswith("![") ]
while not readme_lines[0].strip():
    readme_lines.pop(0)
short_description = readme_lines.pop(0)

full_description = '\n'.join(readme_lines).strip()
dump(metadata_path/"title.txt", title)
dump(metadata_path/"short_description.txt", short_description)
dump(metadata_path/"full_description.txt", full_description)

changelog=Path("CHANGES.md").read_text()

changelog_path = metadata_path/"changelogs"
changelog_path.mkdir(exist_ok=True, parents=True)

changelog_chapters = changelog.split("##")[1:]
for chapter in changelog_chapters:
    version, body = process_chapter(chapter)
    version_code = ''.join(
        f"{int(v):02d}"
        for v in version.split('.')
    )
    dump((changelog_path/version_code).with_suffix('.txt'), body)

images_path = metadata_path/'images'
images_path.mkdir(exist_ok=True, parents=True)
for screenshot in Path().glob("screenshots/*png"):
    target = images_path/screenshot.name
    cp(screenshot, target)

