local hooks={}
Events=setmetatable({}, {__index=function(t,key)
    local list={};hooks[key]=list;local event={Add=function(fn) list[#list+1]=fn end}
    rawset(t,key,event);return event
end})
local function emit(key,...) for _,fn in ipairs(hooks[key] or {}) do fn(...) end end
isServer=function() return MODE=="server" or MODE=="host" end
isClient=function() return MODE=="client" or MODE=="host" end
getCore=function() return {isDedicated=function() return MODE=="server" end} end
local now=100000
GameTime={getServerTimeMills=function() return now end,getServerTimeShiftIsSet=function() return true end}
local inv,player,item={},{},{}
function player:isDead() return false end
function player:getInventory() return inv end
function inv:getItems() return {size=function() return 1 end} end
function inv:getItemWithID(id) if id==17 then return item end end
function item:getContainer() return inv end
function item:getID() return 17 end
function item:getFullType() return "Base.WalkieTalkie5" end
local device={getIsTurnedOn=function() return true end,
    getIsBatteryPowered=function() return true end,getPower=function() return 0.5 end,
    getChannel=function() return 88000 end}
function item:getDeviceData() return device end
getPlayer=function() return player end
SandboxVars={B47HE={EnableSupportPreflightProbe=true}}
local sent=0;local requestArgs
sendServerCommand=function(p,module,command,args)
    assert(p==player and module=="B47HESupportProbe" and command=="RadioObservation")
    assert(args.status=="observed");sent=sent+1
end
sendClientCommand=function(p,module,command,args)
    assert(p==player and module=="B47HESupportProbe" and command=="InspectRadio")
    requestArgs=args;sent=sent+1
end
require "B47HESupportProbe/Preflight"
require "B47HESupportProbe/Client"
emit("OnServerStarted");emit("OnConnected")
assert(sent==0)
if MODE=="server" or MODE=="host" then
    emit("OnClientCommand","B47HESupportProbe","InspectRadio",player,
        {protocolVersion=1,clientNonce="n",itemID=17})
    assert(sent==(MODE=="server" and 1 or 0))
    if MODE=="server" then
        now=now+2000
        item.getDeviceData=function() error("injected native API failure") end
        emit("OnClientCommand","B47HESupportProbe","InspectRadio",player,
            {protocolVersion=1,clientNonce="failure",itemID=17})
        now=now+2000
        emit("OnClientCommand","B47HESupportProbe","InspectRadio",player,
            {protocolVersion=1,clientNonce="after_failure",itemID=17})
        assert(sent==1)
    end
end
if MODE=="client" then
    assert(not B47HESupportProbe.request(player,item))
    emit("OnTick");assert(sent==0)
    assert(B47HESupportProbe.request(player,item) and sent==1)
    local result={protocolVersion=1,clientNonce=requestArgs.clientNonce,itemID=17,
        serverNowMs=100000,status="observed",fullType="Base.WalkieTalkie5",
        turnedOn=true,batteryPowered=true,power=0.5,channel=88000}
    emit("OnServerCommand","B47HESupportProbe","RadioObservation",result)
    assert(B47HESupportProbe.result(player).status=="observed")
    emit("OnDisconnect");assert(B47HESupportProbe.result(player)==nil)
    emit("OnMainMenuEnter");assert(sent==1)
    emit("OnTick")
    item.getID=function() error("injected native API failure") end
    assert(not B47HESupportProbe.request(player,item))
    emit("OnTick");assert(not B47HESupportProbe.request(player,item) and sent==1)
elseif MODE=="sp" or MODE=="host" then assert(B47HESupportProbe==nil and sent==0) end
print("PASS support fake event adapter: "..MODE)
