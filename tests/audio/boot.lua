-- Fake native event wiring: a separate Lua VM per side, no engine/FMOD loaded.
local hooks={}
Events=setmetatable({}, {__index=function(t,key)
    local list={}; hooks[key]=list
    local event={Add=function(fn) list[#list+1]=fn end}; rawset(t,key,event); return event
end})
local function emit(name,...)
    for _,fn in ipairs(hooks[name] or {}) do fn(...) end
end
local now,age=100000,0
local requests,sent,acquired,returned=0,0,0,0
local player={isDead=function() return false end, getX=function() return 100 end, getY=function() return 100 end}
GameTime={getServerTimeMills=function() return now end,getServerTimeShiftIsSet=function() return true end}
getTimestampMs=function() return 1700000000000 end
getGameTime=function() return {getWorldAgeHours=function() return age end} end
getCore=function() return {isDedicated=function() return MODE=="server" end} end
isServer=function() return MODE=="server" end
isClient=function() return MODE=="client" end
getPlayer=function() return player end
SandboxVars={B47HE={EnableAudioFlights=true,FlightIntervalDays=1,FlightDurationSeconds=10}}
getOnlinePlayers=function()
    return {size=function() return 1 end,get=function(_,i) assert(i==0); return player end}
end
sendServerCommand=function(p,module,command,t)
    assert(p==player and module=="B47HEAudio" and command=="Snapshot"); sent=sent+1
end
local nonce
sendClientCommand=function(p,module,command,t)
    assert(p==player and module=="B47HEAudio" and command=="SyncRequest")
    nonce=t.clientNonce; requests=requests+1
end
local emitter={setPos=function() end, tick=function() end, isEmpty=function() return false end,
    playSoundImpl=function(_,key,flag,parent) assert(key=="Helicopter" and flag==false and parent==nil);return 7 end,
    stopSoundLocal=function(_,handle) assert(handle==7) end,stopAll=function() end}
getWorld=function()
    assert(MODE=="client", "headless emitter access")
    return {getFreeEmitter=function() acquired=acquired+1;return emitter end,
        takeOwnershipOfEmitter=function() end,returnOwnershipOfEmitter=function() returned=returned+1 end}
end
if MODE=="server" then
    require "B47HEAudio/Director"
    emit("OnServerStarted"); emit("OnTick")
    emit("OnClientCommand","B47HEAudio","SyncRequest",player,{protocolVersion=1,clientNonce="n"})
    assert(sent==1)
    age,now=24,101000; emit("OnTick"); assert(sent==2 and acquired==0)
else
    require "B47HEAudio/Playback"
    emit("OnConnected"); assert(requests==0)
    emit("OnTickEvenPaused"); assert(requests==0)
    emit("OnTick")
    if MODE=="client" then
        assert(requests==1)
        emit("OnServerCommand","B47HEAudio","Snapshot",{protocolVersion=1,clientNonce=nonce,
            serverEpoch="epoch",snapshotRevision=1,configRevision=1,serverNowMs=now,enabled=true,
            hasFlight=true,eventId="1",soundId="rotor",startMs=now,expiresMs=now+10000,
            x0=40,y0=100,z0=0,x1=160,y1=100,z1=0})
        emit("OnTick"); assert(acquired==1)
        emit("OnDisconnect"); emit("OnMainMenuEnter"); emit("OnTick"); assert(returned==1)
        emit("OnConnected"); emit("OnTick"); assert(requests==2)
    else assert(requests==0 and acquired==0) end
end
print("PASS fake native event adapter: "..MODE)
