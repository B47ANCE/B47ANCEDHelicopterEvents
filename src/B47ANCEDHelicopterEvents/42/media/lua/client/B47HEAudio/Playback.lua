local C = require "B47HEAudio/Config"
local P = require "B47HEAudio/Protocol"
local Playback = {}
local sessionSerial = 0
local audioBlocked = false -- cleanup ambiguity survives reconnect until a process/module restart

function Playback.new(env)
    local s = { state="WAITING_READY", attempts=0, revision=0, normalReady=false }
    local function cleanup()
        local emitter, world, handle, owned = s.emitter, s.world, s.handle, s.owned
        s.emitter, s.world, s.handle, s.owned = nil, nil, nil, nil
        if not emitter then return end
        if not owned then
            audioBlocked, s.blocked = true, true
            env.log("Emitter ownership ambiguous; audio blocked until process restart.")
            return -- no sound was started; do not return a possibly world-owned emitter twice
        end
        -- All references are exclusively ours. Bounded drain; never touch after return.
        local stopped = pcall(function() if handle then emitter:stopSoundLocal(handle) end end)
        local drained = pcall(function()
            emitter:stopAll()
            emitter:tick()
        end)
        local returned = pcall(function() world:returnOwnershipOfEmitter(emitter) end)
        if not stopped or not drained or not returned then
            audioBlocked, s.blocked = true, true
            env.log("Emitter cleanup failed; further audio blocked for this manager.")
        end
    end
    function s.close()
        cleanup()
        s.state, s.descriptor, s.snapshot = "SILENT", nil, nil
    end
    local function fail()
        s.close()
        s.failed = true -- no retry storm; a new connection gets a fresh manager
    end
    local function clock()
        if not env.synced() then return nil end
        local now = env.now()
        if not C.integer(now, 1, 9007199254740991) or (s.lastClock and now < s.lastClock) then return nil end
        s.lastClock = now
        return now
    end
    function s.receive(module, command, args)
        if s.failed or not s.nonce or module ~= P.module or command ~= "Snapshot" then return end
        if not P.snapshot(args) then fail(); return end
        if args.clientNonce ~= s.nonce then return end -- stale connection response
        local now = clock()
        -- A nonce-bound fresh server sample is also required; a cached shift flag alone
        -- cannot authorize playback. Slow delivery/skew >2s fails silent, not local retiming.
        if not now or math.abs(now-args.serverNowMs) > 2000 then fail(); return end
        if s.epoch and args.serverEpoch ~= s.epoch then return end
        if args.snapshotRevision < s.revision then return end
        if args.snapshotRevision == s.revision then
            if not s.snapshot or not P.same(s.snapshot, args) then fail(); return end
            s.lastSnapshot = now
            return
        end
        if s.epoch and args.configRevision < s.snapshot.configRevision then fail(); return end
        if args.hasFlight and (args.startMs > now or args.expiresMs <= now) then
            -- Preserve the watermark even when delayed delivery is already expired.
            if args.startMs > now then fail(); return end
        end
        if s.descriptor and args.hasFlight and args.eventId == s.descriptor.eventId then
            for _, k in ipairs({"soundId","startMs","expiresMs","x0","y0","z0","x1","y1","z1"}) do
                if args[k] ~= s.descriptor[k] then fail(); return end
            end
        end
        s.epoch, s.revision, s.lastSnapshot = args.serverEpoch, args.snapshotRevision, now
        s.snapshot = P.copy(args)
        if not args.hasFlight or args.expiresMs <= now then
            cleanup(); s.descriptor, s.state = nil, "SILENT"
        else
            if s.descriptor and args.eventId ~= s.descriptor.eventId then cleanup() end
            s.descriptor, s.state = P.copy(args), "PLAYING"
        end
    end
    function s.update(normalTick)
        if s.failed or s.blocked or audioBlocked or not env.ready() then
            if s.emitter then cleanup() end
            return
        end
        if normalTick then s.normalReady = true end
        if not s.normalReady then return end
        local now = clock()
        if not now then
            if s.nonce then fail() end
            return
        end
        if not s.nonce then
            if not normalTick then return end
            sessionSerial = sessionSerial + 1
            local wall = env.wall()
            if not C.integer(wall, 1, 9007199254740991) then fail(); return end
            s.nonce = string.format("%.0f_%d", wall, sessionSerial)
            s.state = "WAITING_SNAPSHOT"
        end
        if not s.epoch and normalTick then
            if not s.nextRequest or now >= s.nextRequest then
                if s.attempts >= 3 then fail(); return end
                s.attempts = s.attempts + 1
                s.nextRequest = now + 2000 * (2 ^ (s.attempts-1))
                env.request({protocolVersion=P.version, clientNonce=s.nonce})
            end
            return
        end
        local d = s.descriptor
        if not d then return end
        if now >= d.expiresMs or now-s.lastSnapshot > 6000 then
            cleanup(); s.descriptor, s.state = nil, "SILENT"; return
        end
        local alpha = math.max(0, math.min(1, (now-d.startMs)/(d.expiresMs-d.startMs)))
        local x, y, z = d.x0+(d.x1-d.x0)*alpha, d.y0, d.z0
        if not s.emitter then
            if not normalTick or s.attempted == d.eventId then return end
            s.attempted = d.eventId -- even failure/mute never restarts this flight
            local ok = pcall(function()
                s.world = env.world()
                s.emitter = s.world:getFreeEmitter(x, y, z)
                if not s.emitter then error("no emitter") end
                s.world:takeOwnershipOfEmitter(s.emitter)
                s.owned = true
                local handle = s.emitter:playSoundImpl("Helicopter", false, nil)
                if not C.finite(handle) or handle <= 0 then error("no handle") end
                s.handle = handle
            end)
            if not ok then fail(); return end
        end
        -- Paused callbacks only watchdog/cleanup; a normal tick is the sole tick owner.
        if normalTick then
            local ok = pcall(function()
                s.emitter:setPos(x, y, z)
                s.emitter:tick()
                if s.emitter:isEmpty() then cleanup() end
            end)
            if not ok then fail() end
        end
    end
    return s
end

if isClient and isClient() then
    local manager
    local env = {
        now=function() return GameTime.getServerTimeMills() end,
        synced=function() return GameTime.getServerTimeShiftIsSet() end,
        wall=function() return getTimestampMs() end,
        ready=function() return isClient() and getPlayer() ~= nil and not getPlayer():isDead() end,
        world=function() return getWorld() end,
        request=function(args) sendClientCommand(getPlayer(), P.module, "SyncRequest", args) end,
        log=function(message) print("[B47HEAudio] "..message) end
    }
    local function guarded(fn, ...)
        local ok = pcall(fn, ...)
        if not ok then
            if manager then manager.close(); manager.failed = true end
            env.log("Client adapter stopped; API/runtime validation required.")
        end
    end
    Events.OnConnected.Add(function()
        if manager then manager.close() end
        manager = Playback.new(env)
    end)
    local function close()
        if manager then manager.close(); manager = nil end
    end
    Events.OnDisconnect.Add(close)
    Events.OnMainMenuEnter.Add(close)
    Events.OnTick.Add(function() if manager then guarded(manager.update, true) end end)
    Events.OnTickEvenPaused.Add(function() if manager then guarded(manager.update, false) end end)
    Events.OnServerCommand.Add(function(...) if manager then guarded(manager.receive, ...) end end)
elseif isClient then
    print("[B47HEAudio] Dedicated MP prototype: SP playback unsupported and silent.")
end

return Playback
