"""Portable research-document checks, retained alongside the audio source checks."""
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
required = ('API_AUDIT', 'API_EVIDENCE', 'ENGINE_BLOCKERS', 'MP_AUTHORITY',
            'RUNTIME_TEST_PLAN', 'AUDIO_FEASIBILITY', 'AUDIO_API_EVIDENCE')
for name in required:
    assert (ROOT / 'docs' / f'{name}.md').is_file(), name
local_evidence_links = 0
for path in [ROOT / 'README.md', *(ROOT / 'docs').glob('*.md')]:
    for target in re.findall(r'\]\(([^)]+)\)', path.read_text(encoding='utf-8-sig')):
        if target.startswith(('https://', 'http://')):
            continue
        relative = target.partition('#')[0]
        if relative.startswith(('evidence/', 'evidence-followup/', 'history/')):
            local_evidence_links += 1
            continue  # Private evidence is not distributed; no source validation claim.
        assert (path.parent / relative).exists(), (path.name, target)
plan = (ROOT / 'docs/RUNTIME_TEST_PLAN.md').read_text(encoding='utf-8-sig')
rows = [line for line in plan.splitlines() if re.match(r'^\| A-R\d+', line)]
assert len(rows) == 12, 'Expected twelve dedicated audio scenarios'
assert all('NOT TESTED' in row for row in rows), 'No runtime PASS without operator evidence'
status = json.loads((ROOT / 'docs/VALIDATION_STATUS.json').read_text())
assert status['projectVersion'] == (ROOT / 'VERSION').read_text().strip()
assert status['G7'] == 'BLOCKED / NOT TESTED'
assert status['stableReleaseG8'] == 'BLOCKED'
tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
for name in filter(None, tracked):
    assert not name.startswith(('.codex/', '.agents/', 'docs/evidence/',
                                'docs/evidence-followup/', 'docs/history/')), name
    assert Path(name).suffix.lower() not in ('.class', '.jar', '.zip', '.log', '.pem', '.key'), name
assert {p.relative_to(ROOT).as_posix() for p in ROOT.glob('src/**/mod.info')} == {
    'src/B47ANCEDHelicopterEvents/42/mod.info'}, 'Unexpected runtime metadata surface'
print(f'STATIC PASS: documentation links, 12 NOT TESTED audio scenarios, gates and tracked-file boundaries; {local_evidence_links} private evidence links not validated.')
print('NOT TESTED: Lua runtime/overload behavior, sound/network effects, SP, clean provenance and dedicated MP.')
