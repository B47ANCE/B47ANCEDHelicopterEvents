# Engine blockers

## Military support direction - 2026-10-15

[Military Support MS01-MS06](MILITARY_SUPPORT_API_AUDIT.md) independently gate credential custody, original officer loot, durable authorization, virtual-attacker combat and runtime sound. Full-crash B01-B12 remain deferred; none was waived.

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
