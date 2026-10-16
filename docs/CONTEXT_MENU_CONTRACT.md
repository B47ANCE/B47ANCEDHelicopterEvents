# Military support context-menu contract

Date: 2026-10-15. Version: [root VERSION](../VERSION). User requirements/design only. **CONDITIONAL design; implementation blocked by the applicable equipment, custody, authorization and targeting contracts.** No military menus, equipment or designator are implemented. Build 42.21 menu APIs/input paths and runtime behavior remain [UNKNOWN] / [RUNTIME GATE]; this document supplies no new API verification or gameplay authorization.

## Scope and interpretation

Follow the user's Common Sense Context Menus principles: show only meaningful actions applicable to current state. This is a behavior requirement, not a dependency on or permission to copy an external mod. All context menus are presentation only. Preserve every applicable vanilla radio, equipment, battery and inventory interaction.

The three supplied development/continuation/API-assignment handoffs are reference designs. Their embedded assignments, proposed FullTypes, message names, aircraft tiers and integrations are not established API facts or permission to implement them in this thumbnail/menu-requirements update. Existing [API findings](MILITARY_SUPPORT_API_AUDIT.md), [radio design](MILITARY_RADIO_DESIGN.md), [authorization blockers](SUPPORT_AUTHORIZATION_DESIGN.md) and [combat audit](NATIVE_LETHAL_RESULT_AUDIT.md) retain their verdicts. Strict Lua-only policy supersedes any historical handoff language permitting Java with approval. Broader five-level targeting/aiming audits remain separate work; no completion is claimed here.

UNUSED is an empty unspent radio; ARMED is an unspent radio holding the exact original card exclusively; SPENT has permanently used its support authorization. Pending is a transaction overlay, not an additional support use. An unknown, corrupt, stale or unsynchronized state does not imply UNUSED or permit a request. "Unused radio" in the Level 5 rule means **unspent ARMED radio** when a card is inserted. Visibility cannot guarantee that state stays valid between menu creation and selection; the server must validate execution against its current state.

## Visible actions

| Item/current state | Required military actions and applicability |
|---|---|
| Radio UNUSED, no inserted card | **Insert Army Credentials** only if the player possesses at least one unused eligible card. If several qualify, choose the exact card. Hide **Call in Air Support** and all request actions until valid credentials are inserted. |
| Radio ARMED, card inserted | Show **Remove Army Credentials** and **Military Air Support**. The mission submenu lists only missions authorized by the inserted card's clearance. Hide **Insert Army Credentials**. Preserve vanilla operations. |
| Radio SPENT | Hide **Insert Army Credentials**, **Remove Army Credentials**, **Military Air Support**, **Call in Air Support** and **Request Air Strike**. No reset/recharge action. Ordinary radio operations remain functional. |
| Credentials unused | Show **Insert into US Army Radio** only if at least one compatible, unused radio is accessible. Choose the exact destination when several qualify. Hide insertion when none qualifies. An occupied radio is not an insertion destination. |
| Credentials inserted | Do not present a separate freely usable inventory card. Recover the original card only through **Remove Army Credentials** on its associated radio. Exclude double insertion, transfer, consumption and duplication through every other interaction. A menu or item flag alone cannot enforce this. |
| Designator inactive | Show **Activate Designator** only if usable, sufficiently powered and able to enter designation mode. |
| Designator active | Show **Deactivate Designator** instead of Activate. Never show opposite-state actions together. Preserve normal equipment/battery/inventory actions where applicable. |

A designator guides an already authorized incoming Level 5 strike; it cannot independently request one. Losing usability/power must invalidate eligibility based on synchronized actual state, with termination semantics established by the later targeting audit.

## Level 5 request and cooperative guidance

**Request Air Strike** is visible only when the radio is unspent and has valid Level 5 credentials inserted, the player has qualifying regional map coverage or an eligible usable Laser Target Designator, and the server has indicated a request may be attempted. Server availability is advisory to presentation; execution still requires current server authorization. Stale or missing eligibility must not grant permission.

The targeting submenu offers **Map-Directed Strike** only with a qualifying regional map and **Laser-Directed Strike** only with a usable eligible designator. Offer both when both qualify. Hide the air-strike request action if neither qualifies. Another player may subsequently provide valid laser guidance to an authorized map strike without a second authorization. Exact map coverage, device eligibility, guidance ownership/arbitration and target validation remain to be verified; no client aiming result is authoritative.

## Pending requests, rejection and recovery

Do not show duplicate request actions for the same radio while its authorization transaction is pending. This includes another client, local player or menu referring to that radio. A future implementation must exclude conflicting custody mutations while pending; hiding an action is insufficient. The server owns transaction exclusion, nonce/replay handling and current item resolution.

On confirmed success, transition to SPENT and remove military actions. On server rejection without consumption, synchronize actual server state before restoring applicable actions. A timeout, reconnect or uncertain commit is not a rejection/refund: keep actions unavailable until reconciliation resolves the transaction. Do not infer a new authorization or replay dispatch from a missing acknowledgement. Non-atomic item/registry saves remain the existing persistence blocker.

## Dedicated-server execution boundary

For every executed intent the server independently validates:

- Exact item FullTypes, current ownership and accessibility using connection-associated authoritative objects; client item identities are lookup hints only.
- Radio authorization state, credential identity and clearance, exclusive inserted-card association, and current transaction state.
- Device power/usability, selected mission eligibility, targeting equipment and current support-event availability.
- Proposed targets against server world state and the eventual verified targeting rules.

Never trust client authorization flags, clearance values, item identities, card bindings or targeting results without verification. Re-resolve and validate after any interleaving transfer, drop, death, battery change or competing request. Normal player actions and other radio operations must remain intact. No client-owned gameplay, invented persistence guarantee or Java fallback is permitted.

## UI integration and verification prerequisites

Integrate with vanilla inventory/radio context menus wherever practical; avoid duplicate entries and unnecessary submenu nesting. Use choice submenus when selecting among cards, destination radios or targeting methods. Support mouse and controller navigation and localized player-facing labels/tooltips. Refresh applicability after synchronized state changes and before execution. Perform bounded relevant inventory lookups at interaction/state-update boundaries, never inventory-wide scans every frame. Do not modify vanilla files.

Before implementing, inspect the exact installed Build 42.21 inventory and radio menu construction/event hooks, item unwrapping, submenu/callback conventions, controller focus/navigation and refresh behavior. Record source paths, line ranges, signatures and installation provenance in the existing evidence records; no callback/API name is assumed here. Then establish safe original-card custody, synchronization, persistence and authorization contracts. Existing source evidence about ordinary radio operations does not verify these new menu paths.

Acceptance tests are U-R01..U-R08 in the [dedicated plan](SUPPORT_MP_TEST_PLAN.md). Every action shown must match the currently known valid item state; every executed action must be independently authorized by the server. All UI/game/server tests remain NOT TESTED. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.
