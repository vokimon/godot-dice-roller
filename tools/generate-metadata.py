#!/usr/bin/env python

# generates metadata for packaging and distributing in different
# platforms from README.md, CHANGES.md and screenshots

from pathlib import Path
import os
import contextlib
from lxml import etree
import re
from godot_asset_library_client.config import Config as BaseConfig
from dataclasses import dataclass, field

@dataclass
class Config(BaseConfig):
    unique_name: str = 'net.canvoki.godot_dice_roller'
    repo_user: str = 'vokimon'
    repo_name: str = 'godot-dice-roller'
    categories: list[str] = field(default_factory=list)
    keywords: list[str] = field(default_factory=list)
    license : str = "AGPL-3.0-or-later"


yaml_metadata = 'tools/assetlib.yaml'
config = Config.from_file(yaml_metadata)

print(config)



emoji_pattern = re.compile(
    "["
    "\U0001F600-\U0001F64F"
    "\U0001F300-\U0001F5FF"
    "\U0001F680-\U0001F6FF"
    "\U0001F700-\U0001F77F"
    "\U0001F780-\U0001F7FF"
    "\U0001F800-\U0001F8FF"
    "\U0001F900-\U0001F9FF"
    "\U0001FA00-\U0001FA6F"
    "\U0001FA70-\U0001FAFF"
    "\u2600-\u26FF"
    "\u2700-\u27BF"
    "]+", flags=re.UNICODE)

def remove_emojis(text):
    return emoji_pattern.sub(r'', text)

def program_exists(program):
    import shutil
    return shutil.which(program) is not None

def mkdir(path):
    path.mkdir(exist_ok=True, parents=True)

def version_to_code(version, epoch=0) -> str:
    return ''.join(
        f"{int(v):02d}"
        for v in version.split('.')
    )

def last_version(metadata_path):
    last_code = list(sorted((metadata_path/'changelogs').glob('*txt')))[-1].stem
    digits = 2
    return '.'.join(
        str(int(last_code[i:i+digits]))
        for i in range(0,len(last_code),digits)
    )

def cp(origin, target):
    origin=Path(origin)
    target=Path(target)
    print(f":: \033[34;1m{origin} -> {target}\033[0m")
    mkdir(target.parent)
    target.write_bytes(origin.read_bytes())

def dump(file, content):
    print(f":: \033[34;1m{file}\033[0m\n{content}")
    file.write_text(content)

def generateDescriptions(metadata_path):
    readme = Path("README.md").read_text()
    readme = readme.split('#',1)[1]
    readme_lines = readme.splitlines()
    config.title = readme_lines.pop(0).replace('#', '').strip().replace('-',' ').title()
    readme_lines = [ line for line in readme_lines if not line.strip().startswith("![") ]
    while not readme_lines[0].strip():
        readme_lines.pop(0)
    config.short_description = readme_lines.pop(0)
    config.full_description = cutoff_on_mark('\n'.join(readme_lines).strip())

    dump(metadata_path/"title.txt", config.title)
    dump(metadata_path/"short_description.txt", config.short_description)
    dump(metadata_path/"full_description.txt", config.full_description)

def generateChangelogs(metadata_path: Path):
    def process_chapter(chapter):
        heading, body = chapter.split('\n', 1)
        heading = heading.strip()
        version = heading.split()[0]
        return version, body.strip()

    changelog=Path("CHANGES.md").read_text()

    changelog_path = metadata_path/"changelogs"
    mkdir(changelog_path)

    changelog_chapters = changelog.split("##")[1:]
    for chapter in changelog_chapters:
        version, body = process_chapter(chapter)
        if not version[0].isnumeric():
            # Unreleased
            continue
        version_code = version_to_code(version)
        dump((changelog_path/version_code).with_suffix('.txt'), "##" + chapter)

def generateImages(metadata_path):
    images_path = metadata_path/'images'/'phoneScreenshots'
    for screenshot in Path().glob("screenshots/*png"):
        target = images_path/screenshot.name
        cp(screenshot, target)

def generateIcon(metadata_path):
    import subprocess
    pad=300
    subprocess.run([
        'convert',
        'icon.png',
        '-set', 'option:distort:viewport',
        f'%[fx:w+{2*pad}]x%[fx:h+{2*pad}]-{pad}-{pad}',
        '-virtual-pixel',
        'Edge',
        '-distort',
        'SRT',
        '0',
        '+repage',
        str(metadata_path/'images'/'icon.png')
    ])


def adapt_android_preset(metadata_path):
    appname = (metadata_path/'title.txt').read_text()
    version = last_version(metadata_path)
    code = version_to_code(version)
    export_path = (Path('build/android')/appname.replace(" ", "-").lower()).with_suffix('.apk')
    icon_main = str(metadata_path/'images'/'icon.png')

    import configparser
    import json

    def get(section, name):
        return json.loads(section.get(name, 'null'))
    def set(section, name, value):
        section[name] = json.dumps(value)

    def get_named_preset(config, name):
        for section in config.sections():
            section_name = get(config[section], 'name')
            print(f"Found {section} {section_name} {name}")
            if section_name != name: continue
            return config[section], config[section+".options"]
        return None, None

    export_presets = configparser.ConfigParser()
    export_presets.read('tools/export_presets_template.cfg')
    preset, options = get_named_preset(export_presets, "Android")
    set(preset, 'export_path', str(export_path))
    set(options, 'version/name', version)
    set(options, 'version/code', code)
    set(options, 'package/name', appname)
    set(options, 'package/unique_name', config.unique_name)
    set(options, 'launcher_icons/main_192x192', icon_main)
    presets_file = Path("export_presets.cfg")
    with presets_file.open('w') as output:
        export_presets.write(output)
    modified = presets_file.read_text().replace(" = ", "=")
    presets_file.write_text(modified)

def updateSplashVersion(metadata_path):
    version = last_version(metadata_path)
    splash_svgfile = Path('examples/dice_roller/splash.svg')

    nsmap = dict(
        svg='http://www.w3.org/2000/svg',
        inkscape="http://www.inkscape.org/namespaces/inkscape",
        sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd",
        xlink="http://www.w3.org/1999/xlink",
    )

    parser = etree.XMLParser(remove_blank_text=True)
    tree = etree.parse(splash_svgfile, parser)
    root = tree.getroot()

    el = root.xpath("//svg:text[@id='version']/svg:tspan", namespaces=nsmap)
    if not el:
        print("Warning: No element with id version found is splash screen svg")
        return
    if el[0].text == version:
        print(f"Skipping splash screen version update, already {version}")
        return

    print(f"Updating splash screen version from {el[0].text} to {version}")
    el[0].text = version
    for prefix, nsurl in nsmap.items():
        etree.register_namespace(prefix, nsurl)
    print(f"Generating {splash_svgfile}...")
    tree.write(splash_svgfile, encoding='utf-8', xml_declaration=True, pretty_print=True)
    png_file = splash_svgfile.with_suffix(".png")
    print(f"Generating {png_file}...")

    if not program_exists("inkscape"):
        print("WARNING: Inkscape not detected. Splash png not updated.")
        return

    import subprocess
    subprocess.run([
        'inkscape',
        str(splash_svgfile),
        '--export-type=png',
        '--export-filename='+str(png_file)
    ])

def updateSplash(metadata_path):
    updateSplashVersion(metadata_path)
    cp(
        origin = 'examples/dice_roller/splash.png',
        target = metadata_path/'images'/'featureGraphic.png',
    )


def generateMetadata():
    metadata_path = Path("fastlane/metadata/android/en-US")
    mkdir(metadata_path)
    Path('fastlane/.gdignore').write_text('')
    generateDescriptions(metadata_path)
    generateChangelogs(metadata_path)
    updateSplash(metadata_path)
    generateImages(metadata_path)
    generateIcon(metadata_path)
    adapt_android_preset(metadata_path)
    update_flathub(metadata_path)
    update_flatpak_desktop_file(metadata_path)

def insert_markdown_as_xhtml(parent, markdown_text):
    from markdown import markdown

    # Convert markdown to HTML (XHTML-compliant)
    html = markdown(cutoff_on_mark(markdown_text), extensions=["extra"])

    # Wrap in a dummy root so we can parse multiple elements
    wrapped_html = f"<wrapper>{html}</wrapper>"

    # Parse with XML parser (NOT HTML parser!)
    parser = etree.XMLParser()
    wrapper = etree.fromstring(wrapped_html, parser=parser)

    replace_headings(wrapper)
    flatten_nested_uls(wrapper)

    # Append children to the target XML node
    for child in wrapper:
        parent.append(child)

def cutoff_on_mark(content, cutoff_marker="end-of-description"):

    pattern = re.compile(rf"<!--\s*{re.escape(cutoff_marker)}\s*-->", re.IGNORECASE)
    match = pattern.search(content)
    if match:
        return content[:match.start()]
    return content  # fallback to full content if no marker

def flatten_nested_uls(root):
    for nested_ul in root.xpath('.//ul//ul'):
        parent_li = nested_ul.getparent()
        parent_ul = parent_li.getparent()
        insertion_index = parent_ul.index(parent_li) + 1

        for li in reversed(nested_ul.findall('li')):
            parent_ul.insert(insertion_index, li)

        parent_li.remove(nested_ul)
        parent_ul.remove(parent_li)

def replace_headings(root):
    for heading in root.xpath(".//h1 | .//h2 | .//h3 | .//h4 | .//h5 | .//h6"):
        print("detectado uno")
        # Create <p><strong>...</strong></p>
        strong = etree.Element("strong")
        strong.text = heading.text
        p = etree.Element("p")
        p.append(strong)

        # Copy over tail text (if any)
        if heading.tail:
            p.tail = heading.tail

        # Replace heading with <p><strong>
        parent = heading.getparent()
        parent.replace(heading, p)


def parse_changelog_file(text):
    """
    Extract version, date and notes (markdown string) from a changelog file content.
    Expects the first line to be like: '## 1.5.3 (2025-07-09)'
    """
    import re
    lines = text.strip().splitlines()
    heading = lines[0]
    match = re.match(r'##\s+([\d\.]+)\s+\((\d{4}-\d{2}-\d{2})\)', heading)
    if not match:
        raise ValueError("Invalid changelog heading format")
    version = match.group(1)
    date = match.group(2)
    notes_md = '\n'.join(lines[1:]).strip()
    return version, date, notes_md


def get_screenshot_caption_md(image_path: Path) -> str:
    """Return caption markdown for a screenshot image. Use .md file if present, or generate from filename."""
    md_path = image_path.with_suffix(".md")
    if md_path.exists():
        return md_path.read_text(encoding="utf-8").strip()
    # Default from filename
    return image_path.stem.replace('-', ' ').replace('_', ' ').title()

def update_flathub(metadata_path):
    metainfo_path = Path(f"tools/flatpak/{config.unique_name}.metainfo.xml")

    (Path('tools/flatpak')/f"{config.unique_name}.svg").write_text(
        Path('icon.svg').read_text()
    )

    tree = etree.parse(metainfo_path)
    root = tree.getroot()

    def read_textfile(path):
        return path.read_text(encoding='utf-8').strip()

    def get_and_clear(root, tag):
        node = root.find(tag)
        if node is None:
            return
        node.clear()
        return node

    # -- existing fields

    # Title → <name>
    name_node = get_and_clear(root, "name")
    name_node.text = read_textfile(metadata_path / "title.txt")

    # Summary → <summary>
    summary_node = get_and_clear(root, "summary")
    summary_node.text = read_textfile(metadata_path / "short_description.txt")

    # Full description (markdown) → <description><p>...</p></description>
    description_node = get_and_clear(root, "description")
    insert_markdown_as_xhtml(description_node, read_textfile(metadata_path / "full_description.txt"))

    # id
    id_node = get_and_clear(root, "id")
    id_node.text = config.unique_name

    # icon
    icon_node = get_and_clear(root, "icon")
    icon_node.text = config.unique_name
    icon_node.set('type', 'stock')

    # launch method
    launchable = get_and_clear(root, "launchable")
    launchable.text = config.unique_name + ".desktop"
    launchable.set('type', 'desktop-id')

    # Screenshots
    screenshots_node = get_and_clear(root, "screenshots")
    screenshots_dir = Path("screenshots")

    default = True
    version_name = last_version(metadata_path)
    tag_name = f"{config.repo_name}-{version_name}"
    raw_repo_url_prefix = config.repo_raw.replace('refs/heads/main', tag_name)
    image_url_prefix = f"{raw_repo_url_prefix}/screenshots/"
    for image_path in sorted(screenshots_dir.glob("*.png")):
        screenshot_el = etree.SubElement(screenshots_node, "screenshot")
        if default:
            screenshot_el.set("type", "default")
            default = False

        image_el = etree.SubElement(screenshot_el, "image")
        image_url = image_url_prefix + image_path.name
        image_el.text = image_url

        caption_el = etree.SubElement(screenshot_el, "caption")
        caption_md = get_screenshot_caption_md(image_path)
        insert_markdown_as_xhtml(caption_el, caption_md)

    # project_license
    spdx_id = deduce_license()
    license_node = get_and_clear(root, "project_license")
    license_node.text = spdx_id

    # Strip scheme if present
    repo_host = 'https://github.com'
    url_fields = {
        'homepage': f"{repo_host}/{config.repo_user}/{config.repo_name}",
        'vcs-browser': f"{repo_host}/{config.repo_user}/{config.repo_name}",
        'bugtracker': f"{repo_host}/{config.repo_user}/{config.repo_name}/issues",
    }

    releases_node = get_and_clear(root, "releases")
    for release in sorted((metadata_path/"changelogs").glob('*.txt'), reverse=True):
        release_node = etree.SubElement(releases_node, 'release')
        version, date, notes = parse_changelog_file(release.read_text())
        release_node.set('version', version)
        release_node.set('date', date)
        release_description_node = etree.SubElement(release_node, 'description')
        insert_markdown_as_xhtml(release_description_node, notes)
        

    content_rating_node = root.find("content_rating")

    for url_type, url_value in url_fields.items():
        xpath_expr = f"url[@type='{url_type}']"
        url_node = get_and_clear(root, xpath_expr)
        if url_node is None:
            url_node = etree.Element("url", type=url_type)
            content_rating_node.addnext(url_node)
        url_node.text = url_value
        url_node.set("type", url_type)

    categories_node = get_and_clear(root, "categories")
    for category in config.categories:
        etree.SubElement(categories_node, "category").text = category

    keywords_node = get_and_clear(root, "keywords")
    for word in config.keywords:
        etree.SubElement(keywords_node, "keyword").text = word

    etree.indent(tree, space="  ")
    tree.write(metainfo_path, encoding='utf-8', xml_declaration=True, pretty_print=True)
    print(f"✅ Updated metainfo file: {metainfo_path}")

def deduce_license():
    from spdx_lookup import match
    if config.license:
        return config.license
    license_match = match(Path("LICENSE").read_text())
    if license_match:
        print(dir(license_match.license))
        return license_match.license.id
    raise ValueError("LICENSE content couldn't be identified, correct or explicitly set in config the SPDX id")

def update_flatpak_desktop_file(metadata_path):
    app_name = config.title
    summary = config.short_description

    Path(f"tools/flatpak/{config.unique_name}.desktop").write_text(f"""\
[Desktop Entry]
Name={app_name}
Comment={summary}
Categories={";".join(config.categories)}
Icon={config.unique_name}
Exec=godot-runner %U
Type=Application
Terminal=false
StartupNotify=true
""")


if __name__ == '__main__':
    generateMetadata()




