# API evidence

## Follow-up evidence — current decision context

The accepted initial signature inventory below is preserved and still matches its original hashed snapshots. Current project version is ../VERSION. Additional research is separate in evidence-followup; initial decompiled line numbers must not be applied to the new snapshots.

[Follow-up exact signature index](evidence-followup/API_SIGNATURES.md): 55 extracted JAR classes, 149 exact Java signature references, direct class-exposure observations. class-manifest.json records source byte hashes and loose counterparts; source-manifest.json covers all 125 follow-up evidence files; environment.json records inputs. Loose filenames/hashes under installed zombie/ are inventoried in loose-class-inventory.csv. No third-party patched implementation was decompiled for adoption.

| Trace ID | Sources and exact entry points | Evidence / limitation |
|---|---|---|
| F-A1 | PlayerCamera.update/getOffX/getOffY; IsoCamera.SetCharacterToFollow/setCameraCharacter; MultiTextureFBO2.setZoom/setZoomLevels/getMaxZoom/getWidth/getHeight | VERIFIED_SOURCE local camera branches/default zoom; no remote enforced bound. |
| F-A2 | UdpConnection.isRelevantTo/RelevantToPlayerIndex/RelevantTo/getPlayerAt; PlayerPacket.parse/processServer; TeleportPacket.processClient/processServer | VERIFIED_SOURCE four-slot relevance/prediction and teleport flow; viewport ownership and observer/admission fence UNKNOWN. |
| F-A3 | RequestZipListPacket.parse; PlayerDownloadServer.update/isRequestInRange/updateOutOfRangeRequests/updatePendingChunks; WorkerThread; IsoChunkMap references/unload | VERIFIED_SOURCE queued/retained/published chunk paths; no complete subscription/render exclusion contract. Private methods are evidence, not Lua interfaces. |
| F-A4 | IsoObject.transmitCompleteItemToClients; GameServer.RemoveItemFromMap; AddItemToMapPacket.processClient; RemoveItemFromSquarePacket.processClient | VERIFIED_SOURCE per-object native publication; no crash-wide client transaction marker/atomic render boundary in inspected paths. |
| F-B1 | IsoGridSquare.getWall/getFloor/RemoveTileObject/transmitRemoveItemFromSquare/RecalcAllWithNeighbours; IsoObjectUtils.safelyRemoveTileObjectFromSquare/getAllMultiTileObjects | VERIFIED_SOURCE square/edge/multi-object ownership and native mutation chain; full geometry closure UNKNOWN. |
| F-B2 | IsoDoor.destroy/destroyDoubleDoor/destroyGarageDoor; IsoWindow.smashWindow/Damage; IsoThumpable.destroy; IsoTree.Damage/toppleTree; ISDestroyStuffAction:complete | VERIFIED_SOURCE specialized destruction and side effects; deterministic idempotent drops/contents spill not established. |
| F-B3 | MapCollisionData.squareChanged; PolygonalMap2.squareChanged; IsoRegions.squareChanged; IsoCell.checkHaveRoof; IsoGridOcclusionData.SquareChanged | VERIFIED_SOURCE native update/worker paths; cutaway, navigation, exposure and MP settling are NOT TESTED. |
| F-B4 | IsoObject/IsoGridSquare/IsoChunk.invalidateRenderChunkLevel; FBORenderCutaways.checkPlayerRoom/checkExteriorWalls/checkOccludedRooms/shouldHideElevatedFloor; IsoRoom membership and WeatherFxMask | VERIFIED_SOURCE distinct per-client render caches, map room identity and weather-region masking. Generic removal does not prove full combined fidelity. |
| F-C1 | GlobalModData.save/load; ServerMap.SaveAll/QueuedSaveAll; ServerChunkLoader.addSaveLoadedJob/updateSaved; SaveChunkThread.addLoadedJob; SaveLoadedTask.save; IsoChunk.SaveLoadedChunk/SafeWrite | VERIFIED_SOURCE separate snapshot/write paths; no cross-store atomicity or proven durable fsync barrier. |
| F-C2 | ItemContainer.AddItem/Remove/save/load; TransactionManager.update | VERIFIED_SOURCE container serialization and online transaction state; durable transfer ledger NOT established. |
| F-C3 | ObjectModDataPacket.parse/isConsistent/processServer; MovingObject.isConsistent; PacketTypes$PacketType.onServerPacket; INetworkPacket.parseServer | VERIFIED_SOURCE parse can mutate object metadata before consistency; no immutable B47HE namespace/identity guard established. Runtime/exploit claims are not made. |
| F-D | Server/client batch and EXE JSON launchers, pzopt file metadata, loose-class hash inventory | VERIFIED_SOURCE classpath/agent configuration and local hashes; not independent clean depot authentication. |

For execution side, persistence restrictions, minimal runtime tests and unresolved assumptions, follow the named trace into OFFSCREEN_SAFETY_DESIGN.md, STRUCTURAL_DESTRUCTION_AUDIT.md, CRASH_PERSISTENCE_DESIGN.md and INSTALLATION_PROVENANCE.md. All SP/host/headless dedicated/two-client runtime results remain NOT TESTED. No signature alone authorizes use.

Date: 2026-10-09. Build: installed JAR 42.21. Project version: ../VERSION.

Every row below records the exact decompiled signature and a clickable file/line. `VERIFIED_SOURCE` applies only to the signature/branch inspected, with limitations explicitly recorded. The gameplay usage remains CANDIDATE or BLOCKED in API_AUDIT.md. Runtime SP/MP evidence: none. Exposure registration is class-level evidence, not proof of every overload resolving in Lua.

Sources are under docs/evidence/decompiled; class-manifest.json hashes each extracted class and any installed loose counterpart. environment.json hashes installed Lua snapshots, launcher, manifest, JAR and CFR. source-manifest.json hashes every local evidence file. Decompiled line numbers are not original source line numbers.

## E01 — Object creation, identity and direction

Execution side: Shared class; mutations restricted to server by proposed mod design.

Lua exposure: LuaManager$Exposer.java:2334.

Restrictions/persistence: Direction metadata does not prove rotating artwork or correct collision; custom containers unverified.

Minimal runtime tests: R01, R02, R03; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public IsoObject(IsoCell cell)` | [zombie/iso/IsoObject.java:486](evidence/decompiled/zombie/iso/IsoObject.java#L486) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public IsoObject()` | [zombie/iso/IsoObject.java:490](evidence/decompiled/zombie/iso/IsoObject.java#L490) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public IsoObject(IsoCell cell, IsoGridSquare square, IsoSprite spr)` | [zombie/iso/IsoObject.java:506](evidence/decompiled/zombie/iso/IsoObject.java#L506) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public IsoObject(IsoCell cell, IsoGridSquare square, String gid)` | [zombie/iso/IsoObject.java:512](evidence/decompiled/zombie/iso/IsoObject.java#L512) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public IsoObject(IsoGridSquare square, String tile, String name)` | [zombie/iso/IsoObject.java:519](evidence/decompiled/zombie/iso/IsoObject.java#L519) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public IsoObject(IsoGridSquare square, String tile, String name, boolean bShareTilesWithMap)` | [zombie/iso/IsoObject.java:528](evidence/decompiled/zombie/iso/IsoObject.java#L528) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public IsoObject(IsoGridSquare square, String tile, boolean bShareTilesWithMap)` | [zombie/iso/IsoObject.java:548](evidence/decompiled/zombie/iso/IsoObject.java#L548) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public IsoObject(IsoGridSquare square, String tile)` | [zombie/iso/IsoObject.java:560](evidence/decompiled/zombie/iso/IsoObject.java#L560) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public KahluaTable getModData()` | [zombie/iso/IsoObject.java:1059](evidence/decompiled/zombie/iso/IsoObject.java#L1059) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public IsoDirections getDir()` | [zombie/iso/IsoObject.java:1853](evidence/decompiled/zombie/iso/IsoObject.java#L1853) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void setDir(int dir)` | [zombie/iso/IsoObject.java:1857](evidence/decompiled/zombie/iso/IsoObject.java#L1857) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void setDamage(short damage)` | [zombie/iso/IsoObject.java:1881](evidence/decompiled/zombie/iso/IsoObject.java#L1881) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void setSprite(IsoSprite sprite)` | [zombie/iso/IsoObject.java:1913](evidence/decompiled/zombie/iso/IsoObject.java#L1913) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void setSprite(String name)` | [zombie/iso/IsoObject.java:1922](evidence/decompiled/zombie/iso/IsoObject.java#L1922) | VERIFIED_SOURCE; runtime NOT TESTED |

## E02 — Square insertion

Execution side: Shared class; transmitAddObjectToSquare branches on GameServer.server.

Lua exposure: LuaManager$Exposer.java:2320.

Restrictions/persistence: AddTileObject alone updates world state but does not transmit; all squares must already be ready.

Minimal runtime tests: R01, R11; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public void AddTileObject(IsoObject obj)` | [zombie/iso/IsoGridSquare.java:5200](evidence/decompiled/zombie/iso/IsoGridSquare.java#L5200) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void AddTileObject(IsoObject obj, int index)` | [zombie/iso/IsoGridSquare.java:5204](evidence/decompiled/zombie/iso/IsoGridSquare.java#L5204) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void transmitAddObjectToSquare(IsoObject obj, int index)` | [zombie/iso/IsoGridSquare.java:5269](evidence/decompiled/zombie/iso/IsoGridSquare.java#L5269) | VERIFIED_SOURCE; runtime NOT TESTED |

## E03 — Native object replication

Execution side: Server transmitCompleteItemToClients requires udpEngine; AddItemToMap is sent to relative interest.

Lua exposure: LuaManager$Exposer.java:2334.

Restrictions/persistence: No guarantee of delivery outside interest, reconnect correctness or inventory ownership.

Minimal runtime tests: R01, R02, R04; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public void transmitCompleteItemToClients()` | [zombie/iso/IsoObject.java:4185](evidence/decompiled/zombie/iso/IsoObject.java#L4185) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void transmitUpdatedSpriteToClients(UdpConnection connection)` | [zombie/iso/IsoObject.java:4194](evidence/decompiled/zombie/iso/IsoObject.java#L4194) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void transmitUpdatedSpriteToClients()` | [zombie/iso/IsoObject.java:4221](evidence/decompiled/zombie/iso/IsoObject.java#L4221) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void transmitModData()` | [zombie/iso/IsoObject.java:4426](evidence/decompiled/zombie/iso/IsoObject.java#L4426) | VERIFIED_SOURCE; runtime NOT TESTED |

## E04 — Object and square serialization

Execution side: Native save/load lifecycle; not a recommended direct Lua call.

Lua exposure: LuaManager$Exposer.java:2334.

Restrictions/persistence: Object table load at 1279 and save at 1446; no cross-store transaction or durable tombstone.

Minimal runtime tests: R02, R03, R05; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public final void load(ByteBuffer input, int worldVersion) throws IOException` | [zombie/iso/IsoObject.java:1103](evidence/decompiled/zombie/iso/IsoObject.java#L1103) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void load(ByteBuffer input, int worldVersion, boolean isDebugSave) throws IOException` | [zombie/iso/IsoObject.java:1107](evidence/decompiled/zombie/iso/IsoObject.java#L1107) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public final void save(ByteBuffer output) throws IOException` | [zombie/iso/IsoObject.java:1325](evidence/decompiled/zombie/iso/IsoObject.java#L1325) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void save(ByteBuffer output, boolean isDebugSave) throws IOException` | [zombie/iso/IsoObject.java:1329](evidence/decompiled/zombie/iso/IsoObject.java#L1329) | VERIFIED_SOURCE; runtime NOT TESTED |

## E05 — Overlay candidates

Execution side: Shared; server owns any persistent mutation.

Lua exposure: LuaManager$Exposer.java:2334.

Restrictions/persistence: Overlay API is not a verified ground decal/trail or terrain classifier.

Minimal runtime tests: R06; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public void setOverlaySprite(String spriteName)` | [zombie/iso/IsoObject.java:4498](evidence/decompiled/zombie/iso/IsoObject.java#L4498) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void setOverlaySprite(String spriteName, boolean bTransmit)` | [zombie/iso/IsoObject.java:4502](evidence/decompiled/zombie/iso/IsoObject.java#L4502) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void setOverlaySpriteColor(float r, float g, float b, float a)` | [zombie/iso/IsoObject.java:4506](evidence/decompiled/zombie/iso/IsoObject.java#L4506) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void setOverlaySprite(String spriteName, float r, float g, float b, float a)` | [zombie/iso/IsoObject.java:4514](evidence/decompiled/zombie/iso/IsoObject.java#L4514) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public boolean setOverlaySprite(String spriteName, float r, float g, float b, float a, boolean bTransmit)` | [zombie/iso/IsoObject.java:4518](evidence/decompiled/zombie/iso/IsoObject.java#L4518) | VERIFIED_SOURCE; runtime NOT TESTED |

## E06 — Structural removal

Execution side: Server transmit removal uses GameServer.RemoveItemFromMap; other branches differ.

Lua exposure: LuaManager$Exposer.java:2320.

Restrictions/persistence: SafelyRemove may expand to multiple squares; collision/region updates do not prove cutaway/weather correctness.

Minimal runtime tests: R07, R08, R10; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public void RecalcAllWithNeighbours(boolean bDoReverse)` | [zombie/iso/IsoGridSquare.java:4537](evidence/decompiled/zombie/iso/IsoGridSquare.java#L4537) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void RecalcAllWithNeighbours(boolean bDoReverse, GetSquare getter)` | [zombie/iso/IsoGridSquare.java:4541](evidence/decompiled/zombie/iso/IsoGridSquare.java#L4541) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public int RemoveTileObject(IsoObject obj)` | [zombie/iso/IsoGridSquare.java:5084](evidence/decompiled/zombie/iso/IsoGridSquare.java#L5084) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public int RemoveTileObject(IsoObject obj, boolean safelyRemove)` | [zombie/iso/IsoGridSquare.java:5089](evidence/decompiled/zombie/iso/IsoGridSquare.java#L5089) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public int transmitRemoveItemFromSquare(IsoObject obj)` | [zombie/iso/IsoGridSquare.java:5279](evidence/decompiled/zombie/iso/IsoGridSquare.java#L5279) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public int transmitRemoveItemFromSquare(IsoObject obj, boolean safelyRemove)` | [zombie/iso/IsoGridSquare.java:5283](evidence/decompiled/zombie/iso/IsoGridSquare.java#L5283) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void RecalcProperties()` | [zombie/iso/IsoGridSquare.java:6335](evidence/decompiled/zombie/iso/IsoGridSquare.java#L6335) | VERIFIED_SOURCE; runtime NOT TESTED |

## E07 — Persistent server registry candidates

Execution side: Lua-exposed wrapper; transport is bidirectional.

Lua exposure: LuaManager$Exposer.java:2798.

Restrictions/persistence: Server must reject client authoritative data; registry save is separate from chunks.

Minimal runtime tests: R02, R05, R16; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public static KahluaTable getOrCreate(String tag)` | [zombie/world/moddata/ModData.java:28](evidence/decompiled/zombie/world/moddata/ModData.java#L28) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static KahluaTable get(String tag)` | [zombie/world/moddata/ModData.java:32](evidence/decompiled/zombie/world/moddata/ModData.java#L32) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static void transmit(String tag)` | [zombie/world/moddata/ModData.java:52](evidence/decompiled/zombie/world/moddata/ModData.java#L52) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static void request(String tag)` | [zombie/world/moddata/ModData.java:56](evidence/decompiled/zombie/world/moddata/ModData.java#L56) | VERIFIED_SOURCE; runtime NOT TESTED |

## E07 — Global table save and lifecycle

Execution side: Native singleton; Lua wrapper is ModData.

Lua exposure: No direct class registration found; UNKNOWN Lua exposure.

Restrictions/persistence: No direct class exposure found; temporary file copy does not prove atomic commit.

Minimal runtime tests: R05; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public void init() throws IOException` | [zombie/world/moddata/GlobalModData.java:74](evidence/decompiled/zombie/world/moddata/GlobalModData.java#L74) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void receiveRequest(ByteBufferReader bb, IConnection requesterConnection)` | [zombie/world/moddata/GlobalModData.java:195](evidence/decompiled/zombie/world/moddata/GlobalModData.java#L195) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void save() throws IOException` | [zombie/world/moddata/GlobalModData.java:242](evidence/decompiled/zombie/world/moddata/GlobalModData.java#L242) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void load() throws IOException` | [zombie/world/moddata/GlobalModData.java:296](evidence/decompiled/zombie/world/moddata/GlobalModData.java#L296) | VERIFIED_SOURCE; runtime NOT TESTED |

## E08 — Commands and connected players

Execution side: LuaMethod globals; branches select server/client/SP paths.

Lua exposure: LuaMethod(name=..., global=true) annotation in same source.

Restrictions/persistence: SP getOnlinePlayers returns empty; use separately verified local-player enumeration. Commands are transport, not validation.

Minimal runtime tests: R04, R09, R13; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public static ArrayList<IsoPlayer> getOnlinePlayers()` | [zombie/Lua/LuaManager$GlobalObject.java:1797](evidence/decompiled/zombie/Lua/LuaManager$GlobalObject.java#L1797) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static void sendClientCommand(String module, String command, KahluaTable args)` | [zombie/Lua/LuaManager$GlobalObject.java:5154](evidence/decompiled/zombie/Lua/LuaManager$GlobalObject.java#L5154) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static void sendClientCommand(IsoPlayer player, String module, String command, KahluaTable args)` | [zombie/Lua/LuaManager$GlobalObject.java:5166](evidence/decompiled/zombie/Lua/LuaManager$GlobalObject.java#L5166) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static void sendServerCommand(String module, String command, KahluaTable args)` | [zombie/Lua/LuaManager$GlobalObject.java:5185](evidence/decompiled/zombie/Lua/LuaManager$GlobalObject.java#L5185) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static void sendServerCommand(IsoPlayer player, String module, String command, KahluaTable args)` | [zombie/Lua/LuaManager$GlobalObject.java:5192](evidence/decompiled/zombie/Lua/LuaManager$GlobalObject.java#L5192) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void addSound(IsoObject source, int x, int y, int z, int radius, int volume)` | [zombie/Lua/LuaManager$GlobalObject.java:7179](evidence/decompiled/zombie/Lua/LuaManager$GlobalObject.java#L7179) | VERIFIED_SOURCE; runtime NOT TESTED |

## E09 — Camera coverage candidates

Execution side: Local camera arrays/player indices; no authoritative remote camera contract established.

Lua exposure: LuaManager$Exposer.java:2315.

Restrictions/persistence: Cannot authorize server mutation from these local values.

Minimal runtime tests: R09; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public static float getOffX()` | [zombie/iso/IsoCamera.java:76](evidence/decompiled/zombie/iso/IsoCamera.java#L76) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static float getOffX(int playerIndex)` | [zombie/iso/IsoCamera.java:80](evidence/decompiled/zombie/iso/IsoCamera.java#L80) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static float getOffY()` | [zombie/iso/IsoCamera.java:92](evidence/decompiled/zombie/iso/IsoCamera.java#L92) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static float getOffY(int playerIndex)` | [zombie/iso/IsoCamera.java:96](evidence/decompiled/zombie/iso/IsoCamera.java#L96) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static float getCameraCharacterZ()` | [zombie/iso/IsoCamera.java:128](evidence/decompiled/zombie/iso/IsoCamera.java#L128) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static int getScreenWidth(int playerIndex)` | [zombie/iso/IsoCamera.java:159](evidence/decompiled/zombie/iso/IsoCamera.java#L159) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static int getScreenHeight(int playerIndex)` | [zombie/iso/IsoCamera.java:173](evidence/decompiled/zombie/iso/IsoCamera.java#L173) | VERIFIED_SOURCE; runtime NOT TESTED |

## E09 — Visibility flags

Execution side: Local player-index lighting flags.

Lua exposure: LuaManager$Exposer.java:2320.

Restrictions/persistence: Not a complete viewport test and not a remote server guarantee.

Minimal runtime tests: R09; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public boolean isCouldSee(int playerIndex)` | [zombie/iso/IsoGridSquare.java:7884](evidence/decompiled/zombie/iso/IsoGridSquare.java#L7884) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public boolean isCanSee(int playerIndex)` | [zombie/iso/IsoGridSquare.java:7892](evidence/decompiled/zombie/iso/IsoGridSquare.java#L7892) | VERIFIED_SOURCE; runtime NOT TESTED |

## E09 — Zoom

Execution side: Local player-index zoom.

Lua exposure: LuaManager$Exposer.java:2005.

Restrictions/persistence: No remote maximum view envelope proved.

Minimal runtime tests: R09; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public float getZoom(int playerIndex)` | [zombie/core/Core.java:3264](evidence/decompiled/zombie/core/Core.java#L3264) | VERIFIED_SOURCE; runtime NOT TESTED |

## E10 — Audio playback candidates

Execution side: PlayWorldSound returns null on GameServer.server; client presentation required.

Lua exposure: LuaManager$Exposer.java:2615.

Restrictions/persistence: Square-based world sound is not verified moving flight audio; asset registration unverified.

Minimal runtime tests: R13; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public Audio PlayWorldSound(String name, IsoGridSquare source, float pitchVar, float radius, float maxGain, boolean ignoreOutside)` | [zombie/SoundManager.java:600](evidence/decompiled/zombie/SoundManager.java#L600) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public Audio PlayWorldSound(String name, boolean loop, IsoGridSquare source, float pitchVar, float radius, float maxGain, boolean ignoreOutside)` | [zombie/SoundManager.java:604](evidence/decompiled/zombie/SoundManager.java#L604) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public Audio PlayWorldSoundImpl(String name, boolean loop, int sx, int sy, int sz, float pitchVar, float radius, float maxGain, boolean ignoreOutside)` | [zombie/SoundManager.java:614](evidence/decompiled/zombie/SoundManager.java#L614) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public Audio PlayWorldSound(String name, IsoGridSquare source, float pitchVar, float radius, float maxGain, int choices, boolean ignoreOutside)` | [zombie/SoundManager.java:620](evidence/decompiled/zombie/SoundManager.java#L620) | VERIFIED_SOURCE; runtime NOT TESTED |

## E11 — Vanilla helicopter

Execution side: Native server/SP simulation; client update uses audio branch.

Lua exposure: No direct class registration found; UNKNOWN Lua exposure.

Restrictions/persistence: No Helicopter class exposure found; singleton integration unapproved; CFR update structuring warning.

Minimal runtime tests: R14; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public void pickRandomTarget()` | [zombie/iso/Helicopter.java:82](evidence/decompiled/zombie/iso/Helicopter.java#L82) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void setTarget(IsoGameCharacter chr)` | [zombie/iso/Helicopter.java:105](evidence/decompiled/zombie/iso/Helicopter.java#L105) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void update()` | [zombie/iso/Helicopter.java:128](evidence/decompiled/zombie/iso/Helicopter.java#L128) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public boolean isActive()` | [zombie/iso/Helicopter.java:341](evidence/decompiled/zombie/iso/Helicopter.java#L341) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void clientSync(float x, float y, boolean active)` | [zombie/iso/Helicopter.java:345](evidence/decompiled/zombie/iso/Helicopter.java#L345) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void save(ByteBuffer bb)` | [zombie/iso/Helicopter.java:357](evidence/decompiled/zombie/iso/Helicopter.java#L357) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void load(ByteBuffer bb, int worldVersion)` | [zombie/iso/Helicopter.java:364](evidence/decompiled/zombie/iso/Helicopter.java#L364) | VERIFIED_SOURCE; runtime NOT TESTED |

## E11 — Vanilla scheduling observations

Execution side: Scheduler references native singleton; setters deliberately not approved.

Lua exposure: LuaManager$Exposer.java:2607.

Restrictions/persistence: Getters provide limited timing; no custom crash hooks established.

Minimal runtime tests: R14; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public int getHelicopterDay()` | [zombie/GameTime.java:1249](evidence/decompiled/zombie/GameTime.java#L1249) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public int getHelicopterStartHour()` | [zombie/GameTime.java:1257](evidence/decompiled/zombie/GameTime.java#L1257) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public int getHelicopterEndHour()` | [zombie/GameTime.java:1265](evidence/decompiled/zombie/GameTime.java#L1265) | VERIFIED_SOURCE; runtime NOT TESTED |

## E12 — Safehouse membership

Execution side: Shared class; authoritative checks use server state.

Lua exposure: LuaManager$Exposer.java:2232.

Restrictions/persistence: Permission exemptions differ from claim ownership. Modified unclaimed bases remain unresolved.

Minimal runtime tests: R10; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public static SafeHouse getSafeHouse(IsoGridSquare square)` | [zombie/iso/areas/SafeHouse.java:179](evidence/decompiled/zombie/iso/areas/SafeHouse.java#L179) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static SafeHouse getSafeHouse(String title)` | [zombie/iso/areas/SafeHouse.java:183](evidence/decompiled/zombie/iso/areas/SafeHouse.java#L183) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static SafeHouse getSafeHouse(int x, int y, int w, int h)` | [zombie/iso/areas/SafeHouse.java:191](evidence/decompiled/zombie/iso/areas/SafeHouse.java#L191) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static SafeHouse getSafehouseOverlapping(int x1, int y1, int x2, int y2)` | [zombie/iso/areas/SafeHouse.java:199](evidence/decompiled/zombie/iso/areas/SafeHouse.java#L199) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static SafeHouse getSafehouseOverlapping(int x1, int y1, int x2, int y2, SafeHouse ignore)` | [zombie/iso/areas/SafeHouse.java:207](evidence/decompiled/zombie/iso/areas/SafeHouse.java#L207) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public boolean containsLocation(float x, float y)` | [zombie/iso/areas/SafeHouse.java:597](evidence/decompiled/zombie/iso/areas/SafeHouse.java#L597) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public static SafeHouse getSafeHouse(int onlineID)` | [zombie/iso/areas/SafeHouse.java:741](evidence/decompiled/zombie/iso/areas/SafeHouse.java#L741) | VERIFIED_SOURCE; runtime NOT TESTED |

## E13 — Loaded square candidate

Execution side: Server map lookup; direct Lua exposure not found.

Lua exposure: No direct class registration found; UNKNOWN Lua exposure.

Restrictions/persistence: No proof of safe remote loading or SP adapter.

Minimal runtime tests: R11; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public static IsoGridSquare getGridSquare(Vector3 v)` | [zombie/network/ServerMap.java:634](evidence/decompiled/zombie/network/ServerMap.java#L634) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public IsoGridSquare getGridSquare(int x, int y, int z)` | [zombie/network/ServerMap.java:638](evidence/decompiled/zombie/network/ServerMap.java#L638) | VERIFIED_SOURCE; runtime NOT TESTED |

## E14 — Tree damage candidate

Execution side: Shared class; WeaponHit tests GameClient.client; Damage can topple trees.

Lua exposure: LuaManager$Exposer.java:2267.

Restrictions/persistence: Generic deletion cannot replace lifecycle audit; all side effects/replication unverified.

Minimal runtime tests: R06; NOT TESTED.

| Exact signature | Snapshot source | Evidence status |
|---|---|---|
| `public void Damage(float amount)` | [zombie/iso/objects/IsoTree.java:239](evidence/decompiled/zombie/iso/objects/IsoTree.java#L239) | VERIFIED_SOURCE; runtime NOT TESTED |
| `public void WeaponHit(IsoGameCharacter owner, HandWeapon weapon)` | [zombie/iso/objects/IsoTree.java:271](evidence/decompiled/zombie/iso/objects/IsoTree.java#L271) | VERIFIED_SOURCE; runtime NOT TESTED |

## Supporting implementation observations

- Core.java:5235: GameVersion(42,21) confirms the current JAR version.
- IsoObject.java:1279/1446: metadata table deserialize/serialize paths.
- IsoGridSquare.java:5084-5144: native removal recalculates neighbors/roof checks, collision, PolygonalMap2, IsoRegions and rendering; audit specialized safe-removal expansion in IsoObjectUtils.java:49-110.
- IsoGridSquare.java:5269-5276: transmitAddObjectToSquare inserts and explicitly transmits on the server.
- GlobalModData.java:74-77: init loads then raises OnInitGlobalModData; 242-338 saves/loads global_mod_data.bin separately from object chunks.
- GlobalModData.java:132-172: transmit has both client and server branches. GlobalModDataPacket.java:58-73 raises OnReceiveGlobalModData; never wire this to accepting client registry data.
- GameTime.java:379-382 and 506-518: vanilla helicopter schedule; 1086-1088/1148-1150: schedule save/load.
- IsoWorld.java:644/3074: owned helicopter singleton and update; GameServer.java:1948-1958 and HelicopterPacket.java:51-54: server event presentation to clientSync.
- ChooseGameInfo$Mod.java:73-84 and ZomboidFileSystem.java:484-520: common/version resource roots and mod.info checks.
- Lua snapshots: SCampfireGlobalObject.lua:69-76 creates IsoObject and inserts it on the server script path; SPlantGlobalObject.lua:215 inserts plant object; SFarmingSystem.lua:571 removes through native transmission. These are call-site leads, not proof of generic wreck/container semantics.

## Audit reproduction and validation

CFR extraction command (PowerShell; research copies only), repeated for each member in class-manifest.json:

```powershell
$gameRoot = 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'
$auditRoot = 'C:\Users\willi\Desktop\Repositories\Project Zomboid\B47ANCEDHelicopterEvents'
$className = 'zombie/core/Core' # replace with each inventoried member without .class
$zipAudit = [System.IO.Compression.ZipFile]::OpenRead("$gameRoot\projectzomboid.jar")
$destAudit = "$auditRoot\docs\evidence\classes\$className.class"
New-Item -ItemType Directory (Split-Path $destAudit) -Force | Out-Null
[System.IO.Compression.ZipFileExtensions]::ExtractToFile($zipAudit.GetEntry("$className.class"),$destAudit,$false)
$zipAudit.Dispose()
& "$gameRoot\jre64\bin\java.exe" -jar ".tmp-nightfall-decompile\cfr-0.152.jar" $destAudit --outputdir "$auditRoot\docs\evidence\decompiled" --silent true
```

The Java process above runs CFR only; it does not launch PZ or a server. Snapshots must not be refreshed over historical evidence for a different build. An initial attempted packet path zombie/network/packets/GlobalModDataPacket.class was absent; its actual import is zombie/network/packets/service/GlobalModDataPacket.class, which was inspected.
