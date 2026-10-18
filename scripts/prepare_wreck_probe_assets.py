"""Prepare local source assets only. Never deploys, packages, uploads or opens PZ.

Supplied model redistribution rights remain unverified. Outputs are Git-ignored;
the public receipt and recipe do not distribute those supplied binaries.
"""
from pathlib import Path
import hashlib
import io
import json
import struct
from PIL import Image, __version__ as pillow_version

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / 'src/B47ANCEDHelicopterEvents/42'
SOURCE = ROOT / 'assets/crash-sites/local-optimized/v0.1.0-dev.5/upright/crash_site_upright.glb'
RECEIPT = ROOT / 'assets/crash-sites/WRECK_PROBE_ASSETS.json'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def expected():
    report = json.loads((SOURCE.parent/'export-report.json').read_text())
    entry = next(r for r in report['outputs'] if r['name'] == SOURCE.name)
    raw = SOURCE.read_bytes()
    assert sha(raw) == entry['sha256'] and len(raw) == entry['bytes'], 'Optimized source drift'
    assert struct.unpack_from('<4sII', raw) == (b'glTF', 2, len(raw))
    chunks, offset = {}, 12
    while offset < len(raw):
        size, kind = struct.unpack_from('<I4s', raw, offset)
        chunks[kind] = raw[offset+8:offset+8+size]
        offset += 8+size
    data = json.loads(chunks[b'JSON'])
    texture = data['materials'][0]['pbrMetallicRoughness']['baseColorTexture']['index']
    image = data['images'][data['textures'][texture]['source']]
    view = data['bufferViews'][image['bufferView']]
    start = view.get('byteOffset', 0)
    encoded = chunks[b'BIN\0'][start:start+view['byteLength']]
    with Image.open(io.BytesIO(encoded)) as source:
        decoded = source.convert('RGB')
        output = io.BytesIO()
        decoded.save(output, format='PNG', compress_level=9)
        png = output.getvalue()
        assert decoded.size == (2048, 2048)
        with Image.open(io.BytesIO(png)) as readback:
            assert decoded.tobytes() == readback.convert('RGB').tobytes(), 'Texture pixel drift'
    return raw, png, sha(encoded)


def main():
    original = json.loads((ROOT/'assets/crash-sites/MANIFEST.json').read_text())
    for item in original['files']:
        assert sha((ROOT/item['localPath']).read_bytes()) == item['sha256'], 'Original source drift'
    raw, png, encoded_hash = expected()
    outputs = [(MOD/'media/models_X/B47HE/wreck_probe_upright.glb', raw),
               (MOD/'media/textures/B47HE/wreck_probe_upright.png', png)]
    # Check every destination before writing; never replace an unexpected file.
    for path, data in outputs:
        assert not path.exists() or path.read_bytes() == data, f'Preserve differing output: {path.name}'
    receipt = {'authoringVersion': (ROOT/'VERSION').read_text().strip(),
               'status': 'LOCAL DIAGNOSTIC ASSETS ONLY; native/dedicated NOT TESTED; distribution rights unverified',
               'input': {'path': SOURCE.relative_to(ROOT).as_posix(), 'sha256': sha(raw)},
               'baseColorEncodedSha256': encoded_hash,
               'textureConversion': f'Pillow {pillow_version}; decoded RGB pixels unchanged, 2048x2048 PNG',
               'fallback': 'src/B47ANCEDHelicopterEvents/42/media/ui/B47_ICON_SMALL.png',
               'outputs': [{'path': p.relative_to(ROOT).as_posix(), 'bytes': len(b), 'sha256': sha(b)}
                           for p, b in outputs]}
    receipt_bytes = (json.dumps(receipt, indent=2)+'\n').encode()
    # Git may check this text receipt out with CRLF. Preserve its bytes while
    # requiring the same JSON content; binary outputs still require exact bytes.
    assert not RECEIPT.exists() or json.loads(RECEIPT.read_text(encoding='utf-8-sig')) == receipt, 'Preserve existing asset receipt'
    for path, data in outputs:
        path.parent.mkdir(parents=True, exist_ok=True)
        if not path.exists():
            with path.open('xb') as handle:
                handle.write(data)
    if not RECEIPT.exists():
        with RECEIPT.open('xb') as handle:
            handle.write(receipt_bytes)
    print('OFFLINE PASS: local GLB copy and RGB-identical base-color PNG; originals unchanged. Not PZ import proof.')


if __name__ == '__main__':
    main()
