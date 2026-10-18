# Clean versus patched Build 42.21

## Static model dependency refresh — 2026-10-17

[W01-W31 fingerprints](STATIC_WRECK_SOURCE_INDEX.json) recheck the same packaged JAR and current loose counterparts for this bounded audit. IsoObject, IsoGridSquare, IsoChunk, Model, ModelManager, IsoObjectModelDrawer and GameWindow each have differing loose copies. Model/ModelManager/IsoObjectModelDrawer can affect import/material/render behavior; their responsibilities indicate possible effects, not a patch-body analysis or compatibility result. No loose counterpart was found for the other 24 indexed classes. This does not exhaust nested/other dependencies, media changes, agents or runtime transformations. Native loader findings are conditional on this provenance boundary. Preserve the installed files; no repair, replacement or launch occurred. Independently authenticated clean client and dedicated fixtures remain required.

## Implementation status - 2026-10-15

Implementation source inspection still targets the same packaged JAR fingerprint; no clean-depot authentication or patched-runtime revalidation was performed. [Current implementation evidence](AUDIO_IMPLEMENTATION_EVIDENCE.md) does not authorize executing, repairing or replacing the installation. Future clean/patched runtime results remain separate.

Current review annotation, 2026-10-14: the installed JAR hash still matches the earlier snapshot; ten loose zombie classes changed since that inventory. FMODSoundEmitter, GameTime and LuaEventManager also have loose copies differing from the JAR. The recorded local source bundles remain intact; that does not revalidate the patched runtime. Java agents/loaders mentioned below describe the existing installation only and are not permitted mod dependencies. Preserve that installation; do not repair it. See [audio source fingerprints](AUDIO_API_EVIDENCE.md).

Date: 2026-10-09. Project version: ../VERSION. **Current installation: NO-GO as clean vanilla evidence. Separate clean-fixture validation plan: CONDITIONAL.** No installed file was deleted, overwritten, repaired, replaced or executed as PZ/server.

## Observed provenance

Steam discovery and appmanifest/depot identifiers remain in the initial hashed environment bundle. Core in the installed JAR reports 42.21. JAR SHA-256 is `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`; that is a local fingerprint, not an official authenticity certificate. An independent original depot comparison has not been performed.

[loose-class-inventory.csv](evidence-followup/loose-class-inventory.csv) enumerates every loose `.class` beneath installed `zombie/`: **433 files, 422 differing from same-name installed JAR members, 11 with no same-name JAR member, zero byte-identical**. Hash difference alone does not identify the author or prove a particular behavioral effect. Only filenames/hashes and installer metadata were inspected for third-party modifications; no patched implementation was copied or adopted.

The scope does not exhaust fmod/, other package roots, native DLLs, Workshop JARs, shaders or Java agents. pzopt-installed.txt/ pzopt-files.txt enumerate additional touched files, including fmod and media resources. Their recorded revision/install time is self-reported installer provenance, not a proof that everything in the installation is original. Keep that timestamp as recorded; it is not a new runtime test timestamp.

ProjectZomboidServer.bat and ProjectZomboid64.bat put `./` before projectzomboid.jar. The EXE JSON puts `.` first and references an external NPCFW JAR/Java agent. Actual launch paths can differ; this audit does not launch any of them. Agent transformation can affect classes even when no loose file exists.

## Existing overrides affecting these contracts

Every class listed as overridden below is present and differs from its JAR counterpart; exact hashes are in the CSV. Effects are [INFERRED] from the original class responsibilities, not claims about patch implementation.

| Existing override | Relevant surface |
|---|---|
| zombie/iso/IsoObject.class and nested classes | Sprite/object membership, persistence, metadata and complete-object transmission calls |
| zombie/iso/IsoGridSquare.class and nested lighting/render classes | Tile insertion/removal, wall/floor property aggregation, collision/neighbor state and render invalidation |
| zombie/iso/IsoChunk.class and ChunkLock/SanityCheck helpers | Chunk serialization, write/read protection, loaded readiness, persistent world state |
| zombie/iso/IsoWorld.class and nested classes | World lifecycle, common ownership, simulation/runtime behavior |
| zombie/iso/IsoChunkMap.class and helpers | Local streaming window, retained/ref-counted chunks, unload behavior |
| zombie/iso/IsoCamera.class, IsoCamera$FrameState.class, PlayerCamera.class | Local camera, pan, follow and viewport/projection state |
| zombie/core/textures/MultiTextureFBO2.class and helper | Local zoom and offscreen render dimensions |
| zombie/characters/IsoPlayer.class and helpers | Local/remote player updates, camera/observer behavior and interaction state |
| zombie/MapCollisionData.class and helpers | Collision change/save notifications |
| zombie/pathfind/PolygonalMap2.class and helpers | Pathfinding change propagation |
| zombie/iso/fboRenderChunk/FBORenderCutaways.class and helpers | Cutaway renderer; additional PzoptMirrorCut helper has no same-name JAR member |
| zombie/GameTime.class and WorldSoundManager.class | Scheduling/time and zombie-attracting world sound |

No loose file was found for the inventoried exact names GameServer, GameClient, ServerMap, PlayerDownloadServer, IsoCell, IsoObjectUtils, IsoDoor, IsoWindow, IsoThumpable, IsoTree, IsoRegions, IsoGridOcclusionData, ItemContainer or GlobalModData. This is a filename inventory result, **not proof of unchanged runtime behavior**: overridden shared dependencies and external agents remain relevant. Networking correctness can change through chunk/object serialization even without a loose GameServer class.

## Separate clean-fixture procedure — not executed

1. Preserve the existing E: installation and its launchers/cache/save files. Do not use Steam Verify Files, uninstallers, repair scripts or depot replacement in that directory. A copy of this patched folder is only a patched comparison fixture, not a clean install.
2. Have the operator obtain an independently downloaded, licensed, original Build 42.21 client and dedicated-server fixture in a separately named directory, for example `C:/PZ-Validation/Clean-42.21/`. This path is a proposal, not created or selected as an installed game. Record exact Steam app/depot/manifest/branch identifiers, download receipt and acquisition date; newest public build alone does not pin 42.21. Do not assume client and server depots/build identifiers coincide.
3. Hash the full fixture tree before launch. Compare its JAR members, shipped loose classes, media, native libraries and launcher files to the independently obtained depot contents. Do not assume that all loose classes are patches: if an original depot ships one, compare it with that depot's original file. Confirm Core version 42.21 and compatibility of relevant bytecode. A matching hash against only the existing local JAR is not enough to establish vanilla provenance.
4. Record every classpath entry, working directory, JVM agent/-javaagent/-agentpath option and native search path for a separate clean launcher. No FadedJavaLoader/pzopt/NPCFW or external mods in the baseline. Merely putting the JAR first can leave other class roots, agents, natives or patched resources active. Do not edit current launchers to achieve this.
5. Use an isolated cache/profile, server config and disposable saves for clean fixtures; verify the supported launch/cache configuration from official shipped files before executing. Prevent shared user mod lists, enabled Workshop items or save directories from contaminating the fixture. Dedicated baseline must have its own authoritative config and at least two controlled clients for G7.
6. Separately record clean-baseline diagnostics and patched compatibility diagnostics with the same scenario/version and independent evidence. Verify actual class origins/agents at launch using an approved diagnostic mechanism; offline classpath inspection is not runtime provenance. Preserve all results and hashes, never merge patched PASS into clean proof.
7. Do not run this procedure until the operator authorizes fixture acquisition/setup and game/server launch. This turn authorizes only source/design documentation; no download, new game installation, launching or save modification occurred.

## Review and next evidence

[UNKNOWN] independent original 42.21 depot hashes, source equivalence of current JAR, actual runtime class origins and transform hooks, full non-zombie override inventory, clean dedicated server build. The initial and follow-up hashed inputs are rechecked after document work; unchanged hashes prove those inspected installed files stayed unchanged during this task, not that the whole installation is clean. Clean validation F-R16 is separate from patched compatibility F-R17. G7 BLOCKED / NOT TESTED; G8 BLOCKED.
