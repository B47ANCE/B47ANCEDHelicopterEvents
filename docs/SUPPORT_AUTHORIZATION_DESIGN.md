# Single-use support authorization and recovery design

Date: 2026-10-15. Version: [root VERSION](../VERSION). **Live-process intent serialization: CONDITIONAL. Persistent loss-safe single-use authorization and exactly-one dispatch across failures: NO-GO pending MS01/MS03.** This is an unimplemented contract, not an exactly-once claim.

## Authoritative objects and native surface

The connection-associated OnClientCommand player supplies identity; client radio/card IDs are lookup hints only. Native command signatures and readiness limits are already recorded in [audio evidence](AUDIO_API_EVIDENCE.md). Re-resolve exact current server inventory objects, allowed full type, ownership, player alive/eligibility, native device state, original card custody, radio not spent, mission capacity and cooldown before mutation. Reject unknown commands/fields, nonfinite values, excessive payloads and retries outside bounded nonce/rate limits. Never accept client state, targets, ammo, damage or authorization results.

[Source index](SUPPORT_SOURCE_INDEX.json): N03 InventoryItem.getID():int / setID(int), getModData():KahluaTable, getContainer():ItemContainer; N04 ItemContainer.getItemWithID(int), getItemWithIDRecursiv(int), containsID(int), AddItem(InventoryItem):InventoryItem, Remove(InventoryItem):void; N01 Radio.getDeviceData():DeviceData. Classes are registered in initial Exposer snapshot:2211-2217. These support candidate lookups/mutations, not immutable server ownership or transaction semantics. Lua invocation and nested/world/vehicle cases remain NOT TESTED.

Native InventoryItem.save(ByteBuffer,boolean) N03 offsets 17-20 writes int ID and offset 299 saves modData; load(ByteBuffer,int) offset 5 restores ID and 497 loads table. Radio.save/load additionally persist DeviceData (N01). Native serializers are not synchronous Lua commit/fsync APIs. Item ID is writable and its global uniqueness across copies/imports is unproved; a UUID placed in modData does not become sealed identity.

Native SyncItemModDataPacket.parse(ByteBufferReader,IConnection), N11 offsets 18-31 resolves container item ID, then offsets 37-56 loads received bytes into that item's table. Packet annotation is LoginOnServer/handlingType=2; that number alone does not establish packet direction, access filtering or an exploitable server write. The audit does **not** claim arbitrary client SPENT edits through this packet. It also supplies no protected namespace/immutable receipt proof. Verify all native inventory/import/update routes and reject ambiguous identity before using modData as authority.

Exposed globals sendAddItemToContainer/sendRemoveItemFromContainer/sendReplaceItemInContainer and syncItemModData (N17, initial GlobalObject snapshot:7608-7678) synchronize candidates after mutation. Native send helpers route to owning player or object relevance (retained GameServer snapshot:2469-2510). Packet transmission/acknowledgment is not a durable save. S10:632-655 native transfer delegation is another interaction path outside custom support request handlers.

## Proposed transaction record

Server-owned immutable association would require: world/save identity, validated radio identity/generation, original credential identity, request ID scoped to authenticated connection generation, support event ID, reservation/cooldown record, prior state, resolved mission specification, receipt/status revision and durable recovery decision. No actual schema/store or new IDs are introduced here.

One live server critical section should reserve mission capacity and exact equipment, validate again, then authorize one immutable mission. Serial handler execution can suppress simultaneous custom requests within one process, but not native transfer interleaving across ticks or asynchronous independent saves. Locks must cover original source/destination containers, all equip/drop/trade/place/corpse conversions, pending native actions, client imports and save capture. A Lua busy flag/menu lock is not an engine fence.

Only a proved commit may consume the card, make the radio permanently SPENT, bind one mission ID and start cooldown. Failed preflight/reservation leaves all items and radio state untouched, with no mission or cooldown. Insert/remove must retain the exact original card and permit its return before commitment. A spent radio retains normal DeviceData and can never be reset with another card. Unknown/corrupt server registration does not default to UNUSED.

## Independent-save counterexamples

Let I be native radio/card inventory persistence; L be a server support ledger (for example GlobalModData); D be live dispatch/combat. I may itself span player/source/destination/world stores after transfers. [Earlier storage audit](CRASH_PERSISTENCE_DESIGN.md) establishes independent global/chunk snapshots; this audit adds serialized inventory participants without a new common durable fence. N19 GlobalModData.save()/load() do not demonstrate atomicity with I.

| Durable state at interruption | Failure without a proved recovery contract |
|---|---|
| L says authorized, I still has UNUSED radio and card | Reusing items can dispatch twice; blindly re-consuming risks taking an unrelated transferred card. |
| I has SPENT radio/card removed, L absent/old | Resources lost with no recorded mission. Reset/refund can duplicate if dispatch already happened. |
| Card source saved removed, radio/escrow destination not saved | Original removable card can disappear even before authorization. |
| Destination saved with card, source saved before removal | Same card can appear in two places; metadata equality does not choose a legitimate owner. |
| D occurred, ledger checkpoint lags | Replaying after restart can grant duplicate combat; not replaying may preserve at-most-once but not accepted-call completion. |
| SPENT transfer saved in one owner/store, another stale copy loaded | Numeric item ID or copied modData alone cannot resolve legitimate generation or restore permanent single use. |

Write-ahead intent, tombstones, same-tick Lua mutations, explicit ModData save, network acknowledgment, a random UUID, serializing a card into modData, or retaining one copy elsewhere do **not individually** solve these cuts. Co-locating state is a research direction only if native save ownership, authentication, transfer conversion and atomic durability are demonstrated. No such mechanism has been established here. Do not promise exactly-once behavior or claim that merely adding a ledger resolves this blocker.

## Restart and concurrent interaction policy

No mission should silently restart from APPROACHING after restart. A later safe design needs one durable committed outcome and a terminal interrupted/cancelled record; never automatically replay gunfire or reissue a grant on reconnect. Refund on death/disconnect/restart is a gameplay decision **and** a new item transaction; do not invent it as recovery. Reserve capacity/cooldown across recovery until reconciled, so reboot cannot reset finite authorization rules.

Fail closed before item mutation while MS01/MS03 remain open: preserve items, deny request and report unavailable authorization. If a future fixture reveals conflicting receipts after a partial operation, stop all related support operations and quarantine the binding for human reconciliation; do not consume additional items, clear SPENT, issue replacement credentials or replay missions. Quarantine is not proof of lossless recovery and cannot satisfy the complete release requirement by itself.

Existing saves/old radios need a registration/migration policy that distinguishes new legitimate equipment from copies/ambiguous state without rewriting player saves during this audit. Missing registry is not a free authorization. Schema/downgrade/backup support must be reviewed before code; no migration files were added.

## UI and configuration boundary

Context actions are localized presentation only: UNUSED plus available compatible card offers Insert; ARMED offers Remove and, when eligible, Call in Air Support; SPENT offers none of these while native radio controls remain. Ordinary radios/card alone get no support action. Revalidate on server even if menu state is stale. No third-party context-menu source is needed or copied.

Candidate future settings group B47HE Military Air Support (not implemented): SupportEnabled (proposed release default true only after gates), SupportDurationSeconds=90, SupportEngagementRadius=25, SupportAmmunition=300, SupportAccuracyPercent=45, SupportFireIntervalSeconds and SupportBurstRounds (defaults/bounds require combat tuning), SupportCooldownDays=7. Stable names, English tooltips/fallback, numeric bounds/steps, native defaults and server interpretation must be defined with implementation. Current audio-flight settings remain untouched and disabled by default. Do not reuse ambient scheduling as authenticated support or accidentally enable both.

Radio/credentials/single-use requirements are mandatory invariants, not options. Friendly fire stays excluded in the first safe slice; no enabling setting until an independently reviewed player-damage path exists. Concurrent mission default 1 is the first-slice bound; a configurable maximum above 1 needs capacity/target/audio tests. Rotor/gunfire attraction radius/cadence are meaningful future sandbox candidates, separate from engagement radius; resolve them before implementation rather than hiding gameplay constants. Protocol limits, IDs, locks and safety fences stay internal.

## Smallest test and verdict

First authorized dedicated probe: read-only preflight/lookup and concurrent nonce requests with two clients; transfer equipment during lookup and verify rejection. No consume/insert/escrow mutation or mission. Before any real authorization prototype, demonstrate a disposable save/restore fault matrix at every I/L/D boundary, native transfer race, stale import, disconnect and restart. Native mutation/replication tests alone are insufficient. All NOT TESTED. Complete persistent authorization NO-GO; G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.
