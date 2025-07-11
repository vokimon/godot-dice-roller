#!/usr/bin/env python

# generates android metadata from README.md, CHANGES.md and screenshots

from pathlib import Path
import os
import contextlib
from lxml import etree

import re

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
    title = readme_lines.pop(0).replace('#', '').strip().replace('-',' ').title()
    readme_lines = [ line for line in readme_lines if not line.strip().startswith("![") ]
    while not readme_lines[0].strip():
        readme_lines.pop(0)
    short_description = readme_lines.pop(0)

    full_description = '\n'.join(readme_lines).strip()
    dump(metadata_path/"title.txt", title)
    dump(metadata_path/"short_description.txt", short_description)
    dump(metadata_path/"full_description.txt", full_description)

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
    unique_name = 'net.canvoki.godot_dice_roller'
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
    set(options, 'package/unique_name', unique_name)
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

def adapt_android_preset(metadata_path: Path):
    flatpak_dir = Path("tools/flatpak")
    unique_id = "net.canvoki.godot_dice_roller"

    metainfo_path = flatpak_dir / f"{unique_id}.metainfo.xml"
    tree = etree.parse(str(metainfo_path))
    root = tree.getroot()

    def md_to_html(md_text):
        return markdown.markdown(md_text, extensions=['extra', 'sane_lists'])

    def update_element(tag_name, file_name):
        text = (metadata_path / file_name).read_text().strip()

        elem = root.find(f"./{tag_name}")
        if elem is None:
            elem = etree.SubElement(root, tag_name)
        elem.text = text

    update_element("name", "title.txt")
    update_element("summary", "short_description.txt")

    tree.write(str(metainfo_path), encoding="utf-8", xml_declaration=True, pretty_print=True)
    print(f"Updated {metainfo_path}")

def insert_markdown_as_xhtml(parent, markdown_text):
    from markdown import markdown

    # Convert markdown to HTML (XHTML-compliant)
    html = markdown(markdown_text, extensions=["extra"])

    # Wrap in a dummy root so we can parse multiple elements
    wrapped_html = f"<wrapper>{html}</wrapper>"

    # Parse with XML parser (NOT HTML parser!)
    parser = etree.XMLParser()
    wrapper = etree.fromstring(wrapped_html, parser=parser)

    # Transform unsupported tags (like <h2>) to allowed ones
    for element in wrapper.iter():
        if element.tag == "h2":
            element.tag = "p"
            strong = etree.Element("strong")
            strong.text = element.text
            element.text = None
            element.append(strong)

    # Append children to the target XML node
    for child in wrapper:
        parent.append(child)

def blainsert_markdown_as_xhtml(parent: etree.Element, markdown_text: str) -> None:
    """
    Convert markdown text to sanitized XHTML and append as children to the parent element.
    Replaces <h2> with <p><strong>...</strong></p> to conform with Flatpak manifest allowed tags.
    """
    from lxml import html
    from markdown import markdown

    html_fragment = markdown(markdown_text)
    doc = html.fragment_fromstring(html_fragment, create_parent=True)

    def fix_node(node):
        if node.tag == 'h2':
            p = etree.Element('p')
            strong = etree.SubElement(p, 'strong')
            strong.text = (node.text or '').strip()
            if node.tail:
                strong.tail = node.tail
            return p
        else:
            for i, child in enumerate(node):
                fixed_child = fix_node(child)
                if fixed_child is not child:
                    node[i] = fixed_child
            return node

    fixed_doc = fix_node(doc)

    # Append all children of fixed_doc to parent
    for child in fixed_doc:
        parent.append(child)
    parent.tail = '\n'

def parse_changelog_file(text):
    """
    Extract version, date and notes (markdown string) from a changelog file content.
    Expects the first line to be: '## 1.5.3 (2025-07-09)'
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


def update_flathub(metadata_path):
    # Define paths
    fastlane_dir = Path(metadata_path)
    metainfo_path = Path("tools/flatpak/net.canvoki.godot_dice_roller.metainfo.xml")

    # Load and parse existing metainfo XML
    tree = etree.parse(metainfo_path)
    root = tree.getroot()

    def read_textfile(path):
        return path.read_text(encoding='utf-8').strip()

    def read_and_format_markdown(path):
        return markdown(read_textfile(path))

    def get_and_clear(root, tag):
        node = root.find(tag)
        if node is None:
            raise ValueError(f"Missing required XML element: <{tag}>")
        node.clear()
        return node

    # Title → <name>
    name_node = get_and_clear(root, "name")
    name_node.text = read_textfile(fastlane_dir / "title.txt")

    # Summary → <summary>
    summary_node = get_and_clear(root, "summary")
    summary_node.text = read_textfile(fastlane_dir / "short_description.txt")

    # Full description (markdown) → <description><p>...</p></description>
    description_node = get_and_clear(root, "description")
    insert_markdown_as_xhtml(description_node, read_textfile(fastlane_dir / "full_description.txt"))

    # Changelogs
    releases_node = get_and_clear(root, "releases")
    changelog_files = (fastlane_dir/'changelogs').glob("*.txt")
    for changelog_file in sorted(changelog_files, reverse=True):
        print("processing", changelog_file)
        content = changelog_file.read_text(encoding='utf-8')
        version, date, notes_md = parse_changelog_file(content)

        release_el = etree.SubElement(releases_node, 'release', version=version, date=date)
        description_el = etree.SubElement(release_el, 'description')
        insert_markdown_as_xhtml(description_el, notes_md)

    # Pretty print and overwrite
    etree.indent(tree, space="  ")
    tree.write(metainfo_path, encoding='utf-8', xml_declaration=True, pretty_print=True)
    print(f"✅ Updated metainfo file: {metainfo_path}")


if __name__ == '__main__':
    generateMetadata()




