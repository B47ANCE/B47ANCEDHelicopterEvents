# Engine blockers

## Military support direction - 2026-10-15

[Combat ordering follow-up](COMBAT_ORDERING_CONTRACT.md): native Lua commands and reliable zombie variants are reliable unordered; ordinary player hits are reliable ordered, without a common cross-stream order. Current-owner identity rejects A while B owns the target, but does not distinguish an old A packet after A-to-B-to-A. Absolute/minimum health corrections and unconditional handoff retry/skip have explicit player-damage or duplicate/loss counterexamples. The 28-schedule offline model is not an engine test. O-C02/O-C03/O-C04 and MS04 remain unresolved; no mutating combat probe.

[Military Support MS01-MS06](MILITARY_SUPPORT_API_AUDIT.md) independently gate credential custody, original officer loot, durable authorization, virtual-attacker combat and runtime sound. Full-crash B01-B12 remain deferred; none was waived.

[Lua-only MS04 follow-up](DOOR_GUNNER_LUA_FEASIBILITY.md): genuine native survivor plus ranged Hit is a CONDITIONAL diagnostic candidate, and Hit reaches native damage/death handling. The current-owner packet can still replace server health; safe ownership handoff, ordered nonlethal result publication and actor lifecycle are unresolved. A hidden NPC, owner=nil assignment, extra-update call or repeated health correction does not clear this contract. Complete armed support remains NO-GO; G-R01..10 all NOT TESTED.

[Ownership/result access trace](GUNNER_OWNERSHIP_RESULT_AUDIT.md), O-C01..06: no complete supported Lua path established. The engine's shared getFakeAttacker proxy improves the attacker lead, not authority. Zombie syncHealth/syncDamage inherit empty bodies; null owner bypasses the reassignment delay; player-hit relay requires real player/source identity. A custom result acknowledgement does not fence old native health packets. No mutating combat probe should be implemented under these findings; bindings/ownership may be observed without mutation after separate authorization.

[Third-party NPC comparison](THIRD_PARTY_RESEARCH.md): examined A-Life paths delegate body execution to clients and separate registered NPC health from ordinary-zombie damage; Bandits has local hit/health rebroadcast paths; Remnants requires a Java agent. These are different execution/trust surfaces, not proof of our native fence. Server-approved owner-side result application remains UNKNOWN research; clients choosing shots/damage remains excluded. No code/assets/dependencies imported; MS04 unchanged, independent clean-room review pending.

## Implementation status - 2026-10-15

Audio definitions and protocol/lifecycle logic now exist in the [offline prototype](AUDIO_PROTOTYPE.md); A03 is now unverified engine/UI/admin behavior rather than absent source. A01/A02/A04/A05/A06 remain runtime gates. No audio or full-crash blocker is promoted to PASS; full-crash B01-B12 remain unchanged.

## Current Lua-only audio status - 2026-10-14

Lua-only is mandatory. Former Java/bridge proposals are historical, not an exit route. The full-crash B01-B12 blockers below remain unchanged. A bounded audio-only candidate avoids world/cargo transactions but still has these separate runtime gates:

| ID | Audio blocker | Exit evidence |
|---|---|---|
| A01 | Ordinary emitter play wrappers can rebroadcast client native sound; remote-event flag is not a transport guard | Dedicated packet/sound isolation test of the exposed local Impl overload; no zombie attraction or duplicated native sound. |
| A02 | Owned emitter tick/stop/pool-return behavior, Lua nil overload and stop tails untested | A-R01 through A-R04, including silent start, reused emitter, pause and disconnect. |
| A03 | Sandbox definitions/localization and server update interpretation unimplemented | A-R05/A-R06 verify bounded IDs, server authority, existing-save defaults and config revisions. |
| A04 | Unsynchronized/zero time, paused updates and SP clock difference | A-R07/A-R08; expired or unsafe clock state must remain silent and never extend lifetime. |
| A05 | Ready handshake, epoch/revision snapshots, late joins and split-screen duplicates untested | A-R09 through A-R12 on headless dedicated with at least two clients. |
| A06 | Patched emitter/clock/event classes differ from JAR; acoustic behavior/vanilla event coexistence unproved | Clean/patched results separated; source fingerprints and actual runtime environment recorded. |

See [audio design](AUDIO_FEASIBILITY.md) and [runtime tests](RUNTIME_TEST_PLAN.md). No newly verified Lua capability waives the strict off-screen or destruction contracts.

Date: 2026-10-09. Project version: ../VERSION. All runtime outcomes UNKNOWN; no PZ/server was launched.

| ID | Blocker | Affected scope | Required exit evidence |
|---|---|---|---|
| B01 | Follow-up confirms local camera controls, four-slot connections, join/teleport gaps, retained/client-requested chunks and independent per-object publication; no full observer/stream fence | All world materialization and damage, including pre-existing sites and recovery | Enforceable admission/stream/teleport/render commit contract, then dedicated adversarial evidence. Until then disable materialization. Distance or client reports cannot authorize it. |
| B02 | 422 loose zombie classes differ from JAR; 11 have no counterpart; launchers prefer loose roots, client JSON adds external agent | Attribution of installed runtime behavior to clean Build 42.21 | Independently acquired/pinned clean client and dedicated-server fixtures, original depot/hash comparison and actual class-origin evidence; preserve current install. |
| B03 | Wall/door/window ownership, removal expansion, room/cutaway/weather fidelity and protected modified-base detection unproved | Sidewall/building destruction | Full native chain/footprint audit plus dedicated collision, navigation, cutaway, exposure and restart evidence. Reject ambiguous structures. |
| B04 | Roof/floor geometry, support effects, floor transitions and multistory damage unproved | Roof and floor penetration | Separate per-level audit and dedicated fixtures after B03, including neighboring squares and falling hazards. |
| B05 | Global save and asynchronously captured/written chunk snapshots are independent; SafeWrite truncates/writes without a proved durable atomic barrier; player transfer store adds another participant | Exactly-once cargo, salvage tombstones, interruption recovery | Protected durable receipts/barriers, idempotent sinks and interaction exclusion; failure-injection matrix across every store. Ambiguity quarantines; deterministic replay is not exactly-once. |
| B06 | Off-screen candidates may be unloaded; a square lookup is not a safe remote generation loader | Site selection, pre-existing determinism, deferred operations | Verify server chunk readiness/lifecycle and bounded work queue; no generated dummy squares or full-map scan. |
| B07 | No verified original sprite manifest, sprite footprint/collision contract or container schema | Independent wreck objects and trails | Original assets and loader/orientation tests only in later authorized phases; no giant vehicle surrogate. |
| B08 | Tree/crop/erosion semantics, terrain classification, fire spread and attraction unproved | Ground destruction and advanced aftermath | Specialized API audit, protection footprint including side effects, dedicated persistence tests. Fire disabled where consequences cannot be bounded safely. |
| B09 | Rotor/impact sound registration and moving positional emitter lifecycle unverified | Dynamic flight presentation | Exact exposed emitter API, licensed/original sounds, headless/distance/occlusion/reconnect tests. Do not run client SoundManager on dedicated server. |
| B10 | July 1993 family variants/unit availability/mission equipment uncorroborated | Aircraft roster, historical loot and skins | Primary historical documentation, dates and configuration-specific decision records. No modern configuration substitutions. |
| B11 | Native ObjectModDataPacket directly loads/wipes object metadata; no authoritative identity/receipt namespace guard established | Stable world component IDs, completion markers, tombstones and server reconciliation | Verify protected server identity binding and pre-mutation packet/namespace ownership contract; do not treat client-mutable metadata as authority. Runtime malicious-request behavior NOT TESTED. |
| B12 | Native loot/move/sledge/dismantle/transfer paths are not covered by a proposed custom salvage lock | Partially generated sites and cross-player cargo recovery | Verified exclusion through every native interaction path and source/destination transaction/save fence; no client-only inaccessible flag. |

Follow-up [design documents](../README.md) trace exact native paths and failure assumptions. A simple plain-wall fixture is only a CONDITIONAL diagnostic; no safe building impact has been established. The maintenance/no-observer alternatives are future contract investigations, not approved launch or world modification.

B01 alone blocks production world generation. Turning building impacts off does not resolve B01. Settings cannot waive an engine safety gate. The broad intended mod remains NO-GO for implementation until affected blockers are resolved; source-backed isolated hypotheses are listed as CONDITIONAL, never release-ready.

Historical policy note: earlier research suggested a Java bridge if Lua exposure proved insufficient. That suggestion is superseded by the 2026-10-12 Lua-only rule and is not current authorization. Do not implement/build/require custom Java, bridges, agents, injected classes, native extensions or JAR dependencies. Unsupported capabilities stay blocked; propose only Lua-only alternatives without weakening authority.
