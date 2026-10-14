# Crash manifest and recovery design — follow-up

Date: 2026-10-09. Project version: ../VERSION. Build: installed JAR 42.21. **Manifest specification: CONDITIONAL design. Exactly-once cargo, durable tombstones and full interruption-safe materialization: NO-GO with the verified primitives so far.** No persistence/gameplay code, save modification or runtime test performed.

## Verified storage facts

Exact signatures: [follow-up API index](evidence-followup/API_SIGNATURES.md).

- IsoObject.save/load serialize object metadata and containers with the object; this supplies a co-located record opportunity, not immutable identity or a crash transaction.
- GlobalModData.save writes a temporary buffer/file, then copies to global_mod_data.bin; it saves independently of chunks. A successful Lua table update or network broadcast is not a durable save acknowledgement.
- ServerMap.QueuedSaveAll (:401 onward) queues chunk saves and later calls GlobalModData.instance.save; exceptions are caught. This does not atomically order the two stores or establish all buffered chunk snapshots match the later registry revision.
- ServerChunkLoader$SaveChunkThread.addLoadedJob captures chunk.SaveLoadedChunk into a buffer and queues a SaveLoadedTask. A receipt written after a world change can be absent from an older queued snapshot even if the task later succeeds. `updateSaved()` drains/release tasks, not a documented mod transaction/fsync fence.
- IsoChunk.SafeWrite (:4082 onward) locks a chunk file, opens/truncates it and writes bytes. No explicit force/fsync or atomic replacement was established in this method. GlobalModData's file copy also lacks a proved crash-safe durability barrier. `SafeWrite` is not evidence of atomic power-loss behavior.
- ItemContainer and TransactionManager provide native item/interaction mechanisms, but inspected TransactionManager maintains in-memory transactions and does not establish durable cross-store escrow. Reusing it may help online contention; its name does not prove crash recovery.
- Native ObjectModDataPacket.parse loads/wipes object metadata, and processServer relays it. PacketTypes$PacketType.onServerPacket calls parseServer before isConsistent; the default parseServer delegates to parse, and MovingObject.isConsistent tests object existence. No B47HE namespace ownership guard was established. Crash/component metadata must be treated as potentially mutable hints, not a trusted authoritative ledger. Packet authorization/patch compatibility needs further audit before any production trust claim.

## Stable identity and deterministic resolution

The authoritative server manifest requires an immutable world/save UUID assigned durably once, plus a persisted monotonically allocated crash sequence (or collision-checked server-generated ID). `crashId = worldId + allocationId`; neither player identity, wall clock nor object index is an identity authority. Allocation and reservation must be durably recorded before effects. On uncertain allocation recovery, stop instead of reusing an ID.

Each `componentId = crashId + manifestSlotId`; slot IDs are assigned before placement and never compacted/reused when a component is removed. Native object indices are volatile references for the current operation only. Map-owned target objects need immutable preconditions, not an assumption that index 4 still refers to the wall formerly at index 4.

Persist the seed, resolver version, aircraft/mission definition revision, server configuration snapshot, heading, severity and **fully resolved** coordinates/sprite variants/cargo list/structural target list. Re-execution consumes the resolved manifest, not fresh random draws or a changed registry iteration order. Unknown schema/asset/definition revisions quarantine the site. Historical schemas are independent of the project SemVer and must never be inferred from it.

## Proposed manifest fields

These are schema requirements for review, not implemented Lua/JSON definitions or a claim that a storage backend exists.

| Section | Fields / meaning |
|---|---|
| Identity | worldId, crashId, allocationId, schemaVersion, manifestRevision, manifestDigest, generationEpoch, definition/resolver revision |
| Resolution | event kind, aircraft, mission, seed, scheduled/resolved world times, immutable configuration snapshot, impact/final coordinates, heading/severity, complete operation list |
| Reservation | stable reservationId, complete affected 3D footprint and dependency closure, footprint digest, occupied region keys, owner crashId/epoch, phase; no expiry may free a partially changed site |
| Commit control | PLANNED / RESERVED / PREPARED / MATERIALIZING / WORLD_COMMITTED / PERSISTENT / CANCELLED / QUARANTINED; durable revision references and verified storage acknowledgement if available |
| Components | stable slot ID, position/orientation/sprite/type, properties/optional container shape, planned status, operation ID, authoritative completion receipt, co-located world receipt, removal receipt/tombstone |
| Structural/terrain operations | operation ID, object ownership/edge, immutable before-state precondition, full linked-object set, expected after-state, spawned debris/drop identities, durable intent and completion receipts |
| Cargo | cargo transactionId, predetermined individual item IDs or stable logical slot IDs, immutable initial contents digest, generation receipt, transfer/consumption receipts, container revision; no respawn flag |
| Interactions | server request/transaction ID, authenticated actor, current component/container revision, lock/lease epoch, validation result, prepare/commit/abort state and durable result where supported |
| Recovery | last verified consistent checkpoint, checked chunks and snapshot revisions, pending/ambiguous operations, quarantine reason, migration decision, evidence of tombstones/receipts |

IDs in world metadata may assist lookup but must be validated against a server-owned immutable manifest and a proven identity binding. Simply regenerating corrupted IDs from client-editable modData or allowing a client to copy a component receipt is forbidden. Coordinates/sprite comparisons alone cannot establish identity after legitimate moves/removal. A protected native identifier or pre-parse namespace/ownership mechanism remains [UNKNOWN]; B11 blocks a production design relying on these receipts.

## Completion markers and tombstones

Completion has three different meanings: (1) mutation applied in memory, (2) object/marker serialized into a specific chunk snapshot, (3) that snapshot durably committed under the supported failure model. Keep separate states; do not set `durable=true` after step 1 or after transmitting a packet.

A candidate for idempotent creation is a component plus its initial cargo and creation receipt serialized in **the same object record**, inserted once while inaccessible to interactions. If a fully loaded trusted record with matching receipt exists, do not create again; if duplicate receipts are found, quarantine. This helps normal retry logic but is not a demonstrated exactly-once algorithm: chunk durability, mutable metadata, stale snapshots, cross-chunk components and future removal still require proof.

A tombstone must survive after the last component/world-item disappears. Never store its only copy in the removed object. The candidate ordering is durable server removal intent/tombstone first, then idempotent physical removal under an interaction lock, then completion receipt. A surviving object paired with a valid tombstone is removed once reconciled; it does not become salvageable again. This requires a verified protected durable ledger and write barrier, neither of which is established for the current Lua primitives.

For structural damage, absence of a wall is not proof that this crash removed it; an unchanged object index is not proof the planned wall survived. After a durable intent, repeat only an idempotent, fully identified operation whose state matches the original immutable precondition and whose drops/contents have an independently proved deduplication mechanism. Random native drops and world effects are not silently replayed. Unknown results quarantine; never restore destroyed walls as a rollback shortcut.

## Cross-store recovery matrix

R = authoritative registry/intent receipt; W = completely loaded, validated world record. UNKNOWN includes unloaded chunks, truncated/stale records or mutable identity. No branch treats unloaded as absent.

| R after restart | W after restart | Required decision |
|---|---|---|
| Prepared intent, no completion | Exact live component plus trusted co-located creation receipt | Candidate reconciliation: adopt the existing result, then persist missing authoritative completion. Do not reroll/refill. CONDITIONAL on trusted identity/durable barrier. |
| Prepared intent, no completion | No component | Cannot tell never spawned from spawned then removed/looted with missing tombstone. Quarantine; do not blindly retry cargo/materialization. |
| Completion receipt | Exact live component | Verify manifest/revision and cargo state; preserve legitimately changed contents. Do not compare against initial loot and refill missing items. |
| Completion receipt | No component | Could be legitimate removal, lost/stale chunk save or identity corruption. Quarantine unless durable removal/transfer receipt establishes the outcome. |
| Durable tombstone | Exact live component | Candidate idempotent removal under exclusion/locks; never reopen loot or regenerate. Requires verified tombstone durability and target identity. |
| Durable tombstone | No component | Removed remains removed; retain tombstone/reservation/history. |
| No authoritative record | Crash-tagged component | Orphan is not a new free site. Quarantine footprint; recover only with validated immutable allocation/manifest evidence. |
| Conflicting/duplicate IDs, digest mismatch, corrupt schema or unknown chunks | Any | Quarantine, reserve space and require review/repair evidence; do not delete or merge arbitrary objects automatically. |

Every decision requires the complete reservation/linked chunks and no observer of intermediate reconciliation. Reconstruct reservations from durable intent before scheduling new crashes; partially committed reservations never expire automatically. Locks in memory are reacquired using a recovery epoch; persisted owner names alone do not grant ownership after restart.

## Exactly-once cargo: what would prove it

Exactly-once means no duplicated persistent initial issuance or transfers, including crashes/retries; deterministic repeated contents is not exactly-once. Online request deduplication is only one piece.

A valid future mechanism would need a durable PREPARE ledger, globally unique cargo/item transaction identities, an idempotent world/inventory sink keyed by those identities, a durable commit/result receipt, and recovery that can discover a transfer in both source and destination stores before permitting any retry. The authority-protected identity binding and all relevant save acknowledgements must be verified. A durable tombstone covers post-generation removal. Cross-store escrow/migrations must participate in the same proof. None of these guarantees is supplied merely by GlobalModData plus ordinary containers.

Counterexample: cargo is created and transferred to a player; the player's save persists while the component/registry save lags. After restart the component is absent/old and the registry says incomplete. Regenerating the predetermined cargo duplicates loot already owned by the player. Conversely, marking completed first can leave no cargo if the world save never persisted. Adding another independently saved boolean moves the uncertainty without resolving it.

Therefore **NO-GO for claiming exactly-once cargo or legitimate-removal recovery**. The fail-closed behavior is to quarantine ambiguous sites and prohibit automatic cargo regeneration/transfer replay. This sacrifices availability; it is not mislabeled exactly-once, and it cannot by itself remove duplicate loot already persisted elsewhere. A permanent cancelled issuance may avoid retries only when its cancellation is durably established before effects; no such barrier is currently proven.

## Concurrent interactions and publication

One server operation lane per crash/linked container set; authoritative compare-and-check revision; authenticate player from connection, validate distance/permission/current state; reject stale requests; persist transaction/result identities before any permitted irreversible retry. Acquire locks in deterministic resource order across crash reservations, components, containers and actor destinations to avoid overlap/deadlock. No trusted identity from arguments or object modData.

During PLANNED through WORLD_COMMITTED, interaction must be inaccessible through **all** native paths (loot UI, moving furniture, sledge, dismantle, inventory transfers), not only custom salvage commands. Publishing a mod flag does not lock vanilla actions. A verified native interception/lock model is unresolved. Do not enable an ordinary container and hope players cannot reach it.

After a durable complete publication, native authoritative inventory transactions can be reused if their save/transfer behavior is proven; retain server-side request deduplication and source/destination revision checks. On restart, no admissions or interactions until reconciliation completes under a proven fence. No permanent tick loop per wreck; bounded recovery queues cannot trade away visibility safety.

## Assumptions and verification gates

Assumptions for a potential algorithm: clean version-matched engine; protected world identity; persistent immutable manifest; trusted crash/object identity binding; verified durable storage barrier; quiescent linked chunk and player snapshots; exclusive native interaction locks; no observers until completed state publication. Every assumption is currently [UNKNOWN] or [RUNTIME GATE], not fulfilled by this document. Power loss/process kill must be distinguished from clean shutdown; both are included in the test plan with clear expected quarantine behavior.

The schema and decision table are reviewable now. No production state machine, cargo generator, tombstone handler or WAL is implemented. F-R11 through F-R15 and the off-screen contract must pass before changing the NO-GO verdict.
