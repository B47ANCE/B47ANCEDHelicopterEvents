-- Read-only diagnostic protocol. Observations never authorize support.
local P = {module="B47HESupportProbe", version=1, radio="Base.WalkieTalkie5"}
function P.integer(v, lo, hi)
    return type(v)=="number" and v==v and v>=lo and v<=hi and v==math.floor(v)
end
function P.time(v) return P.integer(v, 1, 9007199254740991) end
function P.id(v) return P.integer(v, -2147483648, 2147483647) end
function P.token(v)
    return type(v)=="string" and #v>0 and #v<=64 and not v:find("[^A-Za-z0-9_.%-]")
end
local base={protocolVersion=true,clientNonce=true,itemID=true}
local reply={protocolVersion=true,clientNonce=true,itemID=true,serverNowMs=true,status=true}
local fields={fullType=true,turnedOn=true,batteryPowered=true,power=true,channel=true}
local statuses={observed=true,disabled=true,dead=true,not_owned=true,wrong_type=true,
    changed=true,inventory_limit=true,invalid_device=true}
local function envelope(t, allowed)
    if type(t)~="table" or getmetatable(t)~=nil then return false end
    local n=0
    for k,v in pairs(t) do
        n=n+1
        if n>12 or not allowed[k] then return false end
        if type(v)=="string" then
            if not P.token(v) then return false end
        elseif type(v)~="boolean" and (type(v)~="number" or v~=v or math.abs(v)==math.huge) then
            return false
        end
    end
    return true
end
local function identity(t)
    return t.protocolVersion==P.version and P.token(t.clientNonce) and P.id(t.itemID)
end
function P.request(t) return envelope(t,base) and identity(t) end
function P.result(t)
    local allowed={}
    for k in pairs(reply) do allowed[k]=true end
    if type(t)=="table" and t.status=="observed" then
        for k in pairs(fields) do allowed[k]=true end
    end
    if not envelope(t,allowed) or not identity(t) or not P.time(t.serverNowMs)
        or not statuses[t.status] then return false end
    if t.status~="observed" then return true end
    return t.fullType==P.radio and type(t.turnedOn)=="boolean"
        and type(t.batteryPowered)=="boolean" and type(t.power)=="number"
        and t.power==t.power and t.power>=0 and t.power<=1
        and P.integer(t.channel,0,2147483647)
end
function P.copy(t)
    local result={}; for k,v in pairs(t) do result[k]=v end; return result
end
-- Bounded, direct personal inventory only. No nested/world inventory traversal.
function P.lookup(player,id)
    if not player or player:isDead() then return nil,"dead" end
    local inventory=player:getInventory()
    if not inventory then return nil,"not_owned" end
    local items=inventory:getItems()
    if not items or not P.integer(items:size(),0,1024) then return nil,"inventory_limit" end
    local item=inventory:getItemWithID(id)
    if not item or item:getContainer()~=inventory or item:getID()~=id then return nil,"not_owned" end
    if item:getFullType()~=P.radio then return nil,"wrong_type" end
    return item,nil,inventory
end
return P
