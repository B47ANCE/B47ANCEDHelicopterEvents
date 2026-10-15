local Config = require "B47HEAudio/Config"
local P = require "B47HEAudio/Protocol"
local Director = require "B47HEAudio/Director"
local Playback = require "B47HEAudio/Playback"
local count = 0
local function test(name, fn)
    fn(); count=count+1; print("PASS "..name)
end
local function vars(enabled, interval, duration)
    return {B47HE={EnableAudioFlights=enabled, FlightIntervalDays=interval or 1,
        FlightDurationSeconds=duration or 10}}
end
local function snapshot(nonce, revision)
    return {protocolVersion=1, clientNonce=nonce, serverEpoch="epoch_1", snapshotRevision=revision or 1,
        configRevision=1, serverNowMs=100000, enabled=true, hasFlight=true, eventId="1", soundId="rotor",
        startMs=100000, expiresMs=110000, x0=40, x1=160, y0=100, y1=100, z0=0, z1=0}
end
local function server()
    local e = {time=100000, age=0, settings=vars(true), online={{}}, sent={}, dedicatedFlag=true}
    e.now=function() return e.time end
    e.wall=function() return 1700000000000 end
    e.hours=function() return e.age end
    e.vars=function() return e.settings end
    e.dedicated=function() return e.dedicatedFlag end
    e.players=function() return e.online end
    e.position=function() return 100,100 end
    e.send=function(player,t) e.sent[#e.sent+1]={player=player, args=t} end
    local s=Director.new(e); s.update()
    return s,e
end
local function client()
    local e = {time=100000, readyFlag=true, syncFlag=true, requests={}, calls={}, empty=false}
    local function call(name)
        assert(not e.returned, "use after return: "..name)
        e.calls[#e.calls+1]=name
    end
    local emitter={}
    function emitter:playSoundImpl(name, loop, parent)
        call("play"); assert(e.owned and name=="Helicopter" and loop==false and parent==nil)
        return e.handle or 7
    end
    function emitter:tick() call("tick") end
    function emitter:setPos(x,y,z) call("position"); e.x=x; assert(y==100 and z==0) end
    function emitter:stopSoundLocal(handle) call("stop"); assert(handle==7) end
    function emitter:stopAll() call("stopAll") end
    function emitter:isEmpty() call("empty"); return e.empty end
    local world={}
    function world:getFreeEmitter() assert(not e.acquired); e.acquired=true; call("acquire"); return emitter end
    function world:takeOwnershipOfEmitter(value) assert(value==emitter); call("take"); e.owned=true end
    function world:returnOwnershipOfEmitter(value)
        assert(value==emitter and e.owned); call("return"); e.returned=true
    end
    e.now=function() return e.time end
    e.synced=function() return e.syncFlag end
    e.wall=function() return 1700000000000 end
    e.ready=function() return e.readyFlag end
    e.world=function() return world end
    e.request=function(args) e.requests[#e.requests+1]=args end
    e.log=function() end
    local s=Playback.new(e)
    return s,e
end
local function begin(s)
    s.update(true)
    local t=snapshot(s.nonce)
    s.receive(P.module,"Snapshot",t); s.update(true)
    return t
end

test("native settings validation fails closed", function()
    for _,v in ipairs({{},vars(true,0),vars(true,366),vars(true,1,181),vars("true"),vars(true,1.5)}) do
        assert(not Config.read(v).enabled)
    end
    assert(Config.read(vars(true)).enabled and not Config.read(vars(false)).enabled)
    assert(not Config.finite(0/0) and not Config.finite(math.huge))
end)
test("bounded flat protocol rejects malformed fields", function()
    local t=snapshot("n"); assert(P.snapshot(t))
    for _,key in ipairs({"clientNonce","enabled","x1","expiresMs","snapshotRevision"}) do
        local bad=P.copy(t); bad[key]=nil; assert(not P.snapshot(bad))
    end
    for _,value in ipairs({{},string.rep("a",65),"bad/path","é"}) do
        local bad=P.copy(t); bad.clientNonce=value; assert(not P.snapshot(bad))
    end
    local bad=P.copy(t); bad.x0=0/0; assert(not P.snapshot(bad))
    bad=P.copy(t); bad.force=true; assert(not P.snapshot(bad))
    bad=P.copy(t); bad.hasFlight=false; assert(not P.snapshot(bad))
    assert(not P.request({protocolVersion=1,clientNonce="n",force=true}))
    assert(not P.request(setmetatable({protocolVersion=1,clientNonce="n"},{})))
end)
test("server owns schedule and rate limits before payload work", function()
    local s,e=server(); assert(not s.active and s.due==24)
    s.command(P.module,"ForceStart",e.online[1],{}); assert(#e.sent==0)
    s.command(P.module,"SyncRequest",{}, {protocolVersion=1,clientNonce="n"}); assert(#e.sent==0)
    s.command(P.module,"SyncRequest",e.online[1], {protocolVersion=1,clientNonce="n"})
    assert(#e.sent==1 and not e.sent[1].args.hasFlight)
    for i=1,1000 do s.command(P.module,"SyncRequest",e.online[1], {}) end
    assert(#e.sent==1)
    e.age,e.time=240,101000; s.update()
    assert(s.active and s.active.startMs==e.time and s.active.expiresMs==111000)
    assert(#e.sent==2 and s.due==264)
    local deadline=s.active.expiresMs
    e.settings=vars(true,2,180); e.time=102000; s.update()
    assert(s.active.expiresMs==deadline)
    e.settings=vars(false); e.time=103000; s.update()
    assert(not s.active and not e.sent[#e.sent].args.hasFlight)
end)
test("malformed subscribers never receive snapshots; prune replaces player identity", function()
    local s,e=server(); local old=e.online[1]
    s.command(P.module,"SyncRequest",old,{})
    e.age,e.time=24,101000; s.update(); assert(#e.sent==0)
    e.online={{}}; e.time=102000; s.update(); assert(not s.subscribers[old])
    s.command(P.module,"SyncRequest",old,{protocolVersion=1,clientNonce="n"}); assert(#e.sent==0)
end)
test("absence defers one opportunity; restart cancels without catch-up", function()
    local s,e=server(); e.online={}; e.age=240; e.time=101000; s.update(); assert(not s.active)
    e.online={{}}; e.time=102000; s.update(); assert(s.active and s.serial==1)
    local fresh=Director.new(e); fresh.update(); assert(not fresh.active and fresh.due==264)
    assert(fresh.epoch~=s.epoch)
end)
test("host and invalid configuration stay silent; backward clock halts", function()
    local s,e=server(); e.dedicatedFlag=false; e.age=24; e.time=101000; s.update()
    assert(not s.active and not s.config.enabled)
    e.dedicatedFlag=true; e.settings={}; e.time=102000; s.update(); assert(not s.config.enabled)
    e.time=1; s.update(); assert(s.halted)
end)
test("no handshake from paused/setup/unsynchronized state", function()
    local s,e=client(); s.update(false); assert(#e.requests==0)
    e.readyFlag=false; s.update(true); assert(#e.requests==0)
    e.readyFlag=true; e.syncFlag=false; s.update(true); assert(#e.requests==0)
    e.syncFlag=true; s.update(true); assert(#e.requests==1 and not e.acquired)
end)
test("one local start with duplicate split-screen snapshots; original expiry", function()
    local s,e=client(); local t=begin(s); assert(e.acquired and e.owned)
    s.receive(P.module,"Snapshot",t); s.receive(P.module,"Snapshot",t)
    e.time=105000; t.serverNowMs=e.time; s.receive(P.module,"Snapshot",t); s.update(true)
    assert(e.x==100)
    local starts=0; for _,v in ipairs(e.calls) do if v=="play" then starts=starts+1 end end
    assert(starts==1)
    e.time=110000; s.update(false); assert(e.returned)
    local calls=#e.calls; s.close(); s.update(true); assert(#e.calls==calls)
end)
test("newer empty cancellation beats stale active response", function()
    local s,e=client(); local t=begin(s)
    local empty={protocolVersion=1,clientNonce=s.nonce,serverEpoch=t.serverEpoch,
        snapshotRevision=2,configRevision=2,serverNowMs=e.time,enabled=false,hasFlight=false}
    s.receive(P.module,"Snapshot",empty); assert(e.returned and s.revision==2)
    s.receive(P.module,"Snapshot",t); assert(s.descriptor==nil and s.revision==2)
end)
test("equal revision mutation and event deadline extension fail silent", function()
    for _,rev in ipairs({1,2}) do
        local s,e=client(); local t=begin(s); t.snapshotRevision=rev; t.expiresMs=120000
        s.receive(P.module,"Snapshot",t); assert(s.failed and e.returned)
    end
end)
test("late join interpolates; expired join creates no emitter", function()
    local s,e=client(); e.time=105000; s.update(true)
    local t=snapshot(s.nonce); t.serverNowMs=e.time
    s.receive(P.module,"Snapshot",t); s.update(true); assert(e.x==100); s.close()
    s,e=client(); e.time=120000; s.update(true); t=snapshot(s.nonce); t.serverNowMs=e.time
    s.receive(P.module,"Snapshot",t); s.update(true); assert(not e.acquired)
end)
test("stale nonce or different epoch cannot replace current session", function()
    local s,e=client(); local t=begin(s)
    t.clientNonce="old"; s.receive(P.module,"Snapshot",t); assert(not s.failed)
    t.clientNonce=s.nonce; t.serverEpoch="other"; t.snapshotRevision=100
    s.receive(P.module,"Snapshot",t); assert(s.epoch=="epoch_1" and s.revision==1)
    s.close(); local fresh=Playback.new(e); fresh.update(true); assert(fresh.nonce~=s.nonce)
end)
test("fresh server clock sample required; regressions and heartbeat loss stop", function()
    local s,e=client(); s.update(true); local t=snapshot(s.nonce); t.serverNowMs=97000
    s.receive(P.module,"Snapshot",t); assert(s.failed and not e.acquired)
    s,e=client(); begin(s); e.time=99999; s.update(true); assert(e.returned and s.failed)
    s,e=client(); begin(s); e.time=106001; s.update(false); assert(e.returned)
end)
test("bounded handshake retries and failed sound never retry per tick", function()
    local s,e=client(); s.update(true)
    for i=1,20 do e.time=e.time+10000; s.update(true) end
    assert(#e.requests==3 and s.failed)
    s,e=client(); e.handle=0; begin(s); assert(s.failed and e.returned)
    local n=#e.calls; for i=1,100 do s.update(true) end; assert(#e.calls==n)
end)
test("natural clip completion and repeated close return ownership once", function()
    local s,e=client(); begin(s); e.empty=true; s.update(true)
    assert(e.returned); local n=#e.calls; s.close(); s.close(); assert(#e.calls==n)
end)
test("two-client server snapshot flow, duplicate deliveries and admin disable", function()
    local a,ae=client(); local b,be=client(); a.update(true); b.update(true)
    assert(a.nonce~=b.nonce)
    local serverState,se=server(); se.online={{},{}}; se.time=101000; serverState.update()
    serverState.command(P.module,"SyncRequest",se.online[1],ae.requests[1])
    serverState.command(P.module,"SyncRequest",se.online[2],be.requests[1])
    assert(#se.sent==2 and not se.sent[1].args.hasFlight)
    ae.time,be.time=101000,101000
    a.receive(P.module,"Snapshot",se.sent[1].args); b.receive(P.module,"Snapshot",se.sent[2].args)
    se.sent={}; se.age,se.time=24,102000; serverState.update()
    ae.time,be.time=102000,102000
    for _,packet in ipairs(se.sent) do
        local target=packet.player==se.online[1] and a or b
        target.receive(P.module,"Snapshot",packet.args)
        target.receive(P.module,"Snapshot",packet.args)
    end
    a.update(true); b.update(true); assert(ae.acquired and be.acquired)
    se.sent={}; se.settings=vars(false); se.time=103000; serverState.update()
    ae.time,be.time=103000,103000
    for _,packet in ipairs(se.sent) do
        local target=packet.player==se.online[1] and a or b
        target.receive(P.module,"Snapshot",packet.args)
    end
    assert(ae.returned and be.returned and not serverState.active)
    se.sent={}; se.time=104000; serverState.update(); assert(#se.sent==0)
end)
test("ownership failure quarantines playback across reconnect", function()
    local s,e=client(); local w=e.world()
    function w:takeOwnershipOfEmitter() error("adapter failure") end
    begin(s); assert(s.failed and s.blocked and not e.returned)
    local fresh=Playback.new(e); fresh.update(true); assert(not fresh.nonce)
end)

print(string.format("%d offline behavior scenarios passed",count))
