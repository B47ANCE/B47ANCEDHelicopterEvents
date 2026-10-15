# Lua-only gunner blocker investigation

Date: 2026-10-15. Project version: [root VERSION](../VERSION), unchanged. Baseline 8fefbe0f90b9ccdab0f1d6339d62f7c35b3d8611 (Military Support audit PR #5). Target: packaged Build 42.21 / Steam 25485521. **A native survivor attacker is a CONDITIONAL diagnostic candidate. Complete dedicated armed support remains NO-GO pending the ownership/replication/lifecycle contracts below.** No actor, hit, weapon, network message or game/server was created/executed by this investigation.

## What the follow-up establishes

The previous MS04 result is not proof that Lua lacks every usable native attacker. A real vanilla IsoSurvivor could satisfy the non-null attacker parameter without inventing a player connection. Tracing beyond Hit confirms a native damage/death path. That is meaningful progress, but the same trace establishes a specific client-owner health overwrite race. Supplying an attacker alone does not close MS04.

Use [GUNNER_SOURCE_INDEX.json](GUNNER_SOURCE_INDEX.json) for G01-G19 member fingerprints, targeted loose-class comparisons and L01 vanilla Lua caller fingerprint. JAR SHA-256 e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33 still matches the earlier audit; installed Steam build ID was rechecked. Native references are **JVM offsets inside the named method**, not Java line numbers. Earlier Exposer source line references identify the private initial decompile, whose packaged baseline is unchanged. Class registration/caller text is source evidence; no constructor/overload was invoked through Kahlua. [VERIFIED] here means inspected source/binary branches; candidate suitability is [INFERRED], unresolved access is [UNKNOWN], and dedicated behavior is a [RUNTIME GATE]. Patched runtime and clean-depot provenance remain separate gates.

## 1. Genuine native actor candidates

| Exact native surface | Source finding | Implication / limit |
|---|---|---|
| IsoSurvivor(IsoCell); IsoSurvivor(SurvivorDesc,IsoCell,int,int,int); IsoSurvivor(SurvivorDesc,IsoCell,int,int,int,boolean) | G01 concrete final subclass of IsoLivingCharacter. Initial Exposer snapshot:1975 registers it. Cell-only constructor offsets 39-50 enroll in survivor list and trigger OnCreateSurvivor. Descriptor constructors also invoke creation/dress events. | A genuine vanilla candidate, not a Java dependency. Constructor effects must be audited before allocation; an object is not inert just because it is invisible. |
| static SurvivorDesc SurvivorFactory.CreateSurvivor(); static IsoSurvivor InstansiateInCell(SurvivorDesc,IsoCell,int,int,int) | G02; factory registered Exposer:1950. InstansiateInCell offsets 1-14 constructs descriptor-based IsoSurvivor and binds descriptor instance. | Descriptor creation is not itself spawning an actor. The intentionally misspelled native InstansiateInCell name is exact. Runtime constructor resolution remains NOT TESTED. |
| IsoLivingCharacter(IsoCell,float,float,float) | G03 concrete class; inherits character behavior. No explicit direct class registration found in the bounded Exposer inspection. | Additional candidate only if its actual Lua constructor binding can be established; public native constructor alone is insufficient. Do not invent a global class or use a bridge/import to expose it. |
| IsoGameCharacter(IsoCell,float,float,float) | G04 is **abstract** despite its public constructor and class registration. | Not a directly instantiable vanilla attacker. No Lua/Java subclass workaround is authorized. |

The best candidate to investigate is **one server-only native survivor used as attacker context**, with the Lua director owning target choice, misses, ammunition, fire timing and flight coordinates. This may avoid a replicated, animated NPC and its autonomous attack state. [VERIFIED: installed Lua] L01 media/lua/client/OptionScreens/LastStandPlayerSelect.lua:67-75 creates a fresh descriptor and calls IsoSurvivor.new(newDesc,nil,0,0,0) for a preview avatar. This is an actual Lua call form, not just native registration. It is client UI evidence, not a dedicated-server combat/lifecycle guarantee.

G04 constructor offsets 1114-1138 enroll nonzero-position characters in the cell moving-object list. The vanilla preview caller makes detached context research more credible, but does not prove moving such a context to flight coordinates is safe or avoids enrollment in every later path. Do not use off-map parking as an assumed lifecycle exemption. Use a fresh descriptor, never rebind the requesting player's descriptor to an attacker context. Server construction, required attacker position semantics and full cleanup remain [UNKNOWN]/[RUNTIME GATE].

There is no physical helicopter parent in the existing simulated design. A future validated actor would follow server-computed coordinates, not attach to a nonexistent native aircraft object. G17 IsoMovingObject.ensureOnTile offsets 0-45 removes a survivor with no current square from the cell/survivor list. Simply assigning an airborne z or teleporting an actor does not establish valid squares, movement enrollment or physics safety. No claim of mounted ballistics or roof penetration follows from matching coordinates.

## 2. Native damage/death: a positive source result

G05 IsoZombie.Hit(HandWeapon,IsoGameCharacter,float,boolean,float,boolean): offsets 56-60 require a non-null attacker; 92-107 set attacker hit state and call base Hit. G04 IsoGameCharacter.Hit with the same arguments rejects null weapon/attacker at offsets 0-9, computes damage at 261 and calls hitConsequences at 275. Thus a genuine suitable native character could resolve the original nil-attacker issue.

Exact downstream surface: **void IsoGameCharacter.hitConsequences(HandWeapon,IsoGameCharacter,boolean,float,boolean)**. G04 offsets 0-21, when damage is not ignored, apply native global damage reduction and CombatManager.applyDamage(this,damage). G06 CombatManager.applyDamage(IsoGameCharacter,float) checks invulnerability then delegates to G04 applyDamage(float), which subtracts/clamps health at offsets 0-24. Native hitConsequences offsets 24-80 checks death, updates the attacker's zombie-kill count and calls die() on server at 62. Native die/Kill/onKilled/corpse paths are retained in the [combat audit](DOOR_GUNNER_COMBAT_AUDIT.md).

This is stronger than an unsupported direct health assignment: the traced Hit route includes native hit consequences. It still is not a proved dedicated adapter. Melee-only XP branches in hitConsequences cast to IsoPlayer (offset 124), while the nonlethal ranged branch returns at 102; future tests must use an actual validated ranged weapon/configuration and cannot assume every branch accepts a survivor. Do not flip native flags or choose an explosive weapon merely to evade an incompatible branch.

Hit also has observable side effects before damage: G04 offsets 115-155 trigger OnWeaponHitCharacter, OnPlayerGetDamage and WeaponHitCharacter hooks; 226-230 call attacker.addWorldSoundUnlessInvisible(5,1,false); 233-241 calculate hit direction and assign attackedBy. The exact void addWorldSoundUnlessInvisible(int,int,boolean) body returns for an invisible actor, otherwise calls WorldSoundManager.addSound using the attacker's floored x/y/z. A detached context left at origin could therefore misplace sound/direction, and a hiding cheat could change attraction. These semantics must be proved alongside context positioning and the separately budgeted server gunfire sound; a preview actor is not side-effect-free combat context.

Full autonomous shooting has additional hazards. G06 CombatManager.processHit(HandWeapon,IsoGameCharacter,IsoGameCharacter) has a SHOT-reaction branch casting the attacker to IsoPlayer at offset 41. G03 DoAttack(float) can dereference getEmitter at 566-577; G04 construction explicitly assigns a null character emitter for IsoSurvivor at 1109-1111. These are conditional native branches, not proof every call fails; they are enough to reject assuming DoAttack is a generic headless NPC gunner API. The narrower direct-Hit candidate must not automatically invoke the whole animated/player attack pipeline.

## 3. The decisive multiplayer race

G07 **NetworkZombiePacker.parseZombie(ByteBufferReader,IConnection)** offsets 64-88 compare the incoming connection to zombie.getOwner(), reject/recheck mismatches, then at 89-91 call private applyZombie(IsoZombie) for the accepted current owner. That method offsets 179-192 reads ZombiePacket.health, divides by 1000 and calls setHealth. An accepted owner snapshot can therefore replace server-side health independently of a support hit.

Counterexample: owner A sends health 1.0; Lua server Hit reduces it to 0.7; A's queued snapshot is accepted while A remains owner; server health becomes 1.0. Killing a target instead is not a complete fix: death/removal ordering and queued packets need proof, and forcing every successful shot lethal changes the required damage model. A pure offline ordering model reproduced this cut and the effect of a hypothetical owner fence; it is not a game test, measured runtime failure or tested solution.

Nonlethal publication is also unresolved. G08 NetworkZombieSimulator.parseZombie is private: offsets 49-51 branch around creation when an existing client zombie is present; the health assignment at 356-367 is in the **new-zombie creation branch**. G11 NetworkZombieAI.parse(ZombiePacket) updates movement/targets/flags, with no health assignment in the inspected body. Ordinary movement/extra-update traffic must not be assumed to apply a server's arbitrary nonlethal hit to an already existing owner/observer zombie. Inspect and test the exact supported hit-result route, not just packet names.

### What a real ownership solution would require

G09 native **NetworkZombieManager.moveZombie(IsoZombie,UdpConnection,IsoPlayer)** exists. Its live-zombie path maintains ownership-list membership under a lock, calls setOwner/setOwnerPlayer, resets speed limiter, records lastChangeOwner and marks the packer for an extra update. Native updateAuth can select/reselect owners. This is a promising engine mechanism to trace, but no supported direct Lua entry/returned-manager binding or bounded server-ownership lease was established here; the manager is not explicitly registered in the inspected Exposer list. This is a bounded access finding, not a claim that no engine path could ever return it.

G05 IsoZombie.setOwner(UdpConnection) delegates through NetworkZombieComponent. G10 NetworkZombieComponent.setAuthOwner simply assigns the field at offsets 0-5. Setting owner=nil is **not equivalent** to G09's complete manager handoff, does not update all ownership lists or stop later automatic reassignment, and does not publish a native hit result. Reassigning the old owner while it retains stale health can reintroduce the race.

G08 NetworkZombieSimulator.addExtraUpdate(IsoZombie) queues only when zombie.getOwner()==GameClient.connection (offsets 13-43); it is not an unconditional server health-broadcast function. G08 becomeLocal(IsoZombie) also uses GameClient.connection, so its name does not mean a safe dedicated ownership lease. Neither is an approved shortcut.

A viable Lua adapter must demonstrate: a supported ownership/barrier route for the exact loaded target, rejection of queued stale-owner writes, canonical server damage that composes with concurrent ordinary combat, ordered replication of nonlethal results to current/future owners and observers, and safe release/reassignment. All parts are required; repeatedly forcing health/owner fields each tick is not a proof.

## 4. Visibility, identity and cleanup

G04 setInvisible(boolean) checks ToggleInvisibleHimself capability before setting a cheat flag. Its two-argument overload can bypass that check when the second flag is true; that does not establish render-only semantics or approval to impersonate a privileged player. G18 setAlpha(int,float) immediately returns on GameServer.server and is per-player client presentation. A server alpha assignment does not hide an actor from every client or split-screen listener. Prefer proving a strictly server-only context lifecycle over assuming an invisible replicated actor.

G12 **CharacterID.set(IsoGameCharacter)** encodes animal/player/zombie cases at offsets 0-83; there is no IsoSurvivor case in this method. G15 DeadCharacterPacket includes both victim and killer CharacterID fields; setData encodes body's getKilledBy at offsets 90-98. An unrepresented survivor killer is an attribution/interoperability gate, not proof every corpse packet is rejected. No fake player ID or client connection may be assigned to make it look supported.

G18 IsoObject's generic factory does recognize Survivor for object construction/save-load; that observation does not supply a full actor replication, combat identity or ownership protocol. G01 Despawn() only clears descriptor.instance (offsets 0-15). G17 removeFromWorld/removeFromSquare handle moving/scheduler/square collections, and ensureOnTile handles another survivor-list path. No single observed call proves complete actor cleanup, safe construction failure recovery, or absence of orphan save/restart state. Test all of them before any usable actor prototype.

## 5. Lua-only route comparison

| Route | Verdict | What it resolves / why it does not clear MS04 yet |
|---|---|---|
| Full invisible survivor following helicopter and calling DoAttack | NO-GO as implementation contract | Real actor exists, but animated attack branches, null emitter, valid squares, client visibility, actor identity and replication are unproved. |
| Native survivor as minimal server-only attacker; Lua schedules validated ranged Hit | **CONDITIONAL isolated diagnostic; preferred actor candidate** | Source supports attacker parameter plus native health/death consequences. Still needs safe allocation/cleanup, owner barrier and hit-result publication; no combat is authorized now. |
| Concrete IsoLivingCharacter context | UNKNOWN Lua availability | Could avoid survivor-specific behavior, but direct supported Lua construction is unestablished. Abstract IsoGameCharacter cannot replace it. |
| Direct applyDamage/setHealth plus die/Kill | NO-GO for complete feature | applyDamage alone mutates health and clamps it; it does not reproduce the whole ranged-hit/event/replication contract. Owner race remains. |
| Native target handoff/lease then native Hit/result replication | CONDITIONAL research; no working Lua adapter established | Best avenue for the actual authority gap. Must expose an already supported native route and prove full handoff, publication and return; owner-field writes alone do not count. |
| Forge a player/NPC connection or send player-hit packets using a fabricated shooter | NO-GO | Existing player packet requires real player/weapon identity; fake IDs or Java-added bindings are excluded. A copied vanilla player reference is not an aircraft shooter. |
| Server decides shot, native owner client executes an exact server result | UNKNOWN/blocked pending native contract | Applying server results on clients is not inherently client authority. Here no validated ordered native result/ack path was established that preserves the server outcome against owner snapshots, retries, ordinary hits and migration. Client-selected targets/damage/RNG remain prohibited. |
| Maintain a Lua health ledger and overwrite native health every update | NO-GO | No proved interception/order for all native owner/player damage, death and save paths; can undo legitimate combat or lose support damage. Repeated corrections do not solve an atomicity/authority gap. |

An external NPC framework is not evidence of a vanilla Lua route. Existing installed agents/patches cannot be required by this mod. No external-mod implementation was inspected or copied. A future external dependency would need its own explicit scope, Lua-only, licensing and dedicated compatibility review; it is not a substitute for MS04 proof.

## 6. Bounded route to a testable contract

Research complete ownership/result access first. If no exposed safe handoff/result route can be established, **stop at NO-GO for armed support**, even if NPC construction works. The first complete release requirements are not silently weakened to audio-only or damage only against the rare targets already owned by the server.

After separate implementation and engine-test authorization, candidate diagnostics should use disposable equipment/save, one isolated native actor context at most, one target and two clients. No credentials, support missions, persistent grants, autonomous shooting, world attraction or player damage. Stage construction/cleanup first, then one nonlethal native Hit only on a target whose owner and replication contract are proved. Already server-owned targets may isolate native hit behavior in a diagnostic; skipping all client-owned targets does not satisfy the support feature. Stale-owner and owner-migration tests are mandatory before expanding scope.

| ID | Required dedicated probe / acceptance | Actual |
|---|---|---|
| G-R01 | Constructor overload/binding and side effects: one context, exact list/square/scheduler/descriptor/emitter counts before/after; no client actor assumption. | NOT TESTED |
| G-R02 | Allocation failure, abort, disconnect, unload and restart leave no actor, descriptor, inventory, saved orphan or callback residue; ordinary characters unaffected. | NOT TESTED |
| G-R03 | Supported ranged Hit reduces one server-owned zombie nonlethally through normal native consequences; capture callbacks, modifiers, hit direction and native world-sound position/count, including invisibility effects. | NOT TESTED |
| G-R04 | Both existing clients observe the same nonlethal health/reaction; neither computes outcomes or generates duplicate native hits. | NOT TESTED |
| G-R05 | Delayed current-owner health snapshot around a hit cannot restore old health; demonstrate actual barrier/result route, not a timing coincidence. | NOT TESTED |
| G-R06 | Handoff lists/acks/speed limits and automatic reassignment remain consistent; new owner starts from authoritative damaged state. | NOT TESTED |
| G-R07 | Concurrent ordinary player hit plus support hit in both orders produces correct combined health, callbacks and single lethal transition. | NOT TESTED |
| G-R08 | Lethal path produces one native death event/corpse/inventory with reviewed survivor killer attribution; unknown killer representation cannot duplicate/break corpse processing. | NOT TESTED |
| G-R09 | Finite shots/ammo, range/roof/line-of-fire rejection and per-burst ordering remain server-owned; no direct health/deletion/fake-player shortcut. | NOT TESTED |
| G-R10 | Current/late/reconnecting clients and split-screen never see/interact with a gunner; ordinary audio, world-sound and player NPC state remain unchanged outside the test. | NOT TESTED |

This investigation does not implement those probes. MS04 is now decomposed into an attacker-context candidate and concrete lifecycle/ownership/replication gates; it is not marked resolved. MS01-MS03 equipment/loot/authorization blockers remain independent. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.
