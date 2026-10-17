local P=require "B47HESupportProbe/Protocol"
local Client={}
function Client.new(env)
    local s={entries={},serial=0}
    function s.clear() s.entries={}; s.last=nil end -- never reset nonce serial on reconnect
    local function clock()
        local now=env.now()
        if not env.ready() or not env.synced() or not P.time(now) or (s.last and now<s.last) then
            s.clear(); return nil
        end
        s.last=now
        for player,e in pairs(s.entries) do
            if now-e.sent>=5000 then s.entries[player]=nil end
        end
        return now
    end
    function s.request(player,item)
        local now=clock()
        if not now or not player or not item then return false,"not_ready" end
        local id=item:getID()
        if not P.id(id) or P.lookup(player,id)~=item then return false,"not_owned" end
        if s.entries[player] and not s.entries[player].result then return false,"pending" end
        local n=0; for _ in pairs(s.entries) do n=n+1 end
        if not s.entries[player] and n>=4 then return false,"capacity" end
        if s.serial>=2147483647 then return false,"capacity" end
        s.serial=s.serial+1
        local nonce=string.format("%.0f_%d",now,s.serial)
        s.entries[player]={nonce=nonce,item=item,id=id,sent=now}
        env.send(player,{protocolVersion=P.version,clientNonce=nonce,itemID=id})
        return true,nonce
    end
    function s.receive(module,command,args)
        if module~=P.module or command~="RadioObservation" then return end
        local now=clock()
        if not now or not P.result(args) or math.abs(now-args.serverNowMs)>2000 then return end
        for _,e in pairs(s.entries) do
            if not e.result and e.nonce==args.clientNonce and e.id==args.itemID then
                e.result=P.copy(args); return
            end
        end
    end
    function s.result(player)
        if not clock() then return nil end
        local e=s.entries[player]
        if not e or not e.result then return nil end
        if e.result.status=="observed" and P.lookup(player,e.id)~=e.item then
            s.entries[player]=nil; return nil
        end
        return P.copy(e.result)
    end
    return s
end
if isClient and isClient() and not (isServer and isServer()) then
    local ready,failed=false,false
    local instance=Client.new({now=function() return GameTime.getServerTimeMills() end,
        synced=function() return GameTime.getServerTimeShiftIsSet() end,
        ready=function() return not failed and ready and isClient() and getPlayer()~=nil end,
        send=function(player,args) sendClientCommand(player,P.module,"InspectRadio",args) end})
    local function close() ready=false; instance.clear() end
    local function guarded(fn,...)
        local ok,a,b=pcall(fn,...)
        if ok then return a,b end
        failed=true; close()
        print("[B47HESupportProbe] Client diagnostic stopped; API/runtime validation required.")
        return false,"api_error"
    end
    Events.OnConnected.Add(close)
    Events.OnDisconnect.Add(close)
    Events.OnMainMenuEnter.Add(close)
    Events.OnTick.Add(function() ready=true end)
    Events.OnServerCommand.Add(function(...) guarded(instance.receive,...) end)
    -- Developer-only entry point; no automatic requests or player context-menu action.
    B47HESupportProbe={request=function(player,item) return guarded(instance.request,player,item) end,
        result=function(player)
            local value,reason=guarded(instance.result,player)
            if value==false then return nil,reason end
            return value
        end}
end
return Client
