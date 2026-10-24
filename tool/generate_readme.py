#!/usr/bin/env python3
"""Builds README.md from tool/README.template.md and lib/src/component_type.dart.

Run from the package root after updating screenshots in screenshots/components/:
    python3 tool/generate_readme.py
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = "https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main"
COLUMNS = 3

source = (ROOT / "lib/src/component_type.dart").read_text()
categories = dict(re.findall(r"^  (\w+)\('([^']+)'\)[,;]", source, re.M))
components = re.findall(
    r"^  (\w+)\('([^']+)', '([^']+)', NativeComponentCategory\.(\w+), '((?:[^'\\]|\\.)*)'", source, re.M
)

sections = []
for key, title in categories.items():
    rows = [c for c in components if c[3] == key]
    if not rows:
        continue
    cells = []
    for enum_name, cid, name, _, api in rows:
        api = api.replace("\\'", "'")
        cells.append(
            f'<td align="center" valign="top" width="33%">'
            f'<img src="{RAW}/screenshots/components/{cid}.jpg" width="220" alt="{name}"><br>'
            f"<b>{name}</b><br><code>NativeComponentType.{enum_name}</code><br><sub>{api}</sub></td>"
        )
    table = ["<table>"]
    for i in range(0, len(cells), COLUMNS):
        table.append("<tr>" + "".join(cells[i : i + COLUMNS]) + "</tr>")
    table.append("</table>")
    sections.append(f"### {title} ({len(rows)})\n\n" + "\n".join(table))

version = re.search(r"^version: (\S+)", (ROOT / "pubspec.yaml").read_text(), re.M).group(1)
template = (ROOT / "tool/README.template.md").read_text()
readme = template.replace("{{GALLERY}}", "\n\n".join(sections)).replace("{{RAW}}", RAW).replace("{{VERSION}}", version)
(ROOT / "README.md").write_text(readme)
print(f"README.md written: {len(components)} components in {len(sections)} sections")
