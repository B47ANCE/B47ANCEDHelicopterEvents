local P=require "B47HEWreckProbe/Protocol"
local Probe=require "B47HEWreckProbe/Probe"
local Client=require "B47HEWreckProbe/Client"
local count=0
local function test(name,fn) fn();count=count+1;print("PASS wreck: "..name) end
local function args(e,nonce) return {protocolVersion=1,clientNonce=nonce or "test_1",sentAtMs=e.time} end
local function run(s,e,t) s.command(P.module,"Place",e.player,t or args(e)) end
local function fixture() local e=wreckFixture();return Probe.new(e),e end
test("default or malformed toggle never checks assets or mutates",function()
    for _,value in ipairs({false,"true",1,{}}) do
        local s,e=fixture();e.on=value;run(s,e)
        assert(e.creates==0 and e.assetReads==nil and not s.attempted and e.sent[1].status=="disabled")
    end
    local s,e=fixture();e.on=nil;run(s,e);assert(e.creates==0 and e.sent[1].status=="disabled")
end)
test("dedicated and server-resolved admin are mandatory",function()
    for _,reason in ipairs({"not_dedicated","not_admin","dead","far","wrong_floor"}) do
        local s,e=fixture()
        if reason=="not_dedicated" then e.dedicatedFlag=false elseif reason=="not_admin" then e.player.admin=false
        elseif reason=="dead" then e.player.dead=true elseif reason=="far" then e.player.x=P.x+21 else e.player.z=1 end
        run(s,e);assert(e.creates==0 and not s.attempted)
    end
end)
test("payload cannot select coordinates, assets or authorize itself",function()
    for _,change in ipairs({function(t)t.x=0 end,function(t)t.admin=true end,function(t)t.model="Base.Bad" end,
        function(t)t.protocolVersion=2 end,function(t)t.clientNonce=string.rep("n",49) end,
        function(t)t.sentAtMs=0/0 end,function(t)t.sentAtMs=math.huge end,
        function(t)setmetatable(t,{}) end}) do
        local s,e=fixture();local t=args(e);change(t);run(s,e,t);assert(e.creates==0 and #e.sent==0)
    end
end)
test("stale and future intents expire without mutation",function()
    for _,offset in ipairs({-2001,2001}) do local s,e=fixture();local t=args(e);t.sentAtMs=t.sentAtMs+offset
        run(s,e,t);assert(e.creates==0 and #e.sent==0) end
end)
test("unavailable assets reject before construction",function()
    local s,e=fixture();e.assets=false;run(s,e);assert(not s.attempted and e.creates==0 and e.sent[1].status=="assets_missing")
end)
test("any missing square or chunk rejects without streaming",function()
    local s,e=fixture();e.squares[(P.x-8)..":"..P.y]=nil;run(s,e)
    assert(e.creates==0 and e.sent[1].status=="not_loaded")
    s,e=fixture();e.anchor.chunk=nil;run(s,e);assert(e.creates==0 and e.sent[1].status=="not_loaded")
end)
test("all checked obstruction types refuse placement",function()
    for _,kind in ipairs({"floor","outside","room","building","solid","solidtrans","items","special","world","moving","static"}) do
        local s,e=fixture();local q=e.square(P.x-8,P.y+8,0)
        if kind=="floor" then q.floor=nil elseif kind=="outside" then q.outside=false
        elseif kind=="items" then q.items[#q.items+1]={}
        elseif kind=="special" or kind=="world" or kind=="moving" or kind=="static" then q[kind]={{}}
        else q[kind]=true end
        run(s,e);assert(e.creates==0 and e.sent[1].status=="not_clear",kind)
    end
end)
test("one fixed anchor is initialized, inserted and published once",function()
    local s,e=fixture();run(s,e)
    assert(s.attempted and e.creates==1 and e.adds==1 and e.publishes==1)
    assert(e.sent[1].status=="published" and #e.anchor.items==2 and e.anchor.items[2].model==P.placement)
    for _,q in pairs(e.squares) do if q~=e.anchor then assert(#q.items==1) end end
end)
test("duplicate/delayed requests never publish again",function()
    local s,e=fixture();run(s,e);e.time=e.time+3000;run(s,e,args(e,"other"))
    assert(e.creates==1 and e.publishes==1 and e.sent[2].status=="attempted")
end)
test("request spam is rate bounded including malformed requests",function()
    local s,e=fixture();run(s,e,{});run(s,e);assert(e.creates==0)
    e.time=e.time+2000;run(s,e);assert(e.creates==1)
end)
test("a refused nonce cannot become a placement when settings change",function()
    local s,e=fixture();e.on=false;local t=args(e);run(s,e,t)
    e.on=true;e.time=e.time+2000;run(s,e,t)
    assert(e.creates==0 and #e.sent==1)
end)
test("native reentry sees the consumed latch",function()
    local s,e=fixture();e.duringCreate=function() e.time=e.time+3000;run(s,e,args(e,"reentrant")) end
    run(s,e);assert(e.creates==1 and e.adds==1 and e.publishes==1)
end)
test("second inspection refuses changed floors and occupants",function()
    for _,kind in ipairs({"floor","occupant","setting","role"}) do
        local s,e=fixture();e.duringCreate=function()
            if kind=="floor" then local q=e.square(P.x+1,P.y,0);q.floor={};q.items={q.floor}
            elseif kind=="occupant" then e.anchor.moving={{}} elseif kind=="setting" then e.on=false
            else e.player.admin=false end
        end
        run(s,e);assert(s.attempted and e.adds==0 and e.sent[1].status=="changed")
    end
end)
test("exceptions after attempt never authorize a second mutation",function()
    for _,kind in ipairs({"createFault","definitionMissing","addFault","publishFault"}) do
        local s,e=fixture();e[kind]=true
        assert(not pcall(run,s,e) and s.attempted)
        local creates=e.creates;e.time=e.time+3000;run(s,e,args(e,"retry"))
        assert(e.creates==creates and e.sent[#e.sent].status=="attempted")
    end
end)
test("removal does not clear the session latch",function()
    local s,e=fixture();run(s,e);e.anchor.items={e.anchor.floor};e.time=e.time+3000;run(s,e,args(e,"after_removal"))
    assert(e.adds==1 and #e.anchor.items==1 and e.sent[2].status=="attempted")
end)
test("restart has no automatic action; retained native object blocks explicit request",function()
    local s,e=fixture();run(s,e);local restarted=Probe.new(e)
    assert(e.creates==1);e.time=e.time+3000;run(restarted,e,args(e,"new_session"))
    assert(e.creates==1 and e.sent[2].status=="not_clear")
end)
test("clock failure halts before mutation",function()
    local s,e=fixture();e.time=0;run(s,e);e.time=100000;run(s,e)
    assert(s.halted and e.creates==0)
    s,e=fixture();e.on=false;run(s,e);e.on=true;e.time=e.time-1;run(s,e);assert(s.halted and e.creates==0)
end)
local function client()
    local e={time=100000,readyFlag=true,syncedFlag=true,sent={}}
    e.now=function() return e.time end;e.ready=function()return e.readyFlag end;e.synced=function()return e.syncedFlag end
    e.send=function(player,t)e.sent[#e.sent+1]=t end
    return Client.new(e),e
end
test("client only submits intent and does not retry on timeout",function()
    local s,e=client();assert(s.request({}));assert(not s.request({}) and #e.sent==1)
    e.time=e.time+5000;assert(s.result()==nil and #e.sent==1)
    assert(s.request({}) and #e.sent==2 and e.sent[1].clientNonce~=e.sent[2].clientNonce)
end)
test("client correlates and expires observations, rejecting malformed/stale replies",function()
    local s,e=client();s.request({});local t=e.sent[1]
    s.receive(P.module,"Result",{protocolVersion=1,clientNonce="wrong",status="published"});assert(s.result()==nil)
    s.receive(P.module,"Result",{protocolVersion=1,clientNonce=t.clientNonce,status="published",x=0});assert(s.result()==nil)
    s.receive(P.module,"Result",{protocolVersion=1,clientNonce=t.clientNonce,status="published"});assert(s.result()=="published")
    e.time=e.time+5000;assert(s.result()==nil)
    s.request({});s.clear();s.receive(P.module,"Result",{protocolVersion=1,clientNonce=e.sent[2].clientNonce,status="published"})
    assert(s.result()==nil)
end)
test("unsynced/disconnected client cannot send or retain a result",function()
    for _,kind in ipairs({"readyFlag","syncedFlag"}) do local s,e=client();e[kind]=false;assert(not s.request({}) and #e.sent==0) end
end)
print("PASS wreck core cases: "..count)
