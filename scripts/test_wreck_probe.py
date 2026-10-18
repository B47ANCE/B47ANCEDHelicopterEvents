"""Lua 5.1 fake-boundary and event checks. No PZ classes or game/server launch."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
LUA = ROOT/'src/B47ANCEDHelicopterEvents/42/media/lua'
PATHS = ';'.join((LUA/side/'?.lua').as_posix() for side in ('shared', 'server', 'client'))


def vm():
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().package.path = PATHS+';'+lua.globals().package.path
    for path in LUA.rglob('*.lua'):
        lua.execute('assert(loadstring(...))', path.read_text())
    lua.execute((ROOT/'tests/wreck/fixtures.lua').read_text())
    return lua


vm().execute((ROOT/'tests/wreck/spec.lua').read_text())
for mode, fault in [('server', False), ('server', True), ('client', False), ('host', False), ('sp', False)]:
    lua = vm()
    lua.globals().MODE = mode
    lua.globals().FAULT = fault
    lua.execute((ROOT/'tests/wreck/boot.lua').read_text())
print('OFFLINE PASS: wreck protocol/core and fake adapters. Native/Kahlua/materials/save/MP NOT TESTED.')
