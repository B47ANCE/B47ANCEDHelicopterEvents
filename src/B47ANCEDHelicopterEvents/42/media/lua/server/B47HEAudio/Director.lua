local C = require "B47HEAudio/Config"
local P = require "B47HEAudio/Protocol"
local Director = {}

function Director.new(env)
    local s = { revision=1, configRevision=1, serial=0, subscribers={}, members={},
        config={enabled=false}, halted=false }
    local function snapshot(nonce, now)
        local t = {protocolVersion=P.version, clientNonce=nonce, serverEpoch=s.epoch,
            snapshotRevision=s.revision, configRevision=s.configRevision,
            serverNowMs=now, enabled=s.config.enabled, hasFlight=s.active ~= nil}
        if s.active then for k, v in pairs(s.active) do t[k] = v end end
        return t
    end
    local function send(player, sub, now)
        local t = snapshot(sub.nonce, now)
        if P.snapshot(t) then env.send(player, t) end
    end
    function s.shutdown()
        s.active, s.due, s.halted = nil, nil, true
        s.config = {enabled=false}
        s.revision = s.revision + 1
        -- Clients also enforce heartbeat loss and immutable absolute expiry.
    end
    function s.update()
        if s.halted then return end
        local now = env.now()
        if not C.integer(now, 1, 9007199254740991) or (s.last and now < s.last) then
            s.shutdown(); return
        end
        if s.last and now - s.last < 1000 then return end
        s.last = now
        if not s.epoch then
            local wall = env.wall()
            if not C.integer(wall, 1, 9007199254740991) then s.shutdown(); return end
            s.epoch = string.format("%.0f_%.0f", wall, now)
        end
        local changed = false
        local config = C.read(env.vars())
        if not env.dedicated() then config.enabled = false end
        if config.enabled ~= s.config.enabled or config.interval ~= s.config.interval
            or config.duration ~= s.config.duration or config.valid ~= s.config.valid then
            s.config, s.configRevision = config, s.configRevision + 1
            changed = true
            -- New interval applies to the next opportunity; never rewrite an active deadline.
            s.due = nil
        end
        local players, members = env.players(), {}
        for _, player in ipairs(players) do members[player] = true end
        s.members = members
        for player in pairs(s.subscribers) do
            if not members[player] then s.subscribers[player] = nil end
        end
        if s.active and (not config.enabled or now >= s.active.expiresMs) then
            s.active, changed = nil, true
        end
        local hours = env.hours()
        if not C.finite(hours) or hours < 0 or (s.hours and hours < s.hours) then
            s.shutdown(); return
        end
        s.hours = hours
        if not config.enabled then s.due = nil
        elseif #players > 0 then
            if not s.due then s.due = hours + config.interval * 24 end
            if not s.active and hours >= s.due then
                local anchor = players[1]
                local x, y = env.position(anchor)
                if C.finite(x) and C.finite(y) and math.abs(x) < 999800 and math.abs(y) < 999800 then
                    s.serial = s.serial + 1
                    s.active = {eventId=tostring(s.serial), soundId=P.sound,
                        startMs=now, expiresMs=now+config.duration*1000,
                        x0=x-60, y0=y, z0=0, x1=x+60, y1=y, z1=0}
                    changed = true
                end
                s.due = hours + config.interval * 24
            end
        elseif s.due and hours >= s.due then
            s.due = hours -- retain just one overdue opportunity
        end
        if changed then s.revision = s.revision + 1 end
        if changed or (s.active and (not s.lastPush or now-s.lastPush >= 2000)) then
            for player, sub in pairs(s.subscribers) do send(player, sub, now) end
            s.lastPush = now
        end
        if s.revision >= 2147483646 or s.configRevision >= 2147483646 then s.shutdown() end
    end
    function s.command(module, command, player, args)
        if s.halted or module ~= P.module or command ~= "SyncRequest" or not s.epoch
            or not s.members[player] then return end
        local now, sub = env.now(), s.subscribers[player]
        if not C.finite(now) or now < s.last or (sub and now-sub.lastRequest < 2000) then return end
        -- Rate-limit malformed requests too, before inspecting the table.
        if not sub then sub = {}; s.subscribers[player] = sub end
        sub.lastRequest = now
        if not P.request(args) then return end
        sub.nonce = args.clientNonce
        send(player, sub, now)
    end
    return s
end

-- Headless adapter. No client module, camera, sound or world-square dependency.
if isServer and isServer() then
    local instance
    local env = {
        now=function() return GameTime.getServerTimeMills() end,
        wall=function() return getTimestampMs() end,
        hours=function() return getGameTime():getWorldAgeHours() end,
        vars=function() return SandboxVars end,
        dedicated=function() return getCore():isDedicated() end,
        players=function()
            local result, list = {}, getOnlinePlayers()
            for i=0,list:size()-1 do
                local player = list:get(i)
                if player and not player:isDead() then result[#result+1] = player end
            end
            return result
        end,
        position=function(player) return player:getX(), player:getY() end,
        send=function(player, args) sendServerCommand(player, P.module, "Snapshot", args) end
    }
    local function guarded(fn, ...)
        local ok = pcall(fn, ...)
        if not ok then
            if instance then instance.shutdown() end
            print("[B47HEAudio] Server adapter stopped; API/runtime validation required.")
        end
    end
    Events.OnServerStarted.Add(function()
        guarded(function()
            instance = Director.new(env)
            if not env.dedicated() then
                print("[B47HEAudio] Dedicated MP prototype: hosted playback unsupported and silent.")
            end
        end)
    end)
    Events.OnTick.Add(function() if instance then guarded(instance.update) end end)
    Events.OnClientCommand.Add(function(...) if instance then guarded(instance.command, ...) end end)
end

return Director
