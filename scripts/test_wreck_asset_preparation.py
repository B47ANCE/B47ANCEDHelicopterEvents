"""Isolated receipt/output preflight regressions; no real assets or PZ touched.

The approved input-byte supplier is stubbed: these tests exercise text receipts,
destination protection and file creation, not GLB decoding or PNG conversion.
"""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('wreck_asset_prep', ROOT/'scripts/prepare_wreck_probe_assets.py')
prep = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prep)
VERSION = (ROOT/'VERSION').read_text()
MODEL, TEXTURE = b'approved-model-fixture', b'approved-texture-fixture'
SAFE = ROOT/'.tmp-wreck-preparation-tests'
SAFE.mkdir(exist_ok=True)
assert not SAFE.is_symlink() and not getattr(SAFE, 'is_junction', lambda: False)()
assert SAFE.resolve().is_relative_to(ROOT.resolve())
owner = tempfile.TemporaryDirectory(prefix='receipt-', dir=SAFE)
work = Path(owner.name).resolve()


def fixture(name, receipt=None):
    root = work/name
    root.mkdir()
    (root/'VERSION').write_text(VERSION, encoding='utf-8')
    manifest = root/'assets/crash-sites/MANIFEST.json'
    manifest.parent.mkdir(parents=True)
    manifest.write_text('{"files": []}', encoding='utf-8')
    prep.ROOT, prep.MOD = root, root/'src/B47ANCEDHelicopterEvents/42'
    prep.SOURCE, prep.RECEIPT = root/'optimized.glb', root/'assets/crash-sites/WRECK_PROBE_ASSETS.json'
    prep.expected = lambda: (MODEL, TEXTURE, '0'*64)
    if receipt is not None:
        prep.RECEIPT.write_bytes(receipt)
    return [prep.MOD/'media/models_X/B47HE/wreck_probe_upright.glb',
            prep.MOD/'media/textures/B47HE/wreck_probe_upright.png']


def run():
    with contextlib.redirect_stdout(io.StringIO()):
        prep.main()


try:
    assert work.is_relative_to(SAFE.resolve())
    outputs = fixture('initial')
    run()
    assert [p.read_bytes() for p in outputs] == [MODEL, TEXTURE]
    canonical = prep.RECEIPT.read_bytes()
    stamps = [p.stat().st_mtime_ns for p in [*outputs, prep.RECEIPT]]
    run()
    assert [p.stat().st_mtime_ns for p in [*outputs, prep.RECEIPT]] == stamps
    print('PASS asset receipt: initial preparation and unchanged-file idempotence')

    crlf = canonical.replace(b'\n', b'\r\n')
    outputs = fixture('windows-checkout', crlf)
    run()
    assert [p.read_bytes() for p in outputs] == [MODEL, TEXTURE]
    assert prep.RECEIPT.read_bytes() == crlf
    print('PASS asset receipt: equivalent CRLF checkout accepted without rewriting receipt')

    changed = json.loads(canonical)
    changed['input']['sha256'] = 'f'*64
    changed_bytes = json.dumps(changed).encode()
    outputs = fixture('changed-receipt', changed_bytes)
    try:
        run()
    except AssertionError as error:
        assert str(error) == 'Preserve existing asset receipt'
    else:
        raise AssertionError('Changed receipt was accepted')
    assert all(not p.exists() for p in outputs) and prep.RECEIPT.read_bytes() == changed_bytes
    print('PASS asset receipt: changed provenance refused before output writes')

    outputs = fixture('differing-output', canonical)
    outputs[0].parent.mkdir(parents=True)
    outputs[0].write_bytes(b'unrelated-existing-file')
    try:
        run()
    except AssertionError as error:
        assert str(error).startswith('Preserve differing output:')
    else:
        raise AssertionError('Differing output was replaced')
    assert outputs[0].read_bytes() == b'unrelated-existing-file' and not outputs[1].exists()
    assert prep.RECEIPT.read_bytes() == canonical
    print('PASS asset receipt: differing binary destination preserved; no other output written')
finally:
    # Bound the standard-library recursive cleanup to this script's own fixture.
    target = Path(owner.name).resolve()
    assert target == work and target != SAFE.resolve() and target.is_relative_to(SAFE.resolve())
    owner.cleanup()
print('OFFLINE PASS: 4 isolated preparation cases. Not asset codec, native import or MP evidence.')
