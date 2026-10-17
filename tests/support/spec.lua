local P=require "B47HESupportProbe/Protocol"
local Server=require "B47HESupportProbe/Preflight"
local Client=require "B47HESupportProbe/Client"
local count=0
local function test(name,fn) fn();count=count+1;print("PASS support: "..name) end
local function equipment(id)
    local inv={}; local player={dead=false}; local item={id=id or 17,kind=P.radio}
    local device={getIsTurnedOn=function() return true end,getIsBatteryPowered=function() return true end,
        getPower=function() return 0.5 end,getChannel=function() return 88000 end}
    function player:isDead() return self.dead end
    function player:getInventory() return inv end
    function inv:getItems() return {size=function() return inv.count or 1 end} end
    function inv:getItemWithID(key) if key==item.id and not inv.missing then return item end end
    function item:getContainer() if not self.moved then return inv end end
    function item:getID() return self.id end
    function item:getFullType() return self.kind end
    function item:getDeviceData() return device end
    return player,item,inv,device
end
local function request(id,nonce) return {protocolVersion=1,clientNonce=nonce or "n",itemID=id or 17} end
local function server()
    local e={time=100000,settings={B47HE={EnableSupportPreflightProbe=true}},sent={},dedicatedFlag=true}
    e.now=function() return e.time end
    e.dedicated=function() return e.dedicatedFlag end
    e.vars=function() return e.settings end
    e.send=function(player,args) e.sent[#e.sent+1]={player=player,args=P.copy(args)} end
    return Server.new(e),e
end
local function run(s,player,args) s.command(P.module,"InspectRadio",player,args or request()) end
test("strict payloads and finite signed native IDs",function()
    assert(P.request(request(-2147483648)) and P.request(request(2147483647)))
    for _,bad in ipairs({{}, {protocolVersion=1,clientNonce="n",itemID=0/0},
        {protocolVersion=1,clientNonce="n",itemID=math.huge},
        {protocolVersion=1,clientNonce="n",itemID=17,clearance=5},
        {protocolVersion=1,clientNonce={},itemID=17},
        setmetatable(request(),{})}) do assert(not P.request(bad)) end
end)
test("exact server-owned observation and no authorization fields",function()
    local s,e=server(); local player,item,inv=equipment()
    run(s,player); local r=e.sent[1]
    assert(r.player==player and r.args.status=="observed" and r.args.power==0.5)
    assert(r.args.fullType==P.radio and r.args.authorization==nil and P.result(r.args))
    assert(item:getContainer()==inv and inv:getItemWithID(17)==item)
end)
test("missing/false/malformed server option never inspects items",function()
    for _,settings in ipairs({{}, {B47HE={}}, {B47HE={EnableSupportPreflightProbe=false}},
        {B47HE={EnableSupportPreflightProbe="true"}}}) do
        local s,e=server(); e.settings=settings
        run(s,{}); assert(e.sent[1].args.status=="disabled")
    end
end)
test("connection player determines inventory; no remote item lookup",function()
    local s,e=server(); local a=equipment(17); local b=equipment(18)
    run(s,b,request(17)); assert(e.sent[1].player==b and e.sent[1].args.status=="not_owned")
    run(s,a,request(17)); assert(e.sent[2].player==a and e.sent[2].args.status=="observed")
end)
test("wrong types, nested/moved, dead and inventory cap reject",function()
    for _,reason in ipairs({"wrong_type","not_owned","dead","inventory_limit"}) do
        local s,e=server(); local p,i,inv=equipment()
        if reason=="wrong_type" then i.kind="Base.RadioBlack"
        elseif reason=="not_owned" then i.moved=true
        elseif reason=="dead" then p.dead=true else inv.count=1025 end
        run(s,p); assert(e.sent[1].args.status==reason)
    end
end)
test("ownership changes during device reads are rejected",function()
    local s,e=server(); local p,i,_,d=equipment()
    d.getPower=function() i.moved=true;return 0.5 end
    run(s,p); assert(e.sent[1].args.status=="changed" and e.sent[1].args.power==nil)
end)
test("invalid native device data produces no misleading observation",function()
    local s,e=server(); local p,_,_,d=equipment()
    d.getPower=function() return 0/0 end
    run(s,p); assert(#e.sent==0)
end)
test("malformed traffic rate-limited before inventory access",function()
    local s,e=server(); local p=equipment()
    run(s,p,{});run(s,p);assert(#e.sent==0)
    e.time=e.time+2000;run(s,p);assert(#e.sent==1)
    e.time=e.time+2000;run(s,p);assert(#e.sent==1) -- immediate prior nonce not replayed
    e.time=e.time+2000;run(s,p);assert(#e.sent==1)
end)
test("host, foreign commands and backwards clocks fail closed",function()
    local s,e=server(); local p=equipment()
    e.dedicatedFlag=false;run(s,p);assert(#e.sent==0)
    e.dedicatedFlag=true;s.command("other","InspectRadio",p,request());assert(#e.sent==0)
    run(s,p);e.time=e.time-1;run(s,p,request(17,"new"));assert(s.halted and #e.sent==1)
end)
local function client()
    local e={time=100000,readyFlag=true,syncFlag=true,sent={}}
    e.now=function() return e.time end;e.ready=function() return e.readyFlag end
    e.synced=function() return e.syncFlag end
    e.send=function(p,t) e.sent[#e.sent+1]={player=p,args=P.copy(t)} end
    return Client.new(e),e
end
local function observation(e,requestIndex)
    local t=P.copy(e.sent[requestIndex or #e.sent].args)
    t.serverNowMs=e.time;t.status="observed";t.fullType=P.radio
    t.turnedOn=true;t.batteryPowered=true;t.power=0.5;t.channel=88000
    return t
end
test("manual request only, nonce matching, dedup and detached result copy",function()
    local c,e=client(); local p,i=equipment();assert(#e.sent==0)
    assert(c.request(p,i));assert(not c.request(p,i));assert(#e.sent==1)
    local r=observation(e);r.clientNonce="other"
    c.receive(P.module,"RadioObservation",r);assert(c.result(p)==nil)
    r.clientNonce=e.sent[1].args.clientNonce;c.receive(P.module,"RadioObservation",r)
    local copy=c.result(p);assert(copy.status=="observed");copy.power=0
    assert(c.result(p).power==0.5)
end)
test("expiry, local transfer and stale server sample invalidate observations",function()
    local c,e=client();local p,i=equipment();c.request(p,i)
    local r=observation(e);r.serverNowMs=e.time-2001
    c.receive(P.module,"RadioObservation",r);assert(c.result(p)==nil)
    r.serverNowMs=e.time;c.receive(P.module,"RadioObservation",r)
    i.moved=true;assert(c.result(p)==nil)
    i.moved=false;c.request(p,i);r=observation(e);e.time=e.time+5000
    c.receive(P.module,"RadioObservation",r);assert(c.result(p)==nil)
end)
test("reconnect clears observations and never reuses nonce",function()
    local c,e=client();local p,i=equipment();c.request(p,i)
    local old=observation(e);c.clear();c.request(p,i)
    assert(e.sent[1].args.clientNonce~=e.sent[2].args.clientNonce)
    c.receive(P.module,"RadioObservation",old);assert(c.result(p)==nil)
    e.syncFlag=false;assert(not c.request(p,i) and c.result(p)==nil)
end)
test("four independent local slots, bounded capacity and no cross-slot result",function()
    local c,e=client();local players={}
    for n=1,4 do local p,i=equipment(n);players[n]=p;assert(c.request(p,i)) end
    local p,i=equipment(5);assert(not c.request(p,i) and #e.sent==4)
    c.receive(P.module,"RadioObservation",observation(e,2))
    assert(c.result(players[1])==nil and c.result(players[2]).itemID==2)
end)
test("malformed replies, regressing clock and expired requests do not become state",function()
    local c,e=client();local p,i=equipment();c.request(p,i)
    local r=observation(e);r.authorized=true
    c.receive(P.module,"RadioObservation",r);assert(c.result(p)==nil)
    e.time=e.time-1;assert(c.result(p)==nil)
    e.time=110000;assert(c.request(p,i));r=observation(e)
    e.time=e.time+5000;c.receive(P.module,"RadioObservation",r);assert(c.result(p)==nil)
end)
print("PASS support core cases: "..count)
