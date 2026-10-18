local P=require "B47HEWreckProbe/Protocol"
local Probe={}
local function empty(list) return list and list:size()==0 end
local function clear(square)
    if not square or not square:getChunk() then return false,"not_loaded" end
    local floor=square:getFloor()
    if not floor or not square:isOutside() or square:getRoom() or square:getBuilding()
        or square:isSolid() or square:isSolidTrans() then return false,"not_clear" end
    local objects=square:getObjects()
    if not objects or objects:size()~=1 or objects:get(0)~=floor
        or not empty(square:getSpecialObjects()) or not empty(square:getWorldObjects())
        or not empty(square:getMovingObjects()) or not empty(square:getStaticMovingObjects()) then
        return false,"not_clear"
    end
    return true,floor
end
function Probe.new(env)
    local s={attempted=false,halted=false,rates=setmetatable({}, {__mode="k"})}
    function s.shutdown() s.halted=true end -- no recovery/reset entry point
    local function eligible(player)
        if player:isDead() or not player:isAccessLevel("admin") then return false end
        local x,y,z=player:getX(),player:getY(),player:getZ()
        return type(x)=="number" and type(y)=="number" and z==P.z
            and (x-P.x)^2+(y-P.y)^2<=400
    end
    local function inspect(previous)
        local found={}; local anchor
        for x=P.x-P.radius,P.x+P.radius do
            for y=P.y-P.radius,P.y+P.radius do
                local square=env.square(x,y,P.z)
                local ok,value=clear(square)
                if not ok then return nil,value end
                local i=#found+1
                if previous and (previous[i].square~=square or previous[i].floor~=value) then
                    return nil,"changed"
                end
                found[i]={square=square,floor=value}
                if x==P.x and y==P.y then anchor=square end
            end
        end
        return anchor,found
    end
    function s.command(module,command,player,args)
        if s.halted or module~=P.module or command~="Place" or env.dedicated()~=true
            or not player or not player:isAccessLevel("admin") then return end
        local now=env.now()
        if not P.time(now) or (s.last and now<s.last) then s.shutdown();return end
        s.last=now
        local before=s.rates[player]
        if before and now-before.time<2000 then return end
        s.rates[player]={time=now,nonce=before and before.nonce}
        if not P.request(args) or math.abs(now-args.sentAtMs)>2000 then return end
        if before and before.nonce==args.clientNonce then return end
        s.rates[player].nonce=args.clientNonce
        local function reply(status)
            env.send(player,{protocolVersion=P.version,clientNonce=args.clientNonce,status=status})
        end
        if env.enabled()~=true then reply("disabled");return end
        if s.attempted then reply("attempted");return end
        if not eligible(player) then reply("not_nearby");return end
        if env.assetsReady()~=true then reply("assets_missing");return end
        local square,snapshot=inspect()
        if not square then reply(snapshot);return end
        -- Consume the session attempt BEFORE native construction or world mutation.
        -- Never infer rollback or retry permission after a native exception.
        s.attempted=true
        local object=env.create(square)
        if not object or object:getSquare()~=square or not object:getSprite()
            or object:getContainer() then error("invalid decorative object") end
        object:setSpriteModelName(P.placement)
        if not object:getSpriteModel() then error("missing placement definition") end
        local current=inspect(snapshot)
        if current~=square or env.enabled()~=true or not eligible(player) then reply("changed");return end
        square:AddTileObject(object)
        local objects=square:getObjects()
        if objects:size()~=2 or objects:get(1)~=object or object:getSquare()~=square then
            error("ambiguous insertion")
        end
        object:transmitCompleteItemToClients() -- one publication; no delivery/durability claim
        reply("published")
    end
    return s
end
if isServer and isServer() then
    local instance
    Events.OnServerStarted.Add(function()
        if instance then return end -- repeated startup event cannot reset the attempt latch
        instance=Probe.new({
            dedicated=function() return getCore():isDedicated() end,
            now=function() return GameTime.getServerTimeMills() end,
            enabled=function() return type(SandboxVars)=="table" and type(SandboxVars.B47HE)=="table"
                and SandboxVars.B47HE.EnableDecorativeWreckProbe==true end,
            square=function(x,y,z) return getCell():getGridSquare(x,y,z) end,
            create=function(square) return IsoObject.new(square,P.fallback,P.objectName) end,
            assetsReady=function()
                if not fileExists("media/models_X/"..P.mesh) or not fileExists(P.texture)
                    or not fileExists(P.fallback) then return false end
                local manager=getScriptManager()
                local model=manager and manager:getModelScript(P.model)
                local placement=manager and manager:getSpriteModel(P.placement)
                return model~=nil and placement~=nil and model:isStatic()==true
                    and model:getMeshName()==P.mesh and model:getTextureName()==P.texture
                    and placement:getModelScriptName()==P.model
            end,
            send=function(player,args) sendServerCommand(player,P.module,"Result",args) end})
    end)
    Events.OnClientCommand.Add(function(...)
        if not instance then return end
        local ok,reason=pcall(instance.command,...)
        if not ok then
            instance.shutdown()
            print("[B47HEWreckProbe] Diagnostic halted; inspect disposable save. "..tostring(reason))
        end
    end)
end
return Probe
