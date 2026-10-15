# Military Air Support API audit

Date: 2026-10-15. Project version: [root VERSION](../VERSION), unchanged at 0.1.0-dev.3. Target: Build 42.21; installed Steam build 25485521. **Audit/design only. Overall first-release authorization/combat loop: NO-GO with currently verified contracts.** This is an evidence blocker, not a claim that every Lua-only approach is impossible. No support gameplay was implemented or run.

## Direction and evidence boundary

Military Air Support is the first complete gameplay release. Crash/wreck/destruction research remains deferred, with existing NO-GO findings intact; it is not a prerequisite for a non-destructive support diagnostic. This audit follows Part L of the handoff and the user's final direction. Runtime remains strictly Lua-only: no custom Java, injected classes, bridge, JAR dependency or native extension. A future authorization cannot silently weaken the current policy.

The handoff's alternate repository path was absent. The verified existing B47ANCE/B47ANCEDHelicopterEvents checkout is used. Baseline 81563f78ae0179f34f49385909c645bf6f9cf14e is the open rotor-only prototype PR #4. The audit is a documentation branch based on that source; it neither merges nor expands the prototype. No newer separate meta-event audit was found; reuse [E11/native helicopter evidence](API_EVIDENCE.md) and [audio implementation evidence](AUDIO_IMPLEMENTATION_EVIDENCE.md).

[SUPPORT_SOURCE_INDEX.json](SUPPORT_SOURCE_INDEX.json) fingerprints 11 installed text files (S01-S11) and 19 packaged native members (N01-N19), including targeted loose-class hashes. Its paths are relative to the installed game, not redistributed files. Packaged JAR SHA-256 remains e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33. This does not authenticate a clean depot or the effective patched runtime. Existing source snapshots were read, not regenerated; current native bodies were inspected with javap -c -p. Native references below are JVM instruction offsets within exact methods, **not invented Java line numbers**. Private historical decompile references identify snapshot lines explicitly. Lua registration/public native signatures establish candidates, not executed overloads or dedicated proof.

## Subsystem decisions

Latest [ordering/owner-transfer investigation](COMBAT_ORDERING_CONTRACT.md) verifies the transport configuration and documents player-damage preservation counterexamples. Neither Lua acknowledgements nor retry/skip/absolute/minimum-health policies establish the required native fence. MS04 stays NO-GO for a mutating combat probe; no support implementation authorized by these findings.

| Subsystem | Verdict | Verified fact / remaining gate | Smallest later dedicated test |
|---|---|---|---|
| Ordinary Army radio | CONDITIONAL | S01:115-141 Base.WalkieTalkie5 is portable, battery-powered, two-way, range 16000. Reuse candidate; no new radio type justified yet. | Read-only enumeration and ordinary tuning/battery tests with two clients. |
| Insert/remove original card | NO-GO for persistent feature | N01 Radio is a final Moveable, not InventoryContainer (N05). No verified native card slot/transaction or durable exclusive escrow. | After review, disposable exact-item round-trip only once a real association API is established. |
| Officer clothing | CONDITIONAL definitions; NO-GO loot eligibility contract | S03/S04/S05/S06 define an officer coat and service pants; pants are not identified as officer-only, and natural qualifying military spawn is unverified. | Observe original outfit/piece selection at verified birth and first fill; no loot writes. |
| ID probability/replacement | CONDITIONAL hook; NO-GO exact rule | S08 has ID weights; N10 first unexplored request fills server-side. N06 emits post-roll OnFillContainer. Original clothing provenance, nested ID multiplicity and natural officer availability remain gaps. | Record native ID outcomes before any replacement in a disposable fixture. |
| Item lookup and replication | CONDITIONAL | N03/N04 have IDs, containers and serialization; exposed global send helpers exist. None proves protected identity, durable commit or every transfer representation. | Resolve exact owned item and observe native add/remove/update on isolated test items. |
| Single-use authorization | NO-GO | Radio state, original card and server mission ledger lack a demonstrated atomic durable commit/admission fence. | Fault-injection state matrix first; no real credentials consumed. |
| Independent following simulation | CONDITIONAL | Reuse native movement/state observations, not singleton or native HelicopterPacket. Current prototype only has a straight route. | Non-consuming request diagnostic, then separately authorized audio-only follow probe. |
| Rotor audio | CONDITIONAL | Exposed local Impl candidate, ownership and expiry logic already offline-tested. Runtime dispatch/loop/cleanup/acoustics untested. | Existing A-R01..12, not a support PASS. |
| AI attraction | CONDITIONAL | Global addSound/getWorldSoundManager and native WorldSoundManager paths exist. No shared attraction is created by client presentation alone. | One bounded server world sound with two observers and known zombies; separate authorization. |
| Invisible gunner damage/death | NO-GO complete feature; CONDITIONAL native attacker candidate | [Follow-up](DOOR_GUNNER_LUA_FEASIBILITY.md): genuine IsoSurvivor can potentially supply attacker; native Hit includes health/death consequences. Current owner packets can replace server health; ordered nonlethal replication and actor lifecycle remain unproved. | Ownership/result source contract first, then separately authorized G-R01..10 diagnostics. |
| Gunfire audio / 1993 weapon | CONDITIONAL design; UNKNOWN asset/configuration | M60D is a plausible Army door-gun candidate, not a finalized 1993 platform/loadout or verified vanilla sound key. | Asset/type audit and isolated positional burst, with no damage. |
| Complete release | NO-GO / G7 BLOCKED | All acceptance criteria, including loss-safe authorization and dedicated combat, remain unmet. | [SUPPORT_MP_TEST_PLAN.md](SUPPORT_MP_TEST_PLAN.md); all NOT TESTED. |

## Blocking contracts

| ID | Blocker and affected work | Required exit evidence |
|---|---|---|
| MS01 | Real original-card custody, radio identity across inventory/world/vehicle transfers and a protected SPENT binding are not established. | Native association/ownership path, all transfer exclusions, immutable server identity and save/reload tests. |
| MS02 | Officer-only original-outfit eligibility/natural spawning, unchanged ID probability and root/nested multiplicity are unresolved. | Exact native spawn/birth provenance, bounded authoritative post-roll replacement, no historical corpse rewrites. |
| MS03 | Global registry, inventory item/card stores and dispatch have independent save boundaries. No durable atomic commit/exclusive save fence verified. | Demonstrated crash-cut/restart recovery covering every participant; no duplicate dispatch, restored spent radio or loss of uncommitted card. |
| MS04 | Native survivor attacker candidate exists, but safe context lifecycle, stale-owner health exclusion, nonlethal result publication, kill attribution and corpse/death callbacks remain unestablished. | Supported exposed ownership/result route; [G-R01..10](DOOR_GUNNER_LUA_FEASIBILITY.md) two-client construction/cleanup, nonlethal/lethal, concurrent combat, owner migration and restart evidence. |
| MS05 | Native rotor/burst acoustics, loop/stop tails, attraction propagation and clean versus patched runtime remain untested. | Dedicated clean fixture then separate patched compatibility evidence. |
| MS06 | Aircraft-specific 1993 weapon/loadout, burst sound and credentials artwork provenance not finalized. | Primary historical reference and independently licensed/original assets or verified vanilla sound selection. |

MS01-MS04 block spending items/dispatching armed support. Fail closed **before mutation**: no credential consumption, no radio SPENT mutation, no mission and no cooldown write. Quarantine ambiguous recovery rather than automatically replaying, refunding or resetting a radio. A menu lock or custom request allowlist cannot alone fence native transfer/save paths. See [authorization design](SUPPORT_AUTHORIZATION_DESIGN.md).

## Smallest safe next prototype

The [ownership/result access audit](GUNNER_OWNERSHIP_RESULT_AUDIT.md) did not establish a complete supported Lua route. The vanilla getFakeAttacker proxy is an additional smaller context lead; it does not solve stale owner writes or nonlethal result publication. Zombie syncHealth/syncDamage are inherited empty methods, null ownership is not a protected lease and the inspected player-hit envelope requires a real player. **Mutating gunner probe: NO-GO.** Read-only binding/ownership observation may reduce remaining access uncertainty after review; it cannot qualify as combat validation. The equipment diagnostic below remains the smallest overall non-mutating prototype.

After audit review and separate implementation/launch authorization: a **read-only equipment/preflight diagnostic** on a clean dedicated server with two clients. Resolve only the actual requesting player's existing Base.WalkieTalkie5, report full type/container/device state and rejection reasons, correlate one nonce, and change nothing. Test transfer during the query and reject changed ownership. It must not insert cards, create credentials/loot, reserve a durable authorization, spend items, run attraction or damage zombies. This is an API probe, not a partial release or a replacement for the complete required feature.

No gameplay is authorized by this audit. Offline documentation/version checks may PASS; SP, dedicated, native inventory persistence and combat remain NOT TESTED. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. See [radio](MILITARY_RADIO_DESIGN.md), [loot](ARMY_CREDENTIALS_LOOT_AUDIT.md), [combat](DOOR_GUNNER_COMBAT_AUDIT.md) and [test plan](SUPPORT_MP_TEST_PLAN.md).
