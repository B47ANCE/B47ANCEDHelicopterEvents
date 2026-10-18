local P=require "B47HEWreckProbe/Protocol"
function wreckFixture()
    local e={time=100000,on=true,near=true,dedicatedFlag=true,assets=true,squares={},sent={},creates=0,adds=0,publishes=0}
    local function list(items)
        return {size=function() return #items end,get=function(_,i) return items[i+1] end}
    end
    e.list=list
    e.player={dead=false,admin=true,x=P.x+10,y=P.y,z=P.z}
    local p=e.player
    function p:isAccessLevel(level) assert(level=="admin");return self.admin end
    function p:isDead() return self.dead end
    function p:getX() return self.x end;function p:getY() return self.y end;function p:getZ() return self.z end
    for x=P.x-P.radius,P.x+P.radius do for y=P.y-P.radius,P.y+P.radius do
        local q={floor={},chunk={},outside=true,items={},special={},world={},moving={},static={}}
        q.items={q.floor}
        function q:getChunk() return self.chunk end;function q:getFloor() return self.floor end
        function q:isOutside() return self.outside end;function q:getRoom() return self.room end
        function q:getBuilding() return self.building end;function q:isSolid() return self.solid or false end
        function q:isSolidTrans() return self.solidtrans or false end
        function q:getObjects() return list(self.items) end
        function q:getSpecialObjects() return list(self.special) end;function q:getWorldObjects() return list(self.world) end
        function q:getMovingObjects() return list(self.moving) end;function q:getStaticMovingObjects() return list(self.static) end
        function q:AddTileObject(o)
            e.adds=e.adds+1;assert(o.model==P.placement and o.square==self)
            self.items[#self.items+1]=o
            if e.addFault then error("injected partial insertion failure") end
        end
        e.squares[x..":"..y]=q
    end end
    e.square=function(x,y,z) assert(z==0);return e.squares[x..":"..y] end
    e.anchor=e.square(P.x,P.y,P.z)
    e.now=function() return e.time end;e.dedicated=function() return e.dedicatedFlag end
    e.enabled=function() return e.on end;e.assetsReady=function() e.assetReads=(e.assetReads or 0)+1;return e.assets end
    e.send=function(player,args) assert(player==p and P.result(args));e.sent[#e.sent+1]=args end
    e.create=function(square)
        e.creates=e.creates+1
        if e.createFault then error("injected construction failure") end
        local o={square=square,sprite={}}
        function o:getSquare() return self.square end;function o:getSprite() return self.sprite end
        function o:getContainer() return nil end
        function o:setSpriteModelName(name) self.model=name;if e.duringCreate then e.duringCreate(self) end end
        function o:getSpriteModel() if not e.definitionMissing then return {name=self.model} end end
        function o:transmitCompleteItemToClients()
            e.publishes=e.publishes+1
            if e.publishFault then error("injected publication failure") end
        end
        return o
    end
    return e
end
