"""Lua 5.1 fake-boundary checks only; never imports or launches PZ."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'src/B47ANCEDHelicopterEvents/42/media/lua'
paths = ';'.join((SOURCE / side / '?.lua').as_posix() for side in ('shared', 'server', 'client'))
vm = LuaRuntime(unpack_returned_tuples=True)
vm.globals().package.path = paths + ';' + vm.globals().package.path
for path in SOURCE.rglob('*.lua'):
    vm.execute('assert(loadstring(...))', path.read_text(encoding='utf-8'))
vm.execute((ROOT / 'tests/support/spec.lua').read_text(encoding='utf-8'))
for side in ('server', 'host', 'client', 'sp'):
    vm = LuaRuntime(unpack_returned_tuples=True)
    vm.globals().package.path = paths + ';' + vm.globals().package.path
    vm.globals().MODE = side
    vm.execute((ROOT / 'tests/support/boot.lua').read_text(encoding='utf-8'))
print('PASS: support probe Lua 5.1 fake boundaries. NOT PZ/Kahlua/network/MP evidence.')
