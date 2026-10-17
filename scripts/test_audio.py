"""Offline Lua 5.1 fake-boundary tests; never imports or launches Project Zomboid."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'src/B47ANCEDHelicopterEvents/42/media/lua'
lua = LuaRuntime(unpack_returned_tuples=True)
paths = ';'.join((SOURCE / side / '?.lua').as_posix() for side in ('shared', 'server', 'client'))
lua.globals().package.path = paths + ';' + lua.globals().package.path
for path in SOURCE.rglob('*.lua'):
    lua.execute('assert(loadstring(...))', path.read_text(encoding='utf-8'))
lua.execute((ROOT / 'tests/audio/spec.lua').read_text(encoding='utf-8'))
for side in ('server', 'client', 'sp'):
    vm = LuaRuntime(unpack_returned_tuples=True)
    vm.globals().package.path = paths + ';' + vm.globals().package.path
    vm.globals().MODE = side
    vm.execute((ROOT / 'tests/audio/boot.lua').read_text(encoding='utf-8'))
print('PASS: Lua 5.1 compile and fake-boundary suite. NOT PZ/Kahlua/FMOD/network/runtime proof.')
