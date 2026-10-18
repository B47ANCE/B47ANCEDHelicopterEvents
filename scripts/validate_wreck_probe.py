"""Read-only source/asset provenance checks; no PZ launch or packaging."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT/'src/B47ANCEDHelicopterEvents/42'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--require-local-assets', action='store_true')
    args = parser.parse_args()
    settings = (MOD/'media/sandbox-options.txt').read_text()
    body = re.search(r'option B47HE.EnableDecorativeWreckProbe\s*\{([^}]+)\}', settings)[1]
    assert 'default = false' in body and 'type = boolean' in body
    protocol = (MOD/'media/lua/shared/B47HEWreckProbe/Protocol.lua').read_text()
    assert 'x=8871,y=8253,z=0,radius=8' in protocol
    definition = (MOD/'media/scripts/B47HE_WreckProbe.txt').read_text()
    assert re.findall(r'\bmodel (\w+)', definition) == ['WreckProbeUpright']
    assert re.findall(r'\bspriteModel (\w+)', definition) == ['WreckProbeUprightPlacement']
    assert 'static = true' in definition and 'modelScript = B47HE.WreckProbeUpright' in definition
    server = (MOD/'media/lua/server/B47HEWreckProbe/Probe.lua').read_text()
    assert server.index('s.attempted=true') < server.index('env.create(square)') < server.index('square:AddTileObject(object)')
    assert server.count('square:AddTileObject(object)') == 1 and server.count('object:transmitCompleteItemToClients()') == 1
    assert all(token not in server for token in ('OnTick', 'OnLoadGridSquare', 'ModData.', ':getModData(', 'AddItem(', 'RemoveTileObject'))
    receipt = json.loads((ROOT/'assets/crash-sites/WRECK_PROBE_ASSETS.json').read_text())
    expected = {'media/models_X/B47HE/wreck_probe_upright.glb', 'media/textures/B47HE/wreck_probe_upright.png'}
    assert {str(Path(r['path']).relative_to(MOD.relative_to(ROOT))).replace('\\', '/') for r in receipt['outputs']} == expected
    missing = []
    for output in receipt['outputs']:
        path = ROOT/output['path']
        if not path.exists():
            missing.append(output['path'])
            continue
        data = path.read_bytes()
        assert len(data) == output['bytes'] and hashlib.sha256(data).hexdigest() == output['sha256'], path.name
        assert subprocess.run(['git', 'check-ignore', '--quiet', str(path)], cwd=ROOT).returncode == 0
        if path.suffix == '.png':
            assert struct.unpack('>II', data[16:24]) == (2048, 2048)
        else:
            assert struct.unpack_from('<4sII', data) == (b'glTF', 2, len(data))
    assert not missing or not args.require_local_assets, 'Local authoring assets are missing; prepare them before any diagnostic use'
    tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
    assert not any(p.startswith(('src/B47ANCEDHelicopterEvents/42/media/models_X/B47HE/',
                                 'src/B47ANCEDHelicopterEvents/42/media/textures/B47HE/')) for p in tracked)
    if missing:
        print('NOT PREPARED: ignored local model/texture derivatives absent; native requests must fail closed. Static source checks only.')
    else:
        print('OFFLINE PASS: local asset hashes/dimensions and ignore boundaries; not native importer or material proof.')
    print('STATIC PASS: fixed server fixture, default-off option, bounded single-object source and no regeneration hooks.')


if __name__ == '__main__':
    main()
