# Multiplayer authority proposal

## Current Lua-only audio boundary - 2026-10-14

[AUDIO_FEASIBILITY.md](AUDIO_FEASIBILITY.md) is the current audio research contract; it is not implementation or approval to replace the full-crash requirements. Server owns schedule, settings, flight descriptors and cancellation. Clients own local-only sound playback and may request only a rate-limited current-state snapshot. Ordinary native sound rebroadcast wrappers are excluded. No client may choose shared event outcomes or alter authoritative SandboxVars.

The dedicated protocol candidate uses a server-session epoch, event/revision IDs, absolute server-time expiry, cancellation watermarks and ready-gated reconnect snapshots. Deduplicate across split-screen slots. Do not persist/replay active audio through server restart or reuse the MP zero-returning clock in SP. No world, cargo, salvage or zombie-attraction effects; therefore the audio design does not need the crash transaction as a prerequisite, but it still needs its own dedicated synchronization/cleanup evidence.

Only Lua/exposed vanilla APIs may implement a future authorized slice. Java bridges, agents, JAR dependencies and injected classes are prohibited. The remaining full-crash authority/persistence designs and settings below are historical/pending research, not enabled audio behavior or an authorization to add them. See the twelve NOT TESTED dedicated audio scenarios in [RUNTIME_TEST_PLAN.md](RUNTIME_TEST_PLAN.md). G7 and stable-release G8 remain blocked.

Date: 2026-10-09. Project version: ../VERSION. Status: architecture proposal for review; world materialization blocked by B01, identity trust by B11 and transaction guarantees by B05/B12. No implementation.

## Follow-up contract refinement

The [off-screen design](OFFSCREEN_SAFETY_DESIGN.md) rejects distance/current relevance as a sole authorization mechanism and includes all four player slots, loading connections, observer modes, teleportation, retained chunks, pending downloads and per-object render publication. No connected-client commit is approved. Fail closed with no materialization; a future isolated no-observer maintenance interval requires an independently verified admission/worker/persistence fence.

The [structural audit](STRUCTURAL_DESTRUCTION_AUDIT.md) traces server packet-helper removal separately from SP square removal. It includes both sides of wall ownership, corner replacement, multi-object expansion, spills/drops, column roof coverage and asynchronous region work. Server reservation must include that closure and immutable object preconditions. Unmodified-base provenance remains UNKNOWN; getPlayerBuiltFloor is not a construction history ledger.

The [persistence design](CRASH_PERSISTENCE_DESIGN.md) specifies stable allocation/component/operation/cargo IDs, complete deterministic manifests, reservation retention, paired completion receipts, durable tombstones, quarantine on ambiguous restart and native interaction exclusion. These are required contracts, not achieved guarantees. No exactly-once claim is made.

Native ObjectModDataPacket differs from filtered presentation command snapshots: its parse path directly loads/wipes an object's metadata; subsequent consistency checks do not establish B47HE identity ownership. Keep authoritative registry and outcomes server-owned and treat object metadata as untrusted hints until a protected binding/transport guard is verified. A client handler policy alone cannot prevent another native packet path from editing metadata. Never downgrade to client authority to close this gap.

All meaningful sandbox candidates below remain a review proposal. No configuration option may turn off visibility, identity, base protection integrity or durable recovery gates. Engine contract uncertainty disables affected gameplay. No protocol internals, safety fences or durability weakening switches are exposed as balance settings.

## Ownership and trust boundaries

The server owns scheduling, missions, aircraft selection, seeds, flight math, crash resolution, full affected footprint, reservations, world mutations, inventories, occupants, persistence, tombstones and recovery. Clients own positional audio and local aftermath presentation. They may request inspection/salvage; requests never supply authoritative coordinates, severity, inventories or damage manifests.

Use connection-associated player identity from OnClientCommand, not a username/online ID in arguments. Validate module/command allowlists, protocol version, finite bounded values, argument size, rate limits, event/component ID, current state, authoritative distance, permissions and inventory transaction conditions. Reject stale, replayed, malformed or unauthorized requests without mutations. Exact callback and inventory transaction semantics must be audited before coding.

Native object insertion plus explicit server complete-object transmission is the candidate replication path (E02/E03); insertion alone does not transmit in the inspected implementation. Native removal may encompass multiple tiles (E06), so footprint construction must precede reservation and visibility checks. Reuse native container replication only after its server transaction path is verified; never custom-broadcast loot creation from each client.

Commands carry server-issued event ID, sequence, time/expiry, approximate audio position and sound allowlist IDs. Interest-filter presentation descriptors; retain authoritative state server-side. Reconnecting players receive current world chunks and current active presentation state, never restart flight history. Validate snapshot ordering and client deduplication. Vanilla world state remains authoritative; presentation is not evidence of object placement.

ModData is exposed (E07) but its networking is bidirectional. GlobalModDataPacket.parse raises OnReceiveGlobalModData for received tables. Do not accept received tables into the server registry. Keep authoritative registry server-owned; send filtered presentation snapshots through controlled commands. Audit packet/callback handling for unauthorized writes before final authority approval.

## Visibility and materialization

Before any reservation or mutation, calculate the complete 3D footprint: every component, trail, scatter, multi-square removal expansion, structure intersections and consequential side effects. Check all connected players, including split-screen slots if supported, joining/teleporting players, upper floors, camera pan, zoom and viewport. Recheck immediately before each bounded mutation segment; unknown state fails closed.

No server-enforceable camera envelope is verified. Client viewport reports may only increase exclusion, never establish safety. Fixed distance or locally indexed isCanSee/isCouldSee is insufficient. Reserving terrain does not stop players entering it. No multi-tick visibility lease or atomic world-mutation guarantee is asserted. Until these are proved, neither dynamic nor pre-existing sites may materialize. Unloaded terrain cannot be silently treated as safe.

## Persistence and recovery proposal

Use a namespace/schema separate from project version. Assign stable event IDs, deterministic seeds and per-component IDs before materialization. Persist immutable resolution manifests, site reservations, planned structure removals, trail operations, cargo receipts and per-operation state. Suggested lifecycle: SCHEDULED -> IN_FLIGHT -> DISTRESSED/PENDING_IMPACT -> SITE_RESERVED -> MATERIALIZING -> PERSISTENT, with explicit CANCELLED and quarantine paths. Normal flights may complete without a site.

Record component lifecycle separately: planned, materialized, legitimately removed/tombstoned, quarantined. Reconcile by stable IDs against loaded world objects; do not assume missing means never spawned. Never reroll seed/outcomes, regenerate removed cargo or restore removed walls. Unknown schema or ambiguous object/receipt state quarantines the site. No global generated boolean.

GlobalModData and chunk/object stores are separate (E04/E07); no cross-store atomicity established. A crash between world write and receipt save can leave either side ahead. A legitimate salvage tombstone can likewise lag its world removal. This proposal is not proof of exactly-once recovery; B05 remains blocked until ordering/reconciliation is demonstrated. Save manifests before destructive work where verified, preserve durable removal evidence, and never replay ambiguous destruction blindly.

Reservations must use a server-owned bounded spatial index and survive restart. Pre-existing generation needs a stable world seed and region key plus durable explored/eligible/generated state; the exact exploration evidence API is UNKNOWN. Do not change density to reroll previously processed regions. No per-wreck permanent tick loop or full-map search.

## Sandbox candidates

All shared options use server SandboxVars under stable proposed namespace `B47HE`. These IDs and bounds are a review proposal, not implemented/verified loader definitions. Enabled gameplay requires engine gates even if a setting is true. Defaults do not imply usable capabilities.

| Group / proposed ID | Type, proposed default and bounds | Interpretation / existing-save behavior |
|---|---|---|
| Events.DynamicEvents | boolean true | Applies to future schedules; disabling stops new flights without deleting persistent wrecks. |
| Events.PreExistingWrecks | boolean true | Future eligible unprocessed regions only; never reroll existing regions. |
| Events.FlightIntervalDays | integer 14, 1-365, step 1 | Rare default proposal; server schedules future intervals, preserves active events. |
| Events.CrashChancePercent | integer 15, 0-100, step 1 | Per future flight; persist resolution once drawn. |
| Events.ActivityDecline | boolean true | Future schedules use documented outbreak progression curve; curve and its meaningful parameters require balancing review. |
| Events.LateGameActivityPercent | integer 10, 0-100, step 1 | Activity floor relative to initial rate; 0 disables late-game continuation. |
| Aircraft.UH60Weight / UH1Weight / AH64Weight / OH58Weight / CH47Weight | integer proposals 40/25/10/20/5; each 0-100, step 1 | Relative weights, not percentages; normalize server-side. All zero means no aircraft schedules. Historical/balance review pending. |
| Sites.PreExistingDensity | enum Very rare default; Off / Very rare / Rare / Normal | Density budgets and region size require review; region processing remains deterministic. |
| Damage.BuildingImpacts | boolean false until verified | Handoff's enabled-only-where-safe condition; never target unverified structures. |
| Damage.RoofPenetration | boolean false | Separate gate from sidewalls; no floors implied. |
| Damage.EnvironmentalDestruction | boolean true intent | Applies only to future verified operations; terrain overlays may remain cosmetic when destruction disabled. |
| Damage.GroundTrails | boolean true intent | Future sites; preserve existing trails. |
| Aftermath.Fires / Casualties / ZombieAttraction | booleans true intent | Individually gated, mission-aware future outcomes; enabling fire requires bounded protected side effects. |
| Protection.ProtectPlayerBuilt / ProtectSafehouses | booleans true | Check complete footprint server-side; uncertainty rejects. Claims/permissions must not be confused with safehouse exemption logic. |
| Protection.AllowPlayerBaseImpacts | boolean false | Explicit opt-in alone does not establish correct base detection. Protection flags win on conflict; any relaxation needs documented precedence and safe engine model. |
| Cargo.LootAbundance | enum Low / Normal default / High | Server resolves once per mission; changing setting never replenishes existing cargo. |
| Compatibility.NPCSurvivors | boolean false | Optional integration only; absent compatible module rejects/ignores enabling with a clear diagnostic, no core hard dependency. |

Final identifiers must map to actual supported sandbox definitions without ambiguity (namespace/group above is conceptual). Validate loaded types, enums and bounds server-side; invalid values use documented safe defaults, while engine uncertainty disables affected operation. Snapshot relevant configuration revision with resolved events. Localized names/tooltips and groups need all 29 vanilla JSON language folders with English fallback before implementation is usable.

Persistent wrecks and no loot respawn are invariants, not toggleable options that erase saves or resurrect cargo. Protocol/schema values, ID allocation, technical work budgets and visibility safety limits remain internal because user adjustment could invalidate integrity. Trail dimensions are initial balance ranges from the handoff; assess a meaningful aggregate severity/trail-scale option after prototype evidence, not dozens of geometry micro-settings. Vanilla coexistence remains default without changing the vanilla Helicopter sandbox option.
