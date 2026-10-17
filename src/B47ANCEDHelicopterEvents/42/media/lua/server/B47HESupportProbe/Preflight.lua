local P=require "B47HESupportProbe/Protocol"
local Preflight={}
function Preflight.new(env)
    local s={rates=setmetatable({}, {__mode="k"}),halted=false}
    function s.shutdown() s.halted=true; s.rates={} end
    function s.command(module,command,player,args)
        if s.halted or module~=P.module or command~="InspectRadio" or not player
            or not env.dedicated() then return end
        local now=env.now()
        if not P.time(now) or (s.last and now<s.last) then s.shutdown(); return end
        s.last=now
        local rate=s.rates[player]
        if rate and now-rate.time<2000 then return end
        s.rates[player]={time=now,nonce=rate and rate.nonce} -- malformed payloads consume the same rate allowance
        if not P.request(args) then return end
        if rate and rate.nonce==args.clientNonce then return end
        s.rates[player].nonce=args.clientNonce
        local result={protocolVersion=P.version,clientNonce=args.clientNonce,
            itemID=args.itemID,serverNowMs=now,status="disabled"}
        local vars=env.vars()
        if type(vars)=="table" and type(vars.B47HE)=="table"
            and vars.B47HE.EnableSupportPreflightProbe==true then
            local item,reason,inventory=P.lookup(player,args.itemID)
            result.status=reason or "invalid_device"
            if item then
                local device=item:getDeviceData()
                if device then
                    result.status="observed"
                    result.fullType=item:getFullType()
                    result.turnedOn=device:getIsTurnedOn()
                    result.batteryPowered=device:getIsBatteryPowered()
                    result.power=device:getPower()
                    result.channel=device:getChannel()
                    local current,_,currentInventory=P.lookup(player,args.itemID)
                    if current~=item or currentInventory~=inventory or item:getDeviceData()~=device then
                        result={protocolVersion=P.version,clientNonce=args.clientNonce,
                            itemID=args.itemID,serverNowMs=now,status="changed"}
                    end
                end
            end
        end
        if P.result(result) then env.send(player,result) end
    end
    return s
end
if isServer and isServer() then
    local instance
    Events.OnServerStarted.Add(function()
        instance=Preflight.new({now=function() return GameTime.getServerTimeMills() end,
            dedicated=function() return getCore():isDedicated() end,
            vars=function() return SandboxVars end,
            send=function(player,args) sendServerCommand(player,P.module,"RadioObservation",args) end})
    end)
    Events.OnClientCommand.Add(function(...)
        if not instance then return end
        if not pcall(instance.command,...) then
            instance.shutdown()
            print("[B47HESupportProbe] Server diagnostic stopped; API/runtime validation required.")
        end
    end)
end
return Preflight
