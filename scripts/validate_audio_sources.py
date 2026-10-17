"""Bounded Lua-only source/metadata checks. No package, installation or game execution."""
import hashlib
import json
import re
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / 'src/B47ANCEDHelicopterEvents/42'
LUA = MOD / 'media/lua'
expected = {
    'shared/B47HEAudio/Config.lua', 'shared/B47HEAudio/Protocol.lua',
    'server/B47HEAudio/Director.lua', 'client/B47HEAudio/Playback.lua',
    'shared/B47HESupportProbe/Protocol.lua', 'server/B47HESupportProbe/Preflight.lua',
    'client/B47HESupportProbe/Client.lua',
}
assert {p.relative_to(LUA).as_posix() for p in LUA.rglob('*.lua')} == expected
seen = set()
for path in MOD.rglob('*'):
    name = path.relative_to(MOD).as_posix()
    assert name.lower() not in seen, f'Case collision: {name}'
    seen.add(name.lower())
    if path.is_file():
        assert path.suffix in {'.lua', '.json', '.txt', '.info', '.png'}, name
for path in LUA.rglob('*.lua'):
    text = path.read_text()
    for module in re.findall(r'require\s*["\x27]([^"\x27]+)', text):
        assert any(side + '/' + module + '.lua' in expected
                   for side in ('shared', 'client', 'server')), (path, module)
    # No game-mod imports, native wrappers, world/AI/persistence writes, or ordinary playback.
    for banned in ('luajava', 'requireJava', 'loadstring', 'getCell(', 'getGridSquare(',
                   'getModData(', 'ModData.', 'addSound(', 'playWorldSound',
                   ':playSound(', ':playSoundLooped(', ':stopSound(', 'setServerTimeShift',
                   'createZombie', 'addItem(', 'IsoObject.new', 'Helicopter.'):
        assert banned not in text, (path, banned)
    if 'client' not in path.parts:
        assert not re.search(r'getFreeEmitter|playSoundImpl|takeOwnershipOfEmitter', text), path
    if 'B47HESupportProbe' in path.parts:
        assert not re.search(r':(?:set[A-Z]\w*|Kill|die|Hit|Remove|AddItem|removeItem)\s*\(', text), path
        assert not re.search(r'getModData|ModData\.|getCell|addSound|Helicopter\.', text), path
info = dict(line.split('=', 1) for line in (MOD / 'mod.info').read_text().splitlines() if '=' in line)
assert info['id'] == 'B47ANCEDHelicopterEvents'
assert info['modversion'] == (ROOT / 'VERSION').read_text().strip()
assert not any(key in info for key in ('require', 'pack', 'tiledef'))
settings = (MOD / 'media/sandbox-options.txt').read_text()
options = re.findall(r'option B47HE\.(\w+)\s*\{([^}]+)\}', settings)
assert {name for name, _ in options} == {'EnableAudioFlights','FlightIntervalDays','FlightDurationSeconds','EnableSupportPreflightProbe'}
assert len(options) == 4
translation = json.loads((LUA / 'shared/Translate/EN/Sandbox.json').read_text())
keys = {'Sandbox_B47HE', 'Sandbox_B47HESupport'}
for name, body in options:
    token = re.search(r'translation\s*=\s*(\w+)', body)[1]
    assert token == 'B47HE_' + name
    keys.update({'Sandbox_' + token, 'Sandbox_' + token + '_tooltip'})
assert set(translation) == keys and all(translation.values())
for asset, slot, dimensions in (
    ('B47_ICON_SMALL.png', info['icon'], (64,64)),
    ('B47_ICON.png', info['poster'], (128,128)),
):
    original = (ROOT / 'assets/branding' / asset).read_bytes()
    assert (MOD / slot).read_bytes() == original
    assert original[:8] == b'\x89PNG\r\n\x1a\n'
    assert struct.unpack('>II', original[16:24]) == dimensions
    print(f'Exact existing branding: {asset} SHA256 {hashlib.sha256(original).hexdigest()}')
assert 24 * (64 + 64 + 32) + 32 < 4096
print('STATIC PASS: bounded source surface, Lua-only guard, require case, metadata, translations, existing artwork bytes and scalar-size ceiling.')
print('NOT TESTED: native loader, localization fallback, Linux, Lua overloads, audio, packets, SP/host/dedicated MP.')
