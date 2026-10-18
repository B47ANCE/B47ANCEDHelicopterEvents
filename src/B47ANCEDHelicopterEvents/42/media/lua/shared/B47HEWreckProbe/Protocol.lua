-- Fixed diagnostic fixture, not configurable crash scheduling or a site identity protocol.
local P={module="B47HEWreckProbe",version=1,x=8871,y=8253,z=0,radius=8,
    model="B47HE.WreckProbeUpright",placement="B47HE.WreckProbeUprightPlacement",
    mesh="B47HE/wreck_probe_upright.glb",
    texture="media/textures/B47HE/wreck_probe_upright.png",
    fallback="media/ui/B47_ICON_SMALL.png",objectName="B47HE Decorative Wreck Probe"}
local statuses={disabled=true,unavailable=true,not_nearby=true,assets_missing=true,
    not_loaded=true,not_clear=true,changed=true,attempted=true,published=true}
function P.time(n) return type(n)=="number" and n==n and n>0 and n<9007199254740991 end
local function exact(t,allowed,count)
    if type(t)~="table" or getmetatable(t) then return false end
    local n=0
    for k in pairs(t) do n=n+1; if n>count or not allowed[k] then return false end end
    return n==count
end
local function nonce(n) return type(n)=="string" and #n>0 and #n<=48 and n:match("^[%w_]+$")~=nil end
function P.request(t)
    return exact(t,{protocolVersion=true,clientNonce=true,sentAtMs=true},3)
        and t.protocolVersion==P.version and nonce(t.clientNonce) and P.time(t.sentAtMs)
end
function P.result(t)
    return exact(t,{protocolVersion=true,clientNonce=true,status=true},3)
        and t.protocolVersion==P.version and nonce(t.clientNonce) and statuses[t.status]==true
end
return P
