local C = require "B47HEAudio/Config"
local P = { module = "B47HEAudio", version = 1, sound = "rotor" }
local base = { protocolVersion=true, clientNonce=true, serverEpoch=true, snapshotRevision=true,
    configRevision=true, serverNowMs=true, enabled=true, hasFlight=true }
local flight = { eventId=true, soundId=true, startMs=true, expiresMs=true,
    x0=true, y0=true, z0=true, x1=true, y1=true, z1=true }

function P.token(v)
    return type(v) == "string" and #v >= 1 and #v <= 64 and not v:find("[^A-Za-z0-9_%-]")
end

-- At most 24 ASCII keys/values <=64 bytes each, booleans or doubles. TableNetworkUtils
-- scalar encoding adds <32 bytes per entry: <24*(64+64+32)+32=3872 bytes.
-- Reject nested tables before doing any recursive work; stop enumeration at the cap.
local function envelope(t, allowed)
    if type(t) ~= "table" or getmetatable(t) ~= nil then return false end
    local n = 0
    for k, v in pairs(t) do
        n = n + 1
        if n > 24 or type(k) ~= "string" or #k > 64 or not allowed[k] then return false end
        if type(v) == "string" then
            if not P.token(v) then return false end
        elseif type(v) ~= "boolean" and not C.finite(v) then return false end
    end
    return true
end

function P.request(t)
    return envelope(t, {protocolVersion=true, clientNonce=true})
        and t.protocolVersion == P.version and P.token(t.clientNonce)
end

function P.snapshot(t)
    local allowed = {}
    for k in pairs(base) do allowed[k] = true end
    if type(t) == "table" and t.hasFlight == true then
        for k in pairs(flight) do allowed[k] = true end
    end
    if not envelope(t, allowed) then return false end
    for k in pairs(base) do if t[k] == nil then return false end end
    if t.protocolVersion ~= P.version or not P.token(t.clientNonce) or not P.token(t.serverEpoch)
        or not C.integer(t.snapshotRevision, 1, 2147483647)
        or not C.integer(t.configRevision, 1, 2147483647)
        or not C.integer(t.serverNowMs, 1, 9007199254740991)
        or type(t.enabled) ~= "boolean" or type(t.hasFlight) ~= "boolean" then return false end
    if not t.hasFlight then return true end
    if not t.enabled or not P.token(t.eventId) or t.soundId ~= P.sound
        or not C.integer(t.startMs, 1, 9007199254740991)
        or not C.integer(t.expiresMs, 1, 9007199254740991)
        or t.expiresMs - t.startMs < 10000 or t.expiresMs - t.startMs > 180000 then return false end
    for _, k in ipairs({"x0","y0","z0","x1","y1","z1"}) do
        if not C.finite(t[k]) or math.abs(t[k]) > 1000000 then return false end
    end
    return t.z0 == 0 and t.z1 == 0 and t.y0 == t.y1 and t.x1 - t.x0 == 120
end

function P.same(a, b)
    for k in pairs(base) do
        if k ~= "serverNowMs" and a[k] ~= b[k] then return false end
    end
    for k in pairs(flight) do if a[k] ~= b[k] then return false end end
    return true
end

function P.copy(t)
    local result = {}
    for k, v in pairs(t) do result[k] = v end
    return result
end

return P
