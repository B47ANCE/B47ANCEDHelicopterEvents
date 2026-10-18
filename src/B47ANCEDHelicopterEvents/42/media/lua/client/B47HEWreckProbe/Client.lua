local P=require "B47HEWreckProbe/Protocol"
local Client={}
function Client.new(env)
    local s={serial=0}
    function s.clear() s.pending=nil;s.observation=nil end
    local function clock()
        local now=env.now()
        if not env.ready() or not env.synced() or not P.time(now) or (s.last and now<s.last) then
            s.clear();s.last=nil;return nil
        end
        s.last=now
        if s.pending and now-s.pending.sent>=5000 then s.pending=nil end
        if s.observation and now-s.observation.time>=5000 then s.observation=nil end
        return now
    end
    function s.request(player)
        local now=clock()
        if not now or not player then return false,"not_ready" end
        if s.pending then return false,"pending" end
        if s.serial>=2147483647 then return false,"capacity" end
        s.serial=s.serial+1
        local nonce="wreck_"..s.serial
        s.observation=nil;s.pending={nonce=nonce,sent=now}
        env.send(player,{protocolVersion=P.version,clientNonce=nonce,sentAtMs=now})
        return true,nonce
    end
    function s.receive(module,command,args)
        if module~=P.module or command~="Result" or not clock() or not P.result(args) then return end
        if s.pending and s.pending.nonce==args.clientNonce then
            s.observation={status=args.status,time=s.last};s.pending=nil
        end
    end
    function s.result() if not clock() then return nil end;return s.observation and s.observation.status end
    return s
end
if isClient and isClient() and not (isServer and isServer()) then
    local ready,failed=false,false
    local instance=Client.new({ready=function() return ready and not failed and isClient() and getPlayer()~=nil end,
        synced=function() return GameTime.getServerTimeShiftIsSet() end,
        now=function() return GameTime.getServerTimeMills() end,
        send=function(player,args) sendClientCommand(player,P.module,"Place",args) end})
    local function close() ready=false;instance.clear() end
    local function guarded(fn,...)
        local ok,a,b=pcall(fn,...)
        if ok then return a,b end
        failed=true;close()
        print("[B47HEWreckProbe] Client diagnostic halted; API validation required. "..tostring(a))
        return false,"api_error"
    end
    Events.OnConnected.Add(close);Events.OnDisconnect.Add(close);Events.OnMainMenuEnter.Add(close)
    Events.OnTick.Add(function() ready=true end) -- readiness only; never sends or spawns
    Events.OnServerCommand.Add(function(...) guarded(instance.receive,...) end)
    -- Manual developer console entry only. The server independently authorizes every request.
    B47HEWreckProbe={request=function(player) return guarded(instance.request,player or getPlayer()) end,
        result=function() return guarded(instance.result) end}
end
return Client
