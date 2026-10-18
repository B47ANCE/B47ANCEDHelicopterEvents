local P=require "B47HEWreckProbe/Protocol"
local e=wreckFixture();local hooks={}
Events=setmetatable({}, {__index=function(t,k)local list={};hooks[k]=list;local h={Add=function(fn)list[#list+1]=fn end};rawset(t,k,h);return h end})
local function emit(k,...)for _,fn in ipairs(hooks[k] or {})do fn(...)end end
isServer=function()return MODE=="server" or MODE=="host" end
isClient=function()return MODE=="client" or MODE=="host" end
getCore=function()return {isDedicated=function()return MODE=="server" end}end
GameTime={getServerTimeMills=e.now,getServerTimeShiftIsSet=function()return true end}
SandboxVars={B47HE={EnableDecorativeWreckProbe=true}}
getPlayer=function()return e.player end
getCell=function()return {getGridSquare=function(_,x,y,z)return e.square(x,y,z)end}end
IsoObject={new=function(q,sprite,name)assert(sprite==P.fallback and name==P.objectName);return e.create(q)end}
fileExists=function(path)return true end
getScriptManager=function()return {
    getModelScript=function(_,name)assert(name==P.model);return {isStatic=function()return true end,getMeshName=function()return P.mesh end,getTextureName=function()return P.texture end}end,
    getSpriteModel=function(_,name)assert(name==P.placement);return {getModelScriptName=function()return P.model end}end}
end
sendServerCommand=function(player,module,command,args)assert(module==P.module and command=="Result");e.send(player,args)end
local clientRequest
sendClientCommand=function(player,module,command,args)assert(module==P.module and command=="Place");clientRequest=args end
require "B47HEWreckProbe/Probe";require "B47HEWreckProbe/Client"
emit("OnServerStarted");emit("OnConnected");emit("OnTick");assert(e.creates==0 and not clientRequest)
if MODE=="server" or MODE=="host" then
    local function request(n)emit("OnClientCommand",P.module,"Place",e.player,{protocolVersion=1,clientNonce=n,sentAtMs=e.time})end
    if MODE=="server" and FAULT then e.publishFault=true end
    request("first")
    assert(e.creates==(MODE=="server" and 1 or 0))
    emit("OnServerStarted");e.time=e.time+3000;request("second")
    assert(e.creates==(MODE=="server" and 1 or 0))
    assert(B47HEWreckProbe==nil and hooks.OnTick==nil)
elseif MODE=="client" then
    assert(B47HEWreckProbe.request() and clientRequest and e.creates==0)
    emit("OnServerCommand",P.module,"Result",{protocolVersion=1,clientNonce=clientRequest.clientNonce,status="published"})
    assert(B47HEWreckProbe.result()=="published")
    emit("OnDisconnect");assert(B47HEWreckProbe.result()==nil and e.creates==0)
    emit("OnServerCommand",P.module,"Result",{protocolVersion=1,clientNonce=clientRequest.clientNonce,status="published"})
    assert(B47HEWreckProbe.result()==nil)
else assert(B47HEWreckProbe==nil and e.creates==0)end
print("PASS wreck event adapter: "..MODE..(FAULT and " publication-fault" or ""))
