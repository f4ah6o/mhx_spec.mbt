from __future__ import annotations

import sys
from pathlib import Path


def make_identifier(rel: str) -> str:
    out = []
    for ch in rel:
        if ch.isalnum():
            out.append(ch.lower())
        else:
            out.append('_')
    ident = ''.join(out).strip('_')
    while '__' in ident:
        ident = ident.replace('__', '_')
    return f'fixture_{ident}'


def emit_block(text: str) -> str:
    lines = text.splitlines()
    if not lines:
        return '  #|\n  #|'
    body = '\n'.join(f'  #|{line}' for line in lines)
    return body + '\n  #|'


def main() -> None:
    repo = Path(sys.argv[1])
    output = Path(sys.argv[2])
    fixture_root = repo / 'fixtures'
    files = sorted(p for p in fixture_root.rglob('*') if p.is_file())
    blocks: list[str] = []
    entries: list[tuple[str, str]] = []
    paths: list[str] = []
    for path in files:
        rel = path.relative_to(repo).as_posix()
        ident = make_identifier(rel)
        text = path.read_text(encoding='utf-8').rstrip('\n')
        blocks.append(f'///|\nlet {ident} : String =\n{emit_block(text)}\n')
        entries.append((rel, ident))
        paths.append(rel)

    map_entries = '\n'.join(f'    "{rel}": {ident},' for rel, ident in entries)
    path_entries = '\n'.join(f'    "{rel}",' for rel in paths)
    content = f'''///|
/// Generated from fixtures/ by scripts/embed_fixtures.py. Do not edit manually.

'''
    content += '\n'.join(blocks)
    content += f'''///|
let embedded_fixture_map : Map[String, String] = {{
{map_entries}
}}

///|
pub fn embedded_fixture(path : String) -> String? {{
  embedded_fixture_map.get(path)
}}

///|
pub fn embedded_fixture_paths() -> Array[String] {{
  [
{path_entries}
  ]
}}
'''
    output.write_text(content, encoding='utf-8')


if __name__ == '__main__':
    main()
