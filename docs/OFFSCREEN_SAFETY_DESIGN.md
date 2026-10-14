# Off-screen materialization contract — follow-up

Current-policy annotation, 2026-10-14: runtime mods are Lua-only. All earlier engine/Java bridge speculation is historical and unavailable as a remedy. The [audio-only candidate](AUDIO_FEASIBILITY.md) creates no wreck/world mutations and does not meet or waive the crash-site contract below.

Date: 2026-10-09 (America/Phoenix). Project version: ../VERSION. Installed JAR target: Build 42.21. Authorization: source investigation/design only. **Verdict: NO-GO for materialization with connected clients under the required strict guarantee.** No gameplay or runtime experiment performed.

## Required property

For the complete affected 3D footprint F, no connected client may render either the first mutation or any intermediate state until the site's complete authoritative state is available. F includes object insertion/removal, dependent multi-tile objects, attached fixtures, contents spill, ground changes and structural side effects; recalculation/roof effects can extend beyond the deleted object. This must hold throughout mutation, streaming and reconciliation, not just at the initial decision.

Distance from server-known player positions can exclude candidates, but cannot alone authorize a commit. Client visibility reports are untrusted veto hints only. A report being fresh or unanimous does not establish coverage of client render state or packets already in flight.

## Observed source contract

Exact signatures and class exposure are in [the follow-up API index](evidence-followup/API_SIGNATURES.md). All observations below are [VERIFIED_SOURCE] for the installed JAR, with clean provenance unresolved.

| Concern | Source | Finding and unresolved contract |
|---|---|---|
| Normal camera pan | PlayerCamera.update, PlayerCamera.java:125-255 | Driving pan is clamped against local offscreen dimensions; controller aiming uses axes multiplied by 1500; keyboard/mouse pan uses viewport dimensions/aspect ratio and different multipliers. These are screen-space branch limits, not a verified world-space server maximum. |
| Zoom and viewport | MultiTextureFBO2.java:61-62, 81-168, 185-214, 363-374 | Default levels include 2.5 down to 0.25; setters assign zoom and a custom zoom list directly. Normal scroll/update limits are local to configured levels. Width/height depend on local screen size and display zoom. Default 2.5 is not a server-enforced maximum across clients or patches. |
| Local versus remote | IsoCamera.java:29-35, 57-65, 133-150; PlayerCamera.java:136 | Camera arrays and followed character are local; PlayerCamera selects IsoPlayer.players[playerIndex]. No remote viewport/zoom telemetry contract established. PlayerPacket.java:78-109 describes identity/prediction/variables, not a complete viewport contract. |
| Multiple local players | UdpConnection.java:100-106, 223-280; IsoCamera screen-size methods | Connection relevance loops four slots, including connectArea and releventPos. All occupied and pending slots must be accounted for; enumerating one player per connection is insufficient. Server player registry alone does not prove pending slots cannot acquire chunks. |
| Spectators/admin/dead viewers | IsoCamera.SetCharacterToFollow; IsoPlayer.java:3389-3415; PlayerPacket.processServer | Debug following can select another character; admin-related replication differs from normal relevance. No exhaustive vanilla spectator camera lifecycle was established. Ghost/invisible/dead is not proof of an inability to render. Unrecognized observer modes must block commit. Optional observer mods cannot be assumed compatible. |
| Teleportation | TeleportPacket.java:69-107; GameServer.sendTeleport; PlayerPacket.processServer | Native teleport client handler changes coordinates then sends player state. Server/connection state can lag the client's new view. Other scripts/admin actions can relocate players. No mod-level reservation blocks teleport or provides a camera/stream fence. |
| Joining | RequestZipListPacket.parse; UdpConnection.isFullyConnected; GameServer.receiveClientConnect | Loading connections can request chunks via download server before a completed gameplay registration. A commit must include all authenticated/loading connections, pending slots and downloads; no established admission lock couples joins to crash commit. |
| Subscription versus visibility | UdpConnection.isRelevantTo/RelevantTo; PlayerDownloadServer.java:100-107 | Relevance is a connection interest rectangle, with a request test using chunkGridWidth and a radius. It does not track all chunks already present/renderable on a client. chunkGridWidth <= 0 returns true in the request range predicate, so unknown width is not a safe empty view. |
| Streaming | PlayerDownloadServer.java:119-203, 220-261; RequestZipListPacket.java:42-74 | Out-of-range queued requests are admitted after a 5000 ms hold in the inspected path. Pending requests load/keep server chunks and serialize ready chunks. The worker and outstanding network buffers have separate lifetimes. Range rejection is not a permanent visibility fence. |
| Client retained chunks | IsoChunkMap reference/unload paths; e.g. refs removal at :730-742 and :1158 onward | Local maps hold chunk references; unloading follows client-side lifecycle. No server-acknowledged inventory of all renderable/retained snapshots was established. Being outside current relevance does not prove the client never had the footprint. |
| Multi-tick mutation | IsoObject.transmitCompleteItemToClients; GameServer.RemoveItemFromMap; AddItemToMapPacket.processClient | Independent object messages and chunk snapshots expose per-object intermediate state. Reliability/order does not make a crash an atomic client render operation. Rechecking the next tick cannot undo a mutation already observed. |

The numeric pan/zoom/stream values above are engine observations, not proposed mod safety settings. Their conversion into a complete envelope would require accounting for resolution, projection, floor differences, sprite overhang, all follow modes, client cache contents and movement latency. The current patched camera/stream classes further invalidate treating JAR defaults as the running installation's limits.

## Counterexamples to tempting shortcuts

1. Check relevance at t0; mutate several squares; a download request accepted earlier serializes/ships a partial site at t1. The player later renders that retained snapshot. Current interest checks never demonstrated absence of the data.
2. All known players are distant at t0; an authenticated loading client requests the affected chunks, or an admin teleports a player during materialization. Rechecking positions next tick does not retract the first state sent.
3. Generate everything in one server tick. Add/remove packets and a chunk snapshot still have independent processing/arrival; the client may apply one before the others. No transaction-aware render barrier was found in the inspected native paths.
4. Suppress broadcasts until done. Existing clients can already hold stale chunks; streaming/state requests and later deltas need a consistent revision boundary. Suppression alone is not a visibility, persistence or reconciliation contract.
5. Pause time or block movement. ServerMap.checkClientPause sends pause messages for long saves; it does not demonstrate that camera/rendering or download workers are frozen. Client acknowledgement is not an authoritative proof against a modified observer.

These are [INFERRED] failure traces from the source separation, not executed runtime failures. They suffice to show the proposed distance/relevance checks have not proved the strict property; they are not a claim that every possible engine-level solution is impossible.

## Missing enforceable contract

A connected-client commit would require a verified mechanism covering (a) all current/retained/pending footprint chunk versions, (b) all renderable view modes, (c) admission and teleport/movement changes, (d) streaming workers/requests/state responses, and (e) publication of a completed site revision to every client without intermediate states. No such dedicated-server/Lua contract was established. The former hypothetical engine-bridge idea is historical only and prohibited under current Lua-only rules. There is no approved replacement for this missing exposed-API contract.

## Fail-closed alternatives only

| Alternative | Verdict | Conditions |
|---|---|---|
| Disable all world materialization; defer or cancel unsafe events | GO as a design safety rule | No wreck/destruction prototype is implied. Record why a planned site never committed; do not falsely emit a confirmed crash location. |
| Keep a deterministic unresolved manifest in server-owned storage | CONDITIONAL | Storage authority/durability must be established; this is planning only, no gameplay/world side effects and no client authorization. |
| Generate during an explicitly isolated maintenance/startup interval with admissions disabled, zero clients and no stream workers/in-flight client snapshots | CONDITIONAL future alternative | Requires verified engine admission/worker exclusion, safe offline world loading, persistence barriers and complete reconciliation before any client can join. Zero entries in getOnlinePlayers is insufficient. No maintenance launch or save modification authorized here. |
| Pre-authored original map aftermath present before the first server session | CONDITIONAL separate project scope | Requires map/asset pipeline and persistence review, no online materialization. It does not fulfill dynamic crash generation and is not silently substituted. |

If a previously partial site exists after interruption, simply letting clients join and finish it violates the same requirement. It must remain unavailable/quarantined or be reconciled under a proven no-observer interval. Never relocate partially committed geometry or roll back structure by recreating walls without a verified transaction.

## Assumptions and next questions

[UNKNOWN] clean 42.21 class provenance; all supported observer modes; exact maximum client renderable set; packet/worker interleaving; authoritative admission fence; teleport hooks; renderer transaction capability; safe remote chunk loading. Next work remains read-only contract verification or separately authorized diagnostics. Runtime plan F-R01 through F-R06 is required before any connected-client GO; G7 remains BLOCKED / NOT TESTED.
