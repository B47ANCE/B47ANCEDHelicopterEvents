# Phase 0 API audit

## Current Lua-only audio review - 2026-10-14

Current policy allows only Lua runtime code and exposed vanilla APIs. Custom Java/bridges/agents/injected classes/native extensions/JAR dependencies are prohibited; dated engine-bridge proposals below/in related documents are historical only. This update is documentation at the existing root VERSION, not Phase 1 or runtime approval.

| Audio surface | Current verdict | Evidence and remaining requirement |
|---|---|---|
| Owned client emitter lifecycle | CONDITIONAL | Exposed acquire/take/return, local playback, position/tick/stop exist. Test Lua overloads, queued starts, stop tails, pool reuse and disconnect cleanup. |
| Server sandbox path | VERIFIED_SOURCE; runtime NOT TESTED | Custom options, server Lua load, connection serialization and client SandboxVars import traced. Verify actual definitions, bounds, localization and admin changes in dedicated MP. |
| Expiry | CONDITIONAL | getServerTimeMills is synchronized in MP but returns zero before sync and in SP. Absolute expiry and a separate SP clock policy required. |
| Reconnect/late join | CONDITIONAL | Lifecycle events/command APIs exist. Ready handshake, session epoch, current snapshots, cancellation revision and deduplication must be implemented/tested only in a later authorized slice. |

See [AUDIO_FEASIBILITY.md](AUDIO_FEASIBILITY.md) and [AUDIO_API_EVIDENCE.md](AUDIO_API_EVIDENCE.md). Ordinary playSound/playSoundLooped may send client native sound packets despite setPlayRemoteEvents(false); use only the verified-local Impl candidate after Lua/runtime tests. No sound, asset or gameplay was implemented.

The audio candidate excludes world mutation, cargo, salvage and zombie attraction; it does not satisfy or override the original crash-site requirements. The following full-crash reconnaissance and NO-GO verdicts remain in force. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. Ten installed loose zombie class hashes drifted since the earlier inventory; initial evidence integrity is not a fresh installation-validation result.

Date: 2026-10-09 (America/Phoenix). Project version: read ../VERSION. Target and observed JAR build: **42.21**. Scope: read-only game/repository investigation and design follow-up with local documentation/evidence output. The accepted initial reconnaissance remains historical in history/phase0-accepted. No gameplay implementation. No runtime tests executed.

## Follow-up A-D decision

| Task | Verdict | Established findings / next requirement |
|---|---|---|
| A — conservative envelope and invisible commit | NO-GO | Local pan/zoom bounds are not server enforcement. Four connection slots, pending joins, retained chunks, delayed downloads and separate per-object publication defeat a proof from distance/relevance alone. Verify a complete admission/stream/render fence, or leave all materialization disabled. |
| B — structural destruction | NO-GO | Exact generic removal, door/window/tree/thumpable and vanilla sledge paths traced; dependent objects/drops/roof columns and asynchronous regions enlarge the footprint. Smallest diagnostic is a plain z=0 straight wall with no dependencies; no complete safe impact established. |
| C — manifest and recovery | NO-GO for exactly-once/durable recovery; CONDITIONAL manifest design | Independent chunk buffers/writes and registry saves permit either store to lead. Native object metadata is not a protected identity ledger. Need durable identity/transaction fences, native interaction exclusion and restart failure-injection evidence. |
| D — clean baseline | NO-GO for current installation as clean evidence; CONDITIONAL separate-fixture plan | 422 loose zombie classes differ from JAR; 11 extra; agents/resources outside that inventory also matter. Acquire independently verified 42.21 client/server fixtures outside the current installation under later authorization. |

See [off-screen contract](OFFSCREEN_SAFETY_DESIGN.md), [destruction audit](STRUCTURAL_DESTRUCTION_AUDIT.md), [manifest/recovery design](CRASH_PERSISTENCE_DESIGN.md), and [installation provenance](INSTALLATION_PROVENANCE.md). The follow-up adds 55 JAR class snapshots and 149 exact signature references in a separate evidence-followup bundle; initial evidence is unchanged. Source existence remains separate from native/runtime correctness.

## Discovery and evidence limits

No matching helicopter project was found in the workspace or repository directories checked. The intended new workspace was identified and reported before creation: `C:/Users/willi/Desktop/Repositories/Project Zomboid/B47ANCEDHelicopterEvents`. Existing suite projects and generated staging were left untouched.

Steam's HKCU registry SteamPath identified `E:/Program Files (x86)/Steam`; libraryfolders.vdf lists that library and C:/SteamLibrary (no listed PZ app there). appmanifest_108600.acf names ProjectZomboid and Steam build ID 25485521. The resulting installation is `E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid`. Current JAR Core.java:5235 constructs `GameVersion(42, 21, "")`; the older workspace AGENTS.md reference to 42.20.3 is stale for this inspection.

[VERIFIED] means a signature or implementation path in the hashed installed JAR or Lua snapshot. Decompiled lines are local evidence line numbers, not original developer source lines. CFR reports missing dependency classes and a structuring warning in Helicopter.update; exact branch behavior requires bytecode corroboration where consequential. No result is VERIFIED_RUNTIME_SP or VERIFIED_RUNTIME_MP.

The installation contains modified loose classes and launcher/loader files. `IsoObject.class` and `IsoGridSquare.class` loose hashes differ from their JAR members. ProjectZomboidServer.bat:4-5 uses `./;projectzomboid.jar`, putting loose classes first. The client JSON also places `.` first and includes an NPCFW Java agent. Other overrides are inventoried in evidence/class-manifest.json. JAR evidence therefore establishes **installed JAR behavior**, not clean vanilla provenance or the behavior of a running patched process. Never remove or repair these external files automatically.

## Verdicts

CONDITIONAL means a source-backed candidate for a later isolated experiment; it does not authorize production implementation. NO-GO means an unmet safety requirement currently blocks that feature. No feature has runtime GO evidence.

| Capability | Verdict | Source evidence and limitation | Next verification |
|---|---|---|---|
| Individual persistent wreck objects | CONDITIONAL | IsoObject constructor, square insertion, table save/load, native object replication exist (E01-E04). Sprite collision, inventories, directional appearance, removal and reload identity untested. | Clean 42.21 baseline; independent UH-60 components with stable IDs; dedicated two-client save/load/removal tests, after visibility gate resolution. |
| Ground crash trails | CONDITIONAL | Independent persistent IsoObjects and overlay methods exist (E05); server farming and tree paths are leads. No verified universal decal or terrain classifier. | Test original directional ground sprites on every listed surface, chunk reload, crops/trees, collision and MP; unknown terrain rejects generation. |
| Building sidewall penetration | NO-GO | Removal updates collision, navigation and region systems (E06), but native multi-object removal may expand the footprint. Wall/door ownership, weather, room/cutaway integrity and base provenance are unresolved. | Audit full wall/door/window removal chain and protected-base detection; disposable single-story vanilla fixture in dedicated MP. |
| Roof and floor penetration | NO-GO | Generic removal and roof checks are insufficient proof of safe multilevel geometry. | Verify roof/floor ownership, support/fall effects, exposure, cutaway and all affected levels; dedicated save/load fixture only after sidewall gate. |
| Off-screen crash guarantees | NO-GO | Online player enumeration exists; camera APIs reference local player indices; square visibility flags also use local indices (E09). No authoritative remote viewport contract was established. | Prove a server-enforceable visibility envelope including pan, zoom, floors, join/teleport and mutation races, or keep all materialization disabled. |
| Dedicated-server synchronization | CONDITIONAL | Server AddItemToMap replication and command globals exist (E03/E08). Interest filtering is present; reconnect/chunk state and inventory behavior not executed. | Dedicated two clients, later arrival/reconnect, contention and headless errors; no client gameplay ownership. |
| Restart recovery | NO-GO | GlobalModData saves separately from buffered/asynchronous chunk/object state; no verified durable barrier, protected identity or cross-store cargo/tombstone transaction. F-C traces the actual save paths. | Establish protected durable receipts and interaction exclusion; demonstrate reconciliation at every mutation/save/transfer checkpoint, including abrupt termination, before claiming exactly-once. |
| Vanilla helicopter compatibility | CONDITIONAL | GameTime scheduler, IsoWorld-owned Helicopter, server packet/client sync are identifiable (E11). Independent coexistence design avoids mutation of them. | Execute normal vanilla events concurrently with custom audio/events; verify no duplicate attraction/audio or altered vanilla schedule. |

The CONDITIONAL capabilities also inherit the off-screen NO-GO: no dynamic or pre-existing world materialization may proceed while that gate is unresolved.

## A-H coverage

A: constructor, insertion, identity metadata, save/load and replication signatures are recorded. `setDir` stores direction; it does not prove arbitrary sprite rotation. Custom directional art, tile properties and container ownership remain unknown.

B: overlay/independent-object trails are candidates. Farming removal and IsoTree.Damage lead to specialized behavior; crop lifecycle, grass/erosion regrowth, terrain tagging, tree side effects and persistent scorch decals remain unverified. Do not use floor replacement to approximate a trail.

C: engine removal invalidates render chunks and recalculates neighbors, roof checks, collision, PolygonalMap2 and IsoRegions. This is useful source evidence, not a complete structural destruction contract. No safe corridor implementation is approved.

D: ModData is Lua-exposed and delegates to GlobalModData. Global tables have a temp-file/copy save path; object tables serialize inside object saves. No cross-store atomicity or durable tombstone guarantee was established. ServerMap square lookups are candidates, not permission to create unloaded map squares or force remote chunks.

E: player-targeted commands and native world-object replication are available. Clients receive presentation only. Never register a server handler that accepts client-supplied authoritative registry tables. Public ModData network transport is bidirectional; its existence is not authorization to trust received data. Follow-up also traces ObjectModDataPacket's direct load/wipe of object metadata before consistency checking; world metadata cannot alone protect authoritative crash/component receipts (B11).

F: current APIs do not establish trustworthy remote camera coverage. Fixed player radius, client-reported visibility, zombie LOS and square flags cannot independently satisfy the specification. Revalidation once before a multi-tick batch also cannot protect later mutations.

G: SoundManager.PlayWorldSound returns null on GameServer.server; client audio and server zombie WorldSoundManager events are distinct. Flight audio must use server-issued bounded presentation descriptors with client-side emitters. Exact continuous moving-emitter lifecycle, rotor sound assets, distance/floor occlusion and reconnection cancellation remain candidates.

H: retain vanilla scheduler, singleton and packet untouched. Do not reuse the vanilla singleton for five custom aircraft. Future observation hooks need explicit exposure and lifecycle verification.

## Loader and scope

ChooseGameInfo$Mod.java:73-84 resolves common and selected version directories. ZomboidFileSystem.java:484-520 chooses compatible version directories and recognizes mod.info in common/version paths. This supports the proposed common + 42 shape at source level. The workspace convention for later source is `src/B47ANCEDHelicopterEvents/42/` plus sibling common; no production tree was created. Exact sound/model/texture registration, multiplayer resource delivery and all 29 JSON translation folders require later loader tests.

July 1993 aircraft, unit assignment and mission configuration are **[UNKNOWN] historical verification**, including early OH-58D equipment and specialized CH-47 variants. The handoff roster is a requirement, not corroborated historical evidence. No assets, weights or cargo tables were implemented. Primary historical sources must precede roster approval.

## Gates

G0 requirements recorded; G1 source reconnaissance and A-D follow-up completed with explicit blockers and candidates; G2 BLOCKED pending review and safe contracts. G3-G5 gameplay implementation/testing NOT STARTED. G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. Document/hash/version checks are offline checks only. Do not proceed to Phase 1 from this report without review. This follow-up does not implement a WAL, bridge, world lock, destruction operation or network interception.
