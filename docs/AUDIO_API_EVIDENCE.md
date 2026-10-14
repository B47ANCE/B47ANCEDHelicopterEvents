# Audio API evidence - 2026-10-14

Target: installed projectzomboid.jar Build 42.21. Inspection only; no Lua implementation or engine launch. Project version is ../VERSION. JAR SHA-256: e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33. This local fingerprint does not authenticate a clean vanilla depot.

Earlier hashed decompiled snapshots were read where available. Newly inspected classes were read directly from the installed JAR using an in-memory Python standard-library classfile reader (constant pool, descriptors and instruction references); no extracted bytecode, decompiled implementation or custom Java was published. Offsets below are JVM bytecode offsets within the named method, not source line numbers. Lua overload resolution and runtime semantics remain NOT TESTED.

| Surface | Exact signature / source reference | Source-backed observation |
|---|---|---|
| Lua exposure | zombie/Lua/LuaManager$Exposer.exposeAll | Registers IsoWorld, BaseSoundEmitter, FMODSoundEmitter, GameTime and SandboxOptions. Class registration does not prove every overload's Lua resolution. |
| Acquisition | IsoWorld.getFreeEmitter(float,float,float); initial local IsoWorld.java:791 | Positions a pooled/new emitter. getFreeEmitter() sets playRemoteEvents false and adds it to the world's currentEmitters. |
| Ownership | void IsoWorld.takeOwnershipOfEmitter(BaseSoundEmitter); void returnOwnershipOfEmitter(BaseSoundEmitter); initial local IsoWorld.java:797-834 | Remove from native current list; return to free pool if empty or current list if still active. Do not retain references after return. |
| World ticking | IsoWorld.updateInternal; initial local IsoWorld.java:3083-3099 | Ticks current emitters, clears parameters/recycles empty emitters. This is why stale pooled references are unsafe. |
| Local operations | BaseSoundEmitter: void setPos(float,float,float), void tick(), boolean isEmpty(), boolean hasSoundsToStart(), boolean isPlaying(long), void stopSoundLocal(long), void stopAll() | Exposed lifecycle surface, including queued-start handling. Emitter release and audible tails need runtime tests. |
| Safe playback candidate | long FMODSoundEmitter.playSoundImpl(String,boolean,IsoObject), offset 3 delegates to playSoundImpl(String,IsoObject) | Three-argument overload avoids square/object nil ambiguity. Inspected overload ignores its boolean. Local path selects clip/addSound; no inspected wrapper native sound send. |
| Unsafe wrapper for this design | long FMODSoundEmitter.playSound(String), offset 104 calls GameClient.PlayWorldSound(String,int,int,byte); other branch sends PlaySound | Ordinary wrappers can rebroadcast client audio. setPlayRemoteEvents(false) is not a transport guard. |
| Loop caveat | long FMODSoundEmitter.playSoundLoopedImpl(String), offset 4 delegates to three-argument playSoundImpl | Function name alone does not force looping. Verify asset/event loop properties. |
| Stop caveat | int FMODSoundEmitter.stopSound(long); private sendStopSound(String,boolean) | Native stop wrapper has a client send path for moving-object parents. Local-only handle stop is the candidate. |
| Timeline | void BaseSoundEmitter.setTimelinePosition(long,String) | String marker API, not arbitrary numeric seek. No sample-phase resume promise. |
| Time | static long GameTime.getServerTimeMills(); static boolean getServerTimeShiftIsSet(); initial local GameTime.java:207-228 | Monotonic server nanos converted to ms; unsynchronized client and SP return zero. |
| Local wall clock | static long LuaManager$GlobalObject.getTimestampMs(); initial local GlobalObject.java:5415-5417 | System.currentTimeMillis; not synchronized across clients/server. |
| Options loading | CustomSandboxOptions.init(), instruction offsets 50/104; path constant media/sandbox-options.txt | Selected version path first, common fallback. |
| Option types | CustomSandboxOptions.parseOption(ScriptParser.Block); CustomIntegerSandboxOption.parse(ScriptParser.Block) | boolean/double/enum/integer/string types; integer min/max/default; common page/translation fields. No assumed custom step field. |
| Lua values | void SandboxOptions.toLua(); SandboxOption.toTable(KahluaTable) | Export options into SandboxVars, including custom namespace table. |
| Server startup | GameServer initialization; local GameServer.java:1611-1655 | CustomSandboxOptions initialized before server Lua configuration/toLua. |
| Initial sync | ConnectionDetails.writeSandboxOptions(ByteBufferWriter), offset 7: SandboxOptions.save(ByteBuffer) | Server configuration serialized to connecting client. |
| Client sync | ConnectToServerState.receiveSandboxOptions(ByteBufferReader), offsets 7/13/19 | load, applySettings, toLua. GameClient.receiveSandboxOptions repeats the path for updates. |
| Admin update | PacketTypes$PacketType.SandboxOptions; local :629 | Capability.SandboxOptions authorization; arbitrary audio sync requests cannot change options. |
| Client request | void sendClientCommand(IsoPlayer,String,String,KahluaTable); initial GlobalObject.java:5166 | Server receives OnClientCommand(module,command,player,args) using connection-associated identity. Native ingame/readiness conditions matter. |
| Server presentation | void sendServerCommand(IsoPlayer,String,String,KahluaTable); initial GlobalObject.java:5192 | Wrapper sends only when GameServer.server. OnServerCommand(module,command,args) has no local slot argument. |
| Registered lifecycle events | LuaEventManager.AddEvents(), offsets 14/21/42/427/434/560/973/980/1078 | OnTick, OnTickEvenPaused, OnGameStart, OnConnected, OnDisconnect, OnMainMenuEnter, OnClientCommand, OnServerCommand, OnServerStarted exist. |
| Ready ordering | ConnectToServerState.receiveWorldDictionary:8; IngameState.updateInternal:1283/1331 | OnConnected occurs in setup. Normal ingame update calls UpdateStuff before onTick; UpdateStuff sets GameClient.ingame. Do not handshake directly in OnConnected. |
| Vanilla asset | media/scripts/generated/sounds/sounds_meta.txt:3-10 | Helicopter -> Meta/Helicopter, distanceMax 1000. Native Helicopter.updateSound uses specialized FMOD/high-altitude/occlusion handling, not proof that general emitter playback sounds equivalent. |

## Provenance fingerprints

| JAR member | SHA-256 |
|---|---|
| zombie/audio/BaseSoundEmitter.class | 1722f6d493ab55e0787b25bd1719fd10b8ccdb13ad7cbca9df51ec1c49b125d5 |
| fmod/fmod/FMODSoundEmitter.class | 286438aff564851f2a349bb290fe233efa12748d6711e5bef0924d4828a63bb6 |
| zombie/SandboxOptions.class | d90458506ab559c7d9b84588a1a62a78ceb7b4c6303bb2127d823fc21c4e7297 |
| zombie/sandbox/CustomSandboxOptions.class | 80d7d66b1bd7dda3877fa2edca2b136442208c4edc9f178e210130feaf0c4166 |
| zombie/gameStates/ConnectToServerState.class | d7a0779d8ccf993cbc1f717c37194595273f1aee8bfc3ee4b20dd93c0fc55ce4 |

[VERIFIED: source] Existing loose FMODSoundEmitter, GameTime and LuaEventManager differ from JAR members. Ten loose zombie classes changed since the earlier inventory, including IsoObject and render classes. Earlier snapshot integrity is not current patched-runtime equivalence. No patched implementation was adopted. No claim of clean provenance or network/audio runtime verification.

Initial private source bundles remain local and ignored. Missing private snapshots in a public clone are unavailable evidence, not a reason to manufacture a source PASS. The public report records observations/signatures, not redistributed game implementation. Every functional conclusion remains tied to the dedicated tests in RUNTIME_TEST_PLAN.md.
