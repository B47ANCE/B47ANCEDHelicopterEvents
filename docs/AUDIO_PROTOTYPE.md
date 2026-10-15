# Bounded audio prototype - implementation notes

Current project version: [root VERSION](../VERSION). Implemented 2026-10-15 under the [merged contract](PHASE1_AUDIO_IMPLEMENTATION_CONTRACT.md); baseline main 126da35b65d0cecf39d251ba722e543cbc935ecc includes existing branding. User explicitly requested the existing 0.1.0-dev.3 target. This is additive prerelease functionality/configuration with no previous runtime API or save schema; no version bump beyond that requested checkpoint. No stable-release target is approved.

## Source and supported behavior

Authoritative root: src/B47ANCEDHelicopterEvents/42; Mod ID B47ANCEDHelicopterEvents. Config/Protocol are side-effect-free shared modules; Director owns server scheduling/subscriptions; Playback owns one physical client's presentation. Vanilla autoload/event wiring lives at the bottom of the respective server/client modules. Only Lua code is installed; Python/Lupa tests are offline development tools. No custom Java, external mod dependency, FMOD binding or native singleton changes.

One server flight at a time: a straight 120-tile eastbound diagnostic route centered on the first eligible current online player, z=0, one existing Helicopter sound key (Meta/Helicopter event). No load/generate square, world/AI sound, attraction, wreck, destruction, loot, salvage, distress, inventory or persistence. This route is a diagnostic fixture; additional production balance needs a separate scope/configuration review. No camera/visibility safety claim is needed because this feature mutates no world objects.

The sound starts once per event per client manager; a short/nonlooping clip is allowed to end naturally and is never restarted. Suitability as a continuous bed and late-join acoustics remain release blockers, not guaranteed by the filename. Missing API, failed sound handle or unsafe clock means silence. No numeric seeking. One owned emitter across local slots; only normal OnTick ticks it. OnTickEvenPaused checks deadlines/heartbeat and may clean up, never starts or advances sound.

The initial adapter supports dedicated MP only. Server getCore():isDedicated() must be true to enable scheduling; hosted servers resolve disabled snapshots and emit a diagnostic. SP client code prints an unsupported diagnostic and never starts a dispatcher. No SP/host compatibility claim.

## Server sandbox options

| Stable ID | Default | Range / interpretation |
|---|---|---|
| B47HE.EnableAudioFlights | false | Native boolean; opt in. Disable cancels at next server check (normally <=1 real second). |
| B47HE.FlightIntervalDays | 14 | Native integer 1-365 in-game days. First due time = current world hours + interval once an eligible player exists. |
| B47HE.FlightDurationSeconds | 60 | Native integer 10-180 real seconds. Resolved expiry is immutable. |

Server reads SandboxVars only. Missing namespace, wrong type, nonfinite/fractional/out-of-range values disable the feature; there is no client configuration fallback. Existing saves depend on native default initialization; if unavailable, remain disabled. Ordinary client volume/mute remains native. Definitions use installed-game custom-option types and JSON translation conventions; English names/tooltips/page are provided. Other languages rely on the native English fallback, which is NOT TESTED.

Configuration/eligibility is checked at most once/real second. Interval edits reset the future due opportunity from current time; duration changes do not alter an active deadline. Disable/re-enable never resumes a cancelled event. Missing players retain at most one overdue opportunity; no catch-up burst. Alive current online player objects are eligible; dead/loading/no-player connections cannot anchor a flight. Disconnect pruning is bounded by actual online players, not map size.

## Protocol, time and resource limits

Only SyncRequest(protocolVersion,clientNonce) is accepted under B47HEAudio. Actual native OnClientCommand player identity must be present in the current cached server membership set. Rate limit is one processed request/player/two seconds, including malformed requests; rejected traffic receives no response. Membership is refreshed once/second and never creates entries for arbitrary identities. Native deserialization occurs before Lua validation; this mod cannot bound engine-level costs of arbitrary malicious packets.

Server sends player-targeted full Snapshot tables only. See contract field inventory. Tables are flat, exact-key validated, at most 24 scalar fields, tokens <=64 ASCII bytes, coordinates finite and within technical bounds. Native scalar serialization inspection supports a conservative <4 KiB table payload budget; packet framing is separate. No custom fragmentation. No client force/start/outcome/config command.

Epoch is a process-instance wall-ms/server-monotonic-ms tuple; event serials are scoped to it. These are ephemeral correlation IDs, not cryptographic identities or crash-durable uniqueness claims. Each local manager uses wall ms plus a module-lifetime serial nonce. It accepts an epoch only for its outstanding nonce, then rejects epoch replacement. Revision/config watermarks and empty snapshots defeat stale active delivery. Equal revisions may only refresh serverNowMs. Same-event descriptors cannot change their deadline/route/sound. Collections stay O(online players) on server, O(1) on client.

OnConnected replaces the manager and clears old audio without sending immediately. A normal in-game tick, live local player and native synchronization flag precede a maximum of three requests (2/4/8-second backoff). A matched fresh snapshot must also agree with local synchronized server time within 2 seconds. This sample is a current-connection clock sanity check; it does not prove native clock internals. Unsafe/regressing/skewed time fails silent; no local receipt-time lifetime substitute. Active heartbeats at most once/two seconds; >6 seconds without a fresh same/new revision stops playback. Even total cancellation-message loss cannot extend absolute expiry. No idle broadcast loop.

Local playback uses only playSoundImpl("Helicopter",false,nil), with acquire/take ownership before playback. Cleanup clears references, attempts local handle stop and exclusive-emitter stopAll, one bounded drain tick, and one ownership return. No returned reference is reused. If ownership/cleanup throws, a module-lifetime latch blocks future acquisition across reconnects until process restart; ambiguous ownership is not blindly returned twice. Native audible tails after return remain unverified. Other start/clock failures silence that manager until a fresh connection, without retry storms. This is diagnostic error handling, not evidence that native resource recovery succeeded.

No active state is saved anywhere. Server restart cancels all prior flights and starts a fresh future schedule; clients reconnect and request only current state. No exactly-once audio/crash/cargo claim and no persistent migration.

## Validation and remaining gates

See [validation](VALIDATION.md), [implementation API findings](AUDIO_IMPLEMENTATION_EVIDENCE.md) and [A-R01..12 plan](RUNTIME_TEST_PLAN.md). Offline Lua 5.1 fake-boundary tests exercise scheduling, protocol/state transitions and resource call order. They do not execute Kahlua, native command serialization, FMOD or the game loader. Syntax/static path checks are not Linux proof. No distribution artifact exists and no engine has been launched.

G6/SP NOT TESTED; G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. Clean and patched fixture tests must stay separate. Prior broad distress and SP-dispatcher subcases are deferred, not PASS. Next operator step requires separate authorization and verified clean Build 42.21 dedicated/two-client fixtures; no launch, package, deploy or upload is authorized by this implementation request.
