# Combat ordering, ownership changes and ordinary player damage

Date: 2026-10-15. Project version: [VERSION](../VERSION), unchanged at 0.1.0-dev.3. Baseline e63e5c05e861f27753835155e8f16fb733552621. Target Build 42.21 / Steam 25485521. **Verdict: NO-GO for a mutating dedicated combat probe.** This follow-up establishes native packet configuration and bounded counterexamples; it does not establish a safe Lua-only combat contract. No gameplay implementation or engine execution.

## Evidence and exact native surfaces

[COMBAT_ORDERING_SOURCE_INDEX.json](COMBAT_ORDERING_SOURCE_INDEX.json) fingerprints T01-T15 packaged members and any loose counterparts. The JAR SHA-256 remains e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33. T references below are native inspections, not approved Lua invocation recipes. Instruction offsets identify bytecode within the named method; annotations and constants are metadata. No bodies are redistributed. [The previous ownership/result index](OWNERSHIP_RESULT_SOURCE_INDEX.json) supplies O03/O08-O18/O22. The patched installation is not a clean runtime fixture; packaged classes do not prove actual loaded origins.

[VERIFIED: packaged configuration] T01 PacketTypes.PacketType.ClientCommand static initialization offsets 3750-3775 sets priority 1 and reliability 2. Its constructor chain supplies ordering channel 0; the full constructor stores priority/reliability/channel at offsets 14/20/26. T02 RakNetPeerInterface constants identify reliability 0 as UNRELIABLE, 1 as UNRELIABLE_SEQUENCED, 2 as RELIABLE and 3 as RELIABLE_ORDERED. The following are configured modes, not observed delivery results:

| Native route | Priority / reliability / channel | Meaning from named native constants |
|---|---|---|
| Lua command, either direction | 1 / 2 / 0 | Reliable, unordered |
| ZombieSimulationUnreliablePacket (T04) | 2 / 0 / 0 | Unreliable, not sequenced |
| ZombieSimulationReliablePacket (T05) | 0 / 2 / 0 | Reliable, unordered |
| ZombieSynchronizationUnreliablePacket (T06) | 2 / 0 / 0 | Unreliable, not sequenced |
| ZombieSynchronizationReliablePacket (T07) | 0 / 2 / 0 | Reliable, unordered |
| ZombieListPacket (T08) | 1 / 0 / 0 | Unreliable, not sequenced |
| PlayerHitZombiePacket (T09) | 0 / 3 / 0 | Reliable ordered |

T04-T09 use PacketSetting annotations; T01's class-based constructor reads those annotations. PacketType.send(IConnection):void offsets 23-36 forwards the stored settings to IConnection.endPacket(int,int,byte):void. T03 UdpConnection.endPacket(ByteBuffer,int,int,byte,Lock):void offsets 32-40 calls flipSendUnlock with those arguments; flipSendUnlock(ByteBuffer,int,int,byte,Lock):void offsets 5-22 forwards them to the native RakNetPeerInterface.Send(ByteBuffer,int,int,byte,long,boolean):int. The native DLL implementation/delivery was not executed or audited here.

T10 GameClient.sendClientCommand(IsoPlayer,String,String,KahluaTable):void selects ClientCommand at offset 8 and sends it at 166-172. T11 GameServer.sendServerCommand(String,String,KahluaTable,UdpConnection):void selects that same packet type at 6 and sends at 145-149. There is no separate reliable-ordered Lua result packet in these routes. T12 ZombieSynchronizationPacket.parse(ByteBufferReader,IConnection):void calls NetworkZombieSimulator.receivePacket at 42-47; write(ByteBufferWriter):void serializes queued ZombiePacket entries at 41-46. Selecting the reliable variant does not add a separate health-application contract.

[INFERRED] Channel zero alone cannot impose a common order across reliable-unordered commands, unordered/unsequenced zombie snapshots and ordered player hits. Ordered player hits from one sender also do not establish a global order across different peers, directions and local mutations. This is a transport configuration finding, not a measured packet trace. Custom Lua sequence numbers could order/deduplicate only messages interpreted by that custom handler.

## What ownership checks actually protect

[VERIFIED] T13 NetworkZombiePacker.parseZombie(ByteBufferReader,IConnection):void parses ZombiePacket, resolves the server zombie, compares getOwner() with the sending connection at 64-69 and rejects a mismatch through 88. A matching owner reaches private applyZombie(IsoZombie):void at 89-91; applyZombie reads health at 184, divides by 1000 at 191 and calls setHealth at 192. T14 ZombiePacket.parse(ByteBufferReader,IConnection):void reads its health short at 40-45. The inspected packet fields/acceptance path have no support-shot ID, Lua epoch, owner-lease generation or applied-damage watermark. Its update byte is optional-field flags, not a support-operation acknowledgement.

Consequently A's old snapshot is rejected while B is current owner. After A-to-B-to-A, identity equality alone accepts the same old A snapshot if it arrives then. A newly established connection is a different case; no claim is made that a disconnected peer's packet automatically matches a fresh connection. The counterexample concerns reuse of the same still-connected owner.

T15 NetworkZombieManager.moveZombie(IsoZombie,UdpConnection,IsoPlayer):void performs list/owner updates, limiter/timer resets and extra-update scheduling (O08). updateAuth(IsoZombie):void applies the 2000ms delay only to a non-null owner. Neither supplies a documented Lua lease. Existing client zombies becoming local are not assigned packet health by becomeLocal (O10). No native state-plus-watermark transfer, queue-drain barrier or pre-apply Lua fence was identified in these paths. **O-C01/O-C02/O-C04 remain unresolved.** Direct owner writes, repeated nulling, sleeping for 2000ms or Lua generation changes do not replace them.

## Preserving ordinary player damage

Ordinary player attacks must continue through their existing native Hit/result/death paths. O11 PlayerHitZombiePacket.setData(Object...):void requires an IsoPlayer; O14 HitCharacter.processServer(PacketType,UdpConnection):void relays then runs native processing; O15 WeaponHit.process invokes target.Hit with its final boolean true. This is a native player route, not permission to impersonate the requester, fabricate a packet or intercept and rebuild every player's damage in a separate Lua ledger.

A limited positive result is available: assuming one stable execution context, one shared current health value, nonlethal integer damage, no stale assignments and each operation applied exactly once, support delta S and player delta P commute: (H-S)-P = (H-P)-S. Local support-shot deduplication preserves this arithmetic under replay **within that same intact context**. This is [TESTED: offline abstract model], not a contract for native Hit, armor, reactions, critical hits, healing, death, disconnects or saves.

| Proposed correction | Bounded counterexample | Verdict |
|---|---|---|
| Set server-calculated absolute health | H=100, S=20, player first subtracts 10; set 80 erases the player's 10. | NO-GO |
| Set min(current,80) | Player first leaves 90 or 60; min leaves 80 or 60, whereas both deltas require 70 or 40. No upward heal still does not preserve the combined damage. | NO-GO |
| Apply delta then acknowledge | Old native snapshot 100 accepted after custom acknowledgement replaces 80. | No native fence established |
| Retry pending S at new owner | New baseline may already include S; retry duplicates it. | No inclusion marker established |
| Skip pending S at new owner | New baseline may lack S; skip loses it. | No inclusion marker established |
| Wait a fixed duration | An old unordered packet arriving after that duration remains eligible if its owner is current; no verified drain bound was found. | No barrier established |

A particularly useful ambiguous prefix uses H=100, S=20, P=20 and new-owner observed health 80. In history 1 that value includes S and a native P is pending; in history 2 it includes P and S is missing. Unconditional retry, skip and setting absolute 60 each fail in at least one history after pending P completes. A custom shot ID by itself cannot identify which native damage that baseline includes. These are counterexamples to those heuristics under stated pending-event assumptions, **not proof that every Lua protocol is impossible or that these histories were reproduced in PZ**. Additional verified native information/barriers could distinguish them; none was established here.

The reproducible project-owned [offline model](../scripts/audit_combat_interleavings.py) checks 28 named schedules: 17 preserve deltas under their explicit assumptions and 11 reproduce counterexamples. Exit success means those assertions agree with the model. It neither calls the engine nor tests RakNet, Kahlua, actual health scaling or native timing. The modeled transfer baselines are assumptions to challenge a proposal, not measured engine snapshots.

## Required contract before a mutating probe

1. Supported Lua entry and target lifecycle identity: distinguish a live target incarnation and server session, not only a recyclable online ID; validate every command against the actual connection. No suitable native lease entry established.
2. Per-target serialization/fence covering native owner health **and** legitimate player hits. Server controls target, ammo, RNG and damage; a client may only apply an exact approved result. Custom message ordering alone cannot fence native state.
3. A supported handoff that binds health and an applied-operation watermark, or an equivalent verified native operation path with stale-write rejection. Release/reassignment/disconnect must preserve player damage and distinguish applied, unapplied and uncertain support results.
4. Acknowledgement after authoritative native acceptance/publication, not merely after Lua callback execution. Pending-state recovery must distinguish effect from receipt across lost acknowledgements, reconnects and non-atomic saves. A persistent custom ledger alone cannot make native health plus receipt atomic.
5. Native player damage, reactions, attribution and single death/corpse lifecycle retained; no health clamping, continuous correction, player-hit suppression or client outcome authority.
6. Then actual clean dedicated evidence, separately recorded patched compatibility evidence, at least two clients and adversarial schedules from [the dedicated plan](SUPPORT_MP_TEST_PLAN.md). No offline result grants that permission or PASS.

**GO:** further read-only inspection and this offline counterexample analysis. **CONDITIONAL:** owner-side delta application as a research candidate only if all contracts above are supplied. **NO-GO:** mutating combat probe and complete armed support under the currently established APIs. There is no safe protocol to implement from these findings. Freeze new support dispatch before an unresolved mutation; quarantine uncertain results without replay/refund/absolute-health correction. Quarantine contains future work, cannot undo already-applied damage and does not establish exactly-once effects.

The smallest later Lua-only diagnostic remains non-mutating ownership/API observation after separate authorization; it cannot close the native fence by itself. An audio-only call would be a scope change requiring review, not completion of the requested armed feature. MS01-MS03 remain independent blockers. G-R01..10/S-R01..24 NOT TESTED; G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. Stop here for findings review.
