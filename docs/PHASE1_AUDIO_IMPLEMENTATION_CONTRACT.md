# Phase 1 audio prototype implementation contract

## Implementation status - 2026-10-15

PR #2 was reviewed and merged; the user separately authorized the bounded implementation on 2026-10-15 at 0.1.0-dev.3. See [actual implementation, scope and limitations](AUDIO_PROTOTYPE.md). The contract body below is preserved as the merged preimplementation design, including its then-pending approval/version language. This request authorizes code/offline checks/PR only, no game/server launch, deployment or publication. Runtime gates remain NOT TESTED.

Prepared 2026-10-14 for review. **DESIGN ONLY - IMPLEMENTATION NOT AUTHORIZED.** Current project version: root VERSION. Source baseline: merged PR #1, commit 17454de4b3c75d70288932968a1217760101ca76. Target: Project Zomboid Build 42.21, dedicated-server first. Source feasibility is CONDITIONAL; every runtime gate is NOT TESTED.

This is the bounded **Phase 1 audio track**, not the original Phase 1 wreck prototype. Preparing or merging this contract does not authorize coding, assets, launching PZ/server, installation, packaging, deployment, Workshop publication or a stable release. A separate implementation request is required. Full-crash B01-B12 blockers remain in force.

## 1. Deliverable and explicit exclusions

A later authorized slice may implement one transient server-scheduled flyover consisting of one continuous positional rotor bed. Maximum one active flight per server process and one owned emitter per physical client. Server owns the route, timing and configuration; clients render local audio only. Missing capability, unsafe time or failed audio start means silence, not a fallback gameplay effect.

Excluded: wrecks/world objects, impact materialization, terrain/building destruction, decals/trails, fire/smoke, bodies/NPCs, loot/cargo, salvage, inventory changes, zombie attraction, AI/world sounds, airborne models, actual flight physics, distress/impact sequences, aircraft-family expansion, persistent crash/event registries, migrations and new assets. No native vanilla helicopter scheduling, singleton, packets or sandbox setting is replaced or monkey-patched. No custom Java/JAR/bridge/agent/injected class/native extension may be built, shipped or required.

Distress is deliberately deferred from the broader Phase 0 candidate: it introduces asset/intro/seek behavior unnecessary for proving one safe local emitter lifecycle. Do not expose DistressChancePercent or another inactive feature option in this prototype. Do not imply that hearing this prototype creates a discoverable crash.

## 2. Source-backed assumptions and mandatory stops

Use [AUDIO_API_EVIDENCE.md](AUDIO_API_EVIDENCE.md) and [AUDIO_FEASIBILITY.md](AUDIO_FEASIBILITY.md) as the API/evidence baseline. Native inspection is not a runtime approval.

| Requirement | Candidate / stop condition |
|---|---|
| Client-only playback | Exposed playSoundImpl(String,boolean,IsoObject). Verify the exact three-argument Lua call; never substitute ordinary playSound/playSoundLooped, which can send native sound packets. setPlayRemoteEvents(false) is not a transport guard. |
| Ownership | getWorld():getFreeEmitter(x,y,z), takeOwnershipOfEmitter, setPos, tick, local stop and returnOwnershipOfEmitter. Stop the affected adapter if an overload/lifetime cannot be established safely. |
| Sound | One allowlisted existing-game rotor candidate, initially Helicopter/Meta/Helicopter. No asset changes. Confirm that the clip can supply a suitable continuous bed and stop cleanly through this exposed path; function names do not force looping. If unusable, stop and report the asset limitation. |
| Time | GameTime.getServerTimeMills() and getServerTimeShiftIsSet() for MP. Zero/unsynchronized/unsafe time stays silent. Do not call the test-only shift setter. Verify synchronization readiness for the current connection; a possibly cached prior-session flag alone is insufficient. |
| Readiness/transport | Exposed sendClientCommand/sendServerCommand with OnClientCommand/OnServerCommand. OnConnected resets state only. A normal in-game tick, valid local player and current synchronized time precede the handshake. |
| Headless execution | Server/shared modules must never acquire/tick emitters, inspect client cameras or require client-only code. No FMOD/native call from mod code. |

Native high-z helicopter positioning and occlusion are not reproduced by this contract. The initial diagnostic route uses a common server-defined z=0 position and ordinary vanilla emitter acoustics. Upper-floor/indoor attenuation and split-screen listening are runtime acceptance tests, not promised aviation realism. No high-z workaround or direct FMOD call is allowed.

The current installation contains patched classes; retain clean and patched test results separately. A code change may be prepared offline only after separate authorization. An unsuccessful or ambiguous live diagnostic blocks the next slice; it never justifies client authority, world mutation or Java substitution.

## 3. Proposed implementation surface - do not create it now

No runtime source tree or mod.info currently exists. Confirm the proposed Mod ID B47ANCEDHelicopterEvents when authorizing implementation. The bounded future source proposal is:

| Future path under src/B47ANCEDHelicopterEvents/42/ | Responsibility |
|---|---|
| mod.info | Prototype identity and supported game metadata, synchronized with root VERSION; no Java or third-party runtime dependency. |
| media/sandbox-options.txt | Only the three supported sandbox options below. |
| media/lua/shared/B47HEAudio/Config.lua | Pure validation/interpretation; no client gameplay preferences or engine side effects at require time. |
| media/lua/shared/B47HEAudio/Protocol.lua | Flat scalar envelope validation and sequence rules; no emitter calls or scheduling authority. |
| media/lua/server/B47HEAudio/Director.lua | Single-flight server state, bounded scheduling, ready-player table and snapshots. |
| media/lua/client/B47HEAudio/Playback.lua | One client manager: readiness, snapshot state, owned emitter and cleanup. |
| media/lua/shared/Translate/<language>/Sandbox.json | Installed-game-compatible localized names/tooltips/page with documented English fallback coverage. |

Case-correct require names such as B47HEAudio/Protocol must match filenames on Linux. Existing native mod metadata/translation conventions must be checked rather than inventing fields. No unrelated refactoring or framework changes. Offline fake-engine tests may be added under tests/audio for protocol, server transitions and emitter-call ownership only after implementation authorization; they cannot prove native behavior.

## 4. Sandbox contract and bounded scheduler

Proposed namespace B47HE; no definitions exist yet. These Phase 1 choices supersede only the broader candidate's provisional defaults for this prototype.

| ID | Default / supported values | Required interpretation |
|---|---|---|
| B47HE.EnableAudioFlights | false; boolean | Explicit opt-in diagnostic prototype. False prevents schedules and cancels an active flight. Invalid/missing configuration fails closed; native initialized defaults are used only when actually available. |
| B47HE.FlightIntervalDays | 14; integer 1-365 | In-game days between future schedules, never a client preference. First due time is established when valid configuration and an eligible server player are present. No accumulated missed-flight burst. |
| B47HE.FlightDurationSeconds | 60; integer 10-180 | Real-time length of a newly resolved descriptor. Reception, pause or game speed cannot extend it. Existing active timing remains immutable. |

Provide meaningful localized names/tooltips/grouping; validate types, finite numbers, integers and bounds server-side. Engine rejection/retain behavior is not assumed to be clamping. Disabling takes effect on the next bounded server configuration check and produces a newer empty snapshot. Other changes apply to future flights. Native server settings remain authoritative; stock volume/mute/accessibility controls still apply locally.

The server keeps one IDLE/ACTIVE state and a next-due world-age value in memory. At the due time, choose an eligible player from the server's current online-player list as the route anchor; no client-supplied anchor, camera or visibility report. No eligible player means defer one due opportunity; when players return, schedule once, not a backlog. A fixed straight 120-tile eastbound route at z=0 is an internal diagnostic fixture, not a claimed aircraft balance model. If it becomes a production balance surface, reassess sandbox configuration before expansion. Validate finite anchor/path values; never load/generate world squares to play sound.

Internal bounds: one flight/emitter, protocol version, payload/string limits, finite-coordinate checks, bounded retry/work budgets and fixture geometry. These are technical/prototype constraints, not hidden configurable gameplay tables. Server configuration/eligibility checks occur at most once per real second; a lightweight lifecycle callback may check its clock each tick. No map/chunk/inventory scans or permanent per-event loops after cleanup.

## 5. Snapshot protocol - no client outcome commands

Proposed module B47HEAudio; protocolVersion 1 is independent of project SemVer. Use only flat scalar tables supported by native command serialization, not arbitrary nested/cyclic data. Reject unknown fields/types, nonfinite or unsafe numeric values, oversized messages and unrecognized sound IDs. Cap each envelope at 24 fields, each token at 64 ASCII characters and the serialized payload at 4 KiB using a verified size/check mechanism; no custom fragmentation. If exact native byte measurement is unavailable, enforce a conservative scalar/string budget that demonstrably stays below the byte cap. These limits remain implementation-only.

Only client command: SyncRequest(protocolVersion, clientNonce). The nonce correlates the current local connection handshake; it grants no permissions or event ownership. Server validates the actual connection-associated player supplied by OnClientCommand, current membership and argument bounds. No force-start, set-config, choose-route, play-sound or change-outcome command. Reject or ignore those requests without state changes.

Only server command: Snapshot. Use a full authoritative state, not START/CANCEL delta replay. Required scalars: protocolVersion, echoed clientNonce, serverEpoch, snapshotRevision, configRevision, serverNowMs, enabled and hasFlight. If hasFlight is true, include eventId, soundId, startMs, expiresMs, x0,y0,z0,x1,y1,z1. If false, omit all flight fields. Do not include player identities or inventories. soundId is a fixed allowlist key, not a sound path supplied by a client. Native sandbox synchronization remains separate; the server's resolved snapshot is what authorizes this presentation state.

Within one server epoch, increment snapshotRevision for every semantic transition, including expiry, disable and an empty state. Equal revisions may refresh serverNowMs but may not change the descriptor or restart/extend audio. Lower revisions are ignored. A newer empty snapshot is the cancellation watermark; a late active snapshot cannot undo it. One global high-water revision suffices for this one-flight scope; do not build an unbounded event history.

Server epoch is a new ephemeral process/session token; event IDs are server allocated within it. Select/verify the epoch mechanism using exposed APIs during the authorized implementation; no global or crash-durable uniqueness claim is required. Bind epoch acceptance to the current validated handshake response. An unsolicited different-epoch push must not reset the client. No persistence, world modData or client-writable receipt is an authority store.

Maintain ready subscriptions keyed by actual current player objects and nonce, not a username/online-ID that may be reused after reconnect. Prune disconnected/replaced entries through the current server player set at the bounded check. Send only to validated ready subscribers using the exposed player-targeted send. Multiple local slots may share one physical connection; client-side epoch/revision deduplication is mandatory. Keep this collection bounded by actual online players.

Proposed technical request limit: at most one accepted sync per player per two real seconds, with no event/schedule side effects; return current or empty state, never history. Client sends a handshake only after readiness, retries at most three times with backoff, then remains silent. An explicit reconnect/new local session may reset that retry budget. Push snapshots on semantic changes and at most once per two real seconds while active; repeated pushes never renew expiry. Do not run idle broadcast loops or let request floods multiply work without bound.

## 6. Playback, expiry and cleanup state machine

Client states: SILENT/WAITING_READY/WAITING_SNAPSHOT/PLAYING. OnConnected clears the old nonce/epoch/sequence state and cleans up old audio; it does not request playback immediately. Wait for normal in-game readiness and current-connection time synchronization. If those cannot be established, stay silent. A malformed current session/descriptor must not allocate sound; ambiguity triggers cleanup and only bounded resynchronization.

Use the synchronized server deadline in MP. Require startMs <= expiresMs, duration within configured/technical supported bounds and a nonexpired current time. Reject excessive future lead times rather than playing early. Interpolate the current position from immutable endpoints and elapsed server time, clamped to the resolved interval. Do not use client receipt time, world-age hours or local wall clock to restart/extend flight lifetime. Regressing/unsafe clock state stops playback. Never invoke native clock-test setters.

For a valid active snapshot, acquire and immediately take ownership of one emitter, then call only the source-backed local Impl overload. Treat nil/zero handle, unavailable sound/listener or disabled sound as a failed start; clean up, with no per-tick retry storm. No direct native FMOD, world sound, ordinary rebroadcasting play wrapper or vanilla helicopter instance calls.

One lifecycle function owns position/tick/stop/return operations. Do not tick independently through multiple event callbacks or through the native world after ownership transfer. OnTickEvenPaused may drive the watchdog/cleanup but must not double-advance or create new flight audio. Verify its ordering and guard against duplicate/reentrant updates. OnDisconnect, OnMainMenuEnter, expiry, disable, error and local session replacement perform idempotent cleanup without waiting for a later normal world tick.

Cleanup uses the recorded handle's local stop; stopAll is limited to this exclusively owned emitter. Drain only bounded work, return ownership exactly once, clear handle/reference/state and never touch the returned emitter. Native return may hand a nonempty tail back to world management; that is not proof that audible playback has stopped. Record and test actual stop-tail/resource behavior; failure to bound it blocks the prototype. Never use a global stop-all-sounds fallback.

Late join/reconnect may attach only the continuous rotor bed at the current route position with the original expiry. Do not replay an approach/intro or use numeric seeking with setTimelinePosition(long,String), which is a marker API. If the selected sound cannot begin as an acceptable continuous bed mid-flight, stay silent for that flight and report the asset limitation. Do not promise sample-phase synchronization. One logical event has one emitter per physical client, regardless of split-screen slot/packet count; native listener mixing is a dedicated test gate.

## 7. Restart, save and platform boundaries

Persist nothing for active audio: no GlobalModData, world-object metadata, per-client save receipts, cargo transactions or replay log. Server process restart cancels prior flights, changes epoch and establishes a new next-due schedule from current valid config/world time. No catch-up/reconstruction. Client restart discards all playback state and requires a new handshake. Disable/re-enable does not resume a previously cancelled event. This deliberately does not promise long-term cadence continuity or exactly-once sound across crashes.

Dedicated MP is the initial engine diagnostic target; it must be headless-safe. SP/locally hosted compatibility is not silently claimed or permanently abandoned: SP requires its own local dispatcher and expiry clock because the inspected MP globals do not supply them. Until a separate bounded SP/host validation is approved, those modes must remain silent with a clear developer diagnostic, not silently execute a broken MP path. No client authority or extra runtime dependency as fallback.

## 8. Offline deliverables and later operator tests

After separate implementation authorization, require meaningful fake-boundary tests for malformed/oversized scalar payloads, readiness and current-session correlation, monotonic revisions/empty cancellation, expired/unsynchronized clocks, immutable deadlines, duplicate split-screen deliveries, server-only scheduling/config validation, bounded retries/collections, and emitter call ordering (acquire/take/play/tick/local-stop/return exactly once). Fakes must verify absence of forbidden network/world/inventory/attraction calls. Do not report mocked audio or storage as engine proof.

Run version/syntax/require-case/localization checks with the game's compatible Lua tooling once source exists. Current commands validate documents only:

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
git diff --check
```

The [A-R01 through A-R12 dedicated plan](RUNTIME_TEST_PLAN.md) remains NOT TESTED. For this narrower prototype, apply those cases to the three active settings and rotor-only behavior. Distress/seek subcases are deferred scope, not a PASS or manufactured N/A for the complete future feature. Clean and patched clients/server results remain separate. Require at least two clients, late join/rejoin, split-screen, pause/menu cleanup, loss/duplicate/stale snapshots, admin disable, server restart, wrong/missing settings, no unintended native sound sends, no zombie attraction and prolonged bounded-resource behavior. SP/host/Linux claims require their actual separate environments.

## 9. Approval, version and stop gates

This document stays at the existing documentation version; no runtime implementation or compatibility change occurred. A later first audio implementation is a new prerelease checkpoint: **proposed target 0.1.0-dev.3**, compatible additive work relative to documentation with no existing runtime saves/API to migrate. Do not change VERSION or create mirrors now; confirm that target and inventory all actual metadata before the authorized coding slice. Project, protocol and PZ build versions remain separate.

| Gate | Required state |
|---|---|
| Contract review | PENDING. Merging documentation is not authorization to implement. |
| Implementation request | Separate explicit user request; still no launch/deploy/publish permission. |
| Source/API failure | Stop affected slice and document the Lua-only limitation. No fabricated signature, client-authority fallback, custom Java or hidden widening of scope. |
| Offline checks | Required for any later code change; passing them does not prove emitter/network/acoustic behavior. |
| G6 / SP | NOT TESTED; separate clock/dispatcher and environment evidence required for compatibility claims. |
| G7 | BLOCKED / NOT TESTED until required actual dedicated evidence passes. This coordinated server/client prototype does not use G7 N/A. |
| Stable-release G8 | BLOCKED. No stable tag, package, release-readiness claim or publication from this contract. |

Stop before adding distress, new assets, persistent event continuity, multiple concurrent flights, additional aircraft, gameplay/world effects or an operator force-event network command. Any such request needs a new bounded contract and authority/config/evidence review. The original wreck/destruction/loot/salvage scope remains outside this track.
