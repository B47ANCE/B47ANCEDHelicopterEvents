# Phase 0 Lua-only audio feasibility

Reviewed 2026-10-14. Current project version: ../VERSION. Target: installed JAR Build 42.21. **CONDITIONAL source feasibility; runtime NOT TESTED.** Documentation only: no Phase 1, assets, implementation or launch authorization.

Current policy permits Lua calls to exposed vanilla engine APIs, not custom Java, bridges, agents, injected classes, native extensions or JAR dependencies. Native bytecode inspection supplies evidence only. Earlier engine-bridge proposals are historical and unavailable. The full crash/wreck/destruction scope remains blocked; an audio candidate does not silently satisfy or replace those requirements.

## Bounded candidate

Server-owned flyovers and distress presentation; no airborne model, wreck materialization, terrain/structure changes, fire, bodies, cargo, salvage, zombie-attracting world sounds or confirmed impact sounds. Do not promise a discoverable crash that does not exist. Preserve vanilla helicopter scheduling/singleton state. Sound and path identifiers are allowlisted server decisions, not client-supplied filenames or outcomes.

## Emitter lifecycle

Source-backed signatures and offsets are in [AUDIO_API_EVIDENCE.md](AUDIO_API_EVIDENCE.md).

Candidate client lifecycle: getWorld():getFreeEmitter(x,y,z), immediately takeOwnershipOfEmitter, create the local sound, retain its returned handle, update position and tick while owned, then stop/drain and returnOwnershipOfEmitter exactly once. The native world updates and recycles world-owned emitters. Once ownership is returned, discard the Lua reference and handle; never stop a recycled emitter through a stale reference. Explicit ownership avoids an auto-recycled emitter becoming another system's sound while Lua still retains it, but creates a duty to tick and clean it up.

The candidate local playback overload is playSoundImpl(String, boolean, IsoObject), avoiding two-argument nil ambiguity between square/object overloads. Its boolean is ignored in the inspected wrapper. **Do not use playSound/playSoundLooped for local-only presentation**: their client branches can send native sound packets. setPlayRemoteEvents(false) selects event behavior and does not suppress those wrapper sends. playSoundLoopedImpl's name is not proof of looping; the selected clip/event must establish loop behavior.

BaseSoundEmitter exposes setPos(float,float,float), tick(), isEmpty(), hasSoundsToStart(), isPlaying(long), stopSoundLocal(long) and stopAll(). Prefer per-handle local stop; stopAll is limited to an exclusively owned emitter. Test queued/not-yet-started playback, stop tails, silent/missing clips, zero handles, disabled sound, listeners and exceptions. Do not return twice or manually tick after return. A failed start must clean up without an unbounded retry loop. No custom finalizers or Java hooks.

OnDisconnect, OnMainMenuEnter, expiry, disable and error all require idempotent cleanup. OnTickEvenPaused is an available candidate for watchdog/cleanup while ordinary simulation ticks pause; event ordering and actual cleanup remain runtime gates. Do not wait for another normal in-game tick after leaving the world. If sound cannot be stopped/drained safely, the lifecycle is not approved.

The vanilla Helicopter sound references Meta/Helicopter, but native helicopter playback uses specialized FMOD positioning and occlusion. Ordinary emitter playback does not prove equivalent airborne acoustics or valid high-z positioning. Original sound assets remain a future asset decision; no sound was generated or shipped. Stop/playback/network isolation must also be checked in the patched installation, whose emitter implementation differs from the inspected JAR.

## Server sandbox authority

Native CustomSandboxOptions loads media/sandbox-options.txt from the selected version directory with common fallback. Server startup initializes custom options, loads server configuration and exports SandboxVars. ConnectionDetails writes the server's SandboxOptions; ConnectToServerState receives, applies and exports them to client SandboxVars. Native admin sandbox packets require Capability.SandboxOptions. Clients cannot set schedule/outcomes through the proposed mod protocol.

Proposed stable identifiers, not implemented definitions:

| ID | Type/default/bounds | Server interpretation and existing-save behavior |
|---|---|---|
| B47HE.EnableAudioFlights | boolean true | Enables future schedules. Disabling cancels active audio through a revisioned cancellation/snapshot; clients also retain a deadline watchdog. |
| B47HE.FlightIntervalDays | integer 14, 1-365 | In-game days for future scheduling; changing it affects the next schedule, not an already resolved event. |
| B47HE.FlightDurationSeconds | integer 60, 10-180 | Real seconds for newly resolved flight deadlines; not game-time-scaled duration. |
| B47HE.DistressChancePercent | integer 15, 0-100 | Server resolves future distress once; no crash outcome or zombie attraction. |

Integer bounds do not imply an unverified custom UI step feature. All IDs require localized names/tooltips and a grouped sandbox page in the installed game's supported translation format. Validate type, finite numeric values, integrality and range on the server. Missing/malformed config prevents new scheduling; do not assume the engine's reject/retain behavior equals clamping. Defaults apply through verified custom-option initialization. No player-edited Lua preferences own shared frequency or outcomes.

Settings revision and resolved duration/distress are carried with each descriptor. Disabling is an explicit cancel; other edits affect future flights. Audio-only active events are ephemeral and are discarded on process restart. Long-term cadence/save semantics are not implemented or approved. Concurrency/message-size/work limits, protocol versions and clock safety checks remain internal integrity constraints, not configurable micro-settings.

## Time and expiry

GameTime.getServerTimeMills() is the exact exposed spelling. It uses synchronized monotonic server time in MP, returns zero before client synchronization, and returns zero in SP. Require getServerTimeShiftIsSet() plus a valid positive time before MP playback; if time becomes invalid or makes an unsafe discontinuity, stop rather than extend the event. Never call the native test-only setServerTimeShift setter.

Server descriptors include session epoch, event ID, revision, issued/start/expiry server timestamps and resolved trajectory. Clients calculate current path position and remaining life from the absolute server deadline; reception, duplicates, snapshots or local pauses never extend it. Reject expired, inconsistent, excessively future-dated or invalid values and excessive duration/coordinates. No subtraction of client wall clock from server time. getTimestampMs is local wall time and is not a cross-machine synchronization mechanism.

SP requires a separate local-clock policy and validation; do not silently reuse the zero-returning MP clock. OnTickEvenPaused behavior, synchronization corrections and system pause/resume require dedicated tests. No durable exactly-once claim is needed or made for transient audio. Sample tail/loop timing remains an audible runtime gate even after descriptor expiry handling is correct in source/design.

## Ready handshake, reconnect and duplicate handling

OnConnected occurs during connection setup: clear old state there, do not immediately send a gameplay handshake. The global sendClientCommand wrapper tests GameClient.ingame. The inspected IngameState update calls UpdateStuff (sets ingame) before its ordinary OnTick. Wait for a normal in-game tick, a valid local player and synchronized time; request a bounded current-state snapshot with limited retries. If readiness cannot be established, remain silent.

Server OnClientCommand supplies the connection-associated player. The sole proposed client request is read-only current-state synchronization: authenticate, allowlist module/command, validate bounded args and rate-limit per actual connection/player. Ignore supplied desired outcomes, schedules, coordinates and settings. Server responses use exposed sendServerCommand. SP transport requires a separate local dispatcher: the inspected global sendServerCommand wrappers only send in server mode.

Use a server-process epoch and current handshake correlation so stale prior-session messages cannot reset current state. Accept an epoch change only through the valid current snapshot handshake. Within an epoch, event revisions include cancellation watermarks; a delayed START cannot undo a newer CANCEL. An empty authoritative snapshot clears local active audio. Expired history is not replayed.

Reconnect/late join may play only the still-active continuous rotor bed at the current trajectory position with remaining lifetime. Do not replay approach or distress introductions. Native setTimelinePosition(long,String) takes an authored marker name, not a numeric millisecond seek. Without a verified seekable asset, do not claim sample-phase synchronization. Silence is safer than restarting a transient late. Discard active flights at server restart; never reconstruct a previous epoch's flight from saved world state.

OnServerCommand has no local-player argument. Player-targeted sends can reach the same physical client through multiple split-screen slots; deduplicate by epoch/event ID/revision across the client and avoid an emitter per packet/player. One logical emitter relies on native listener handling, whose split-screen acoustic behavior must be tested. Retain bounded cancellation/sequence state long enough to reject stale packets, then clear it safely at expiry/session reset. No permanent per-flight tick loop after cleanup.

## Verdict and boundary

Emitter and command/sandbox APIs support a Lua-only candidate. End-to-end local sound isolation, acoustic quality, cleanup, pause expiry and multi-client reconnect are CONDITIONAL until the [dedicated audio test plan](RUNTIME_TEST_PLAN.md) passes. Source evidence is not runtime approval. No custom Java alternative is allowed if a required exposed capability fails. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. Full-crash B01-B12 blockers are not waived by this narrower research.
