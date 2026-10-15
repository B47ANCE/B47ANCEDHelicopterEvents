# Gunner ownership and result path audit

Date: 2026-10-15. Version: [root VERSION](../VERSION), unchanged at 0.1.0-dev.3. Baseline 88443396b76781a95635a25ce41eab2323fca72e. Target packaged Build 42.21 / Steam 25485521. **Verdict: NO-GO for a mutating dedicated combat probe. No complete supported Lua ownership/result path was established.** This is a bounded source finding, not proof that every future Lua approach is impossible. No gameplay implementation, actor construction, hit, packet transmission or engine launch.

## Evidence boundary

Read alongside [the Lua alternatives investigation](DOOR_GUNNER_LUA_FEASIBILITY.md). [OWNERSHIP_RESULT_SOURCE_INDEX.json](OWNERSHIP_RESULT_SOURCE_INDEX.json) identifies O01-O24 native members, L01 installed Lua caller, hashes and targeted loose-class comparisons. The packaged JAR remains SHA-256 e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33; Steam build ID was rechecked. References below are JVM instruction offsets in the exact named method, not Java source lines. Raw javap output remains private/ignored. No class was instantiated or loaded into PZ by this audit.

[VERIFIED] means inspected packaged bytecode or installed Lua text. [INFERRED] identifies suitability or ordering implications. [UNKNOWN] marks missing supported access/contract. Every engine/dedicated outcome is [RUNTIME GATE] / NOT TESTED. The modified installation is not a clean fixture; packaged evidence does not identify the class actually loaded by its patched launchers. Existing clean/patched provenance gates remain unchanged.

## Ownership: the engine has a handoff, but no Lua lease was found

[VERIFIED] O08 NetworkZombieManager exposes native static NetworkZombieManager getInstance() and void moveZombie(IsoZombie,UdpConnection,IsoPlayer). For a live target, moveZombie offsets 150-158 return immediately if the requested owner equals the current owner. Offsets 159-300 maintain old/new ownership-list membership under a lock, assign owner/player, reset speed limiter and the new connection's send timer. Offsets 301-311 record lastChangeOwner and set a packer extra update. These are the native operations a direct setOwner(nil) omits.

[VERIFIED] O08 void updateAuth(IsoZombie) offsets 7-29 apply the 2000ms reassignment delay **only while the owner is non-null**. An owner cleared to null falls through immediately. Offsets 201-328 may choose the connection of a grappling/targeted player; subsequent branches choose by connection relevance/distance. The switchZombiesOwnershipEachUpdate option selects another ownership algorithm, not a server-only ownership mode: false continues into normal assignment. Neither this delay nor that option supplies a protected server lease. No server setting was changed.

The supported-access search was bounded and reproducible:

- O19 LuaManager.Exposer.exposeAll explicitly registers IsoZombie at offset 891, iterates its registered classes at 6976-7011 and exposes annotated GlobalObject functions at 7014-7022. NetworkZombieManager, NetworkZombiePacker, GameServer and hit-packet types are absent from that explicit class list. shouldExpose(Class) offsets 6-14 checks membership. This does not by itself prove that an object could never be returned through another exposed path.
- A constant-pool reference scan of all packaged class members found NetworkZombieManager references only in IsoZombie, UdpEngine, GameServer, NetworkZombiePacker and the manager itself. This is a reference inventory, not an inferred full call graph. Targeted method inspection found no returning-manager getter in those other four classes.
- O04 IsoZombie.removeFromWorld offsets 174-200 invokes the manager's null handoff when a removed zombie has an owner/player. It also removes the zombie through VirtualZombieManager and clears other world state. Removing a living target is not a lease or a safe combat adapter.
- O23 UdpEngine.removeConnection(long) offsets 170-176 and O03 GameServer.disconnectPlayer(IsoPlayer,IConnection) offsets 130-135 clear target authorization during disconnection. Disconnecting players is not a per-target ownership API. No connection was changed.
- O09 packer updateAuth is private and calls the manager during normal processing; its parseZombie has no Lua callback around the accepted owner-health assignment. No pre-apply Lua rejection/fence hook was found in the inspected manager/packer paths.

[UNKNOWN] A supported Lua root for the manager, a bounded lease that survives updateAuth, and a native release/reassignment barrier remain missing. Reflection, class imports through a bridge, added bindings, packet hooks in custom Java, or requiring installed class overrides are excluded. Repeatedly writing owner fields cannot replace those contracts.

## Result delivery: promising names do not publish arbitrary server hits

| Exact surface | Source result | Verdict for this gunner |
|---|---|---|
| void NetworkCharacterAI.syncHealth(); void syncDamage() | O07 each body is only offset 0: return. O06 NetworkZombieAI has no overriding implementation in this build. | [VERIFIED] Empty inherited methods; no zombie result transport. |
| void NetworkCharacterAI.setLocal(boolean) | O07 offsets 0-5 assign wasLocal only. | No server ownership transfer, native packet barrier or result send. |
| void NetworkZombieAI.extraUpdate() | O06 offsets 0-10 call NetworkZombieSimulator.addExtraUpdate(zombie); O10 queues only if owner equals GameClient.connection. | Client-owner send scheduling, not arbitrary dedicated server health publication. |
| void GameServer.sendHitCharacter(HitCharacter,PacketTypes.PacketType,UdpConnection) | O03 offsets 34-44 dereference/exclude the source connection; 47-82 relay to relevant other connections. | Native relay for an existing source packet; nil source is unsafe and a real source cannot be fabricated. No exposed generic server-origin NPC hit entry established. |
| void HitCharacter.processServer(PacketType,UdpConnection); processClient(UdpConnection) | O14 server offsets 0-25 log/update, relay then execute processClient. Client offsets 0-30 call preProcess/process/postProcess/attack/react. | Native real-combat result processing exists. The envelope, attacker and authority contract still must match; invoking an interface default is not a new Lua transport. |
| void PlayerHitZombiePacket.setData(Object...); set(IsoPlayer,HandWeapon,boolean,List<TracerInfo>,List<WeaponHit>,IsoZombie,boolean) | O11 setData casts argument 0 to IsoPlayer at offset 4. O12 processHits dispatches each WeaponHit to the target. O15 WeaponHit.process calls target.Hit with the final boolean true at 79-98. | Real-player result route; neither a survivor nor the native hit proxy is a valid player wielder. Do not attribute aircraft fire to the requester. |
| static void LuaManager.GlobalObject.sendHitZombie(IsoPlayer) | O01 offsets 0-3 require GameClient.client; loops client zombies and creates ZombieHitPlayerPacket at 44-85. | Wrong direction: zombies hitting a player, not publishing support damage to zombies. Never invoke it as a gunner broadcast. |
| static void GameClient.sendPlayerHit(IsoGameCharacter,IsoObject,HandWeapon,boolean,List<TracerInfo>,List<WeaponHit>,boolean) | O22 requires client/local actor at 0-14, chooses PlayerHitZombie at 165-218. That packet has the IsoPlayer cast above. | General parameter type does not make its zombie branch accept a native survivor/proxy or become a dedicated send path. |

O16 fields.hit.Character and O17 fields.hit.Zombie encode/process reaction, position and flags. They do not establish a general server health snapshot API. O18 ZombiePacket carries health; O09 server parseZombie accepts the current owner then applyZombie writes health/1000. O10 client parseZombie assigns packet health only in the new-object branch; the existing-object branch uses O06 NetworkZombieAI.parse without a health assignment. Normal owner-list changes are also insufficient: O10 added() calls becomeLocal on existing newly authorized zombies; becomeLocal offsets 0-34 set owner/player/path state, not health. A handoff does not by itself prove the new owner starts with the server's nonlethal result.

The generic object-change route was checked too. O05 IsoGameCharacter.saveChange/loadChange handle typed IsoObjectChange branches including SHOVE, random damage **from** a zombie, kill-count and UI actions. O04 has no zombie-specific saveChange/loadChange override in the inspected class; O21 IsoMovingObject inherits the O20 IsoObject implementation, which handles object/container/sprite changes. No arbitrary zombie health/hit result branch was found in this hierarchy. SHOVE/reaction updates must not be relabeled as ranged damage synchronization. No invented string change type is proposed.

## A better attacker helper, independent of the ownership blocker

[VERIFIED] O01 exposed global IsoGameCharacter getFakeAttacker() offsets 0-9 returns getCell().getFakeZombieForHit(). O02 IsoCell.getFakeZombieForHit():IsoZombie offsets 0-23 lazily constructs and caches one IsoZombie. L01 media/lua/server/ClientCommands.lua:861-902 uses getFakeAttacker() for privileged animal kill commands; those commands also change health and send animal-specific messages. Their existence is source-backed server-side use, not evidence that this route synchronizes zombie ranged combat.

This is the engine's own shared hit proxy, not a forged player identity or a custom Java dependency. It may be a smaller attacker-context candidate than an allocated survivor. It is **not mod-owned**: never despawn/remove it, assign a fake online ID, permanently repurpose its inventory/weapon, or assume exclusive access. Native callbacks/reentrancy, position/direction, critical state, shared kill accounting and lingering attackedBy references require review. Saving/restoring a few fields around Hit is not a demonstrated isolation contract.

O24 IsoTrap.explosion(IsoGridSquare) offsets 0-23 uses the same fallback attacker, then 88-124 calls Hit. This is a real vanilla use, but its private area-effect path includes random damage/fire and client-specific processing. It is not a safe single-target machine-gun or ownership/result adapter. No trap/explosion was created, and no explosive substitute is proposed. The attacker subproblem has a better lead; MS04's ownership/result gap remains.

## Why a custom Lua acknowledgement alone cannot close the gap

[INFERRED from O09/O18] The inspected acceptance path checks owner identity and applies health; it has no support-shot ID or Lua lease generation comparison. Consider this ordering, even if an application-level result message is reliable:

1. Native owner A queues health 1.0 before the shot.
2. Server applies 0.3 damage and sends a Lua result; A applies/acknowledges health 0.7.
3. The old native health 1.0 packet arrives while A is the current owner, and the native receiver accepts it.

A Lua acknowledgement proves receipt of the Lua operation, not drainage/rejection of an independent native queue. If A was temporarily unowned, reassigning A before that old packet arrives permits the same replacement. Fixed sleeps, timestamps solely in custom commands, retry deduplication, stopping a Lua timer, or temporarily changing a client's wasLocal flag do not add the missing native fence. Delayed ordinary player hits and an A-to-B-to-A ownership cycle must compose too. No supported native barrier/order guarantee establishing otherwise was found. A model of this ordering is offline reasoning, not a measured runtime failure.

## Contract decision and next permitted work

Subsequent [clean-room NPC comparison](THIRD_PARTY_RESEARCH.md) inspects A-Life, Remnants and Bandits. It finds delegated client execution/custom NPC health and an excluded Java-agent surface, not a verified native ownership/result fence for our server-decided hits on ordinary zombies. The source-backed existence of NPC gunfire does not close O-C01..06. Owner-side application of server-approved results remains a research candidate; no client outcome authority, code import or combat probe is approved.

| Contract | Current source status | Must exist before mutating probe |
|---|---|---|
| O-C01 Supported Lua ownership entry | UNKNOWN; native manager exists, no supported root identified. | Exact exposed receiver/call or equivalent verified native pathway. |
| O-C02 Lease and stale-write fence | Not established; null owner bypasses the reassignment delay. | Rejection of stale native writes during acquisition, hit and release, including same-connection reuse. |
| O-C03 Server-origin nonlethal result | Not established; sync methods empty, player packets require player identity. | Ordered native owner/observer result application without invented player attribution or repeated health enforcement. |
| O-C04 Concurrent combat and reassignment | Not established. | Legitimate native player damage preserved in either order; damaged state retained by every subsequent owner. |
| O-C05 Attacker and lethal lifecycle | CONDITIONAL helpers; NOT TESTED. | Safe native proxy/context use, attribution, one native corpse/death callback and no shared proxy corruption. |
| O-C06 Dedicated evidence | NOT TESTED. | Clean dedicated, two clients, latency/ownership changes/reconnects, then separate patched compatibility results. |

No complete supported path can currently be specified. **Do not implement the mutating combat probe.** Existing G-R01..10 and S-R01..24 remain NOT TESTED; no gate is relaxed. Stop source-backed gameplay work at this boundary rather than switch combat authority to clients.

Fail-closed Lua-only work still possible after review: a non-mutating diagnostic can observe existing target ownership/AI state and server/client API availability without changing owner, health, proxy or items. It can establish actual binding/side observations but cannot prove a fence or qualify as armed-support validation. A new build exposing a suitable native result/ownership API could be audited separately. Neither alternative silently changes the complete release requirement. MS01-MS03 remain independent blockers; G7 BLOCKED / NOT TESTED, stable-release G8 BLOCKED.
