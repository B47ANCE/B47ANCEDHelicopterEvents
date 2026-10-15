# Military radio design and native API audit

Date: 2026-10-15. Version: [root VERSION](../VERSION). **Ordinary-radio reuse: CONDITIONAL. Persistent credential insertion/single-use equipment: NO-GO pending MS01/MS03.** Design only; runtime NOT TESTED.

## Existing equipment before custom items

References S01/S04 and N01-N05 use [source index](SUPPORT_SOURCE_INDEX.json). S01 is media/scripts/generated/items/radio.txt; S04 is the English ItemName.json.

| FullType | Installed source | Native behavior / decision |
|---|---|---|
| Base.WalkieTalkie5 | S01:115-141; S04:4748 | US Army Walkie Talkie. base:radio, portable, two-way, battery-powered, 16000 transmit range, UseDelta 0.014, normal channels 200-1000000. Best minimal reuse candidate; do not alter the vanilla definition, battery use or tuning. |
| Base.ManPackRadio | S01:170-201; S04:2636 | US ARMY COMM. Manpack Radio; wearable/back equipment, heavier radio with native device behavior. Additional equip/transfer cases; defer broadening equipment allowlist until reviewed. |
| Base.HamRadio2 | S01:229-253; S04:1839 | US ARMY COMM. Ham Radio; nonportable, two-way, 20000 transmit range. World/placed device identity is additional scope, not automatically covered by the walkie prototype. |

B47HE.USArmyRadio is still a provisional item FullType, not the Mod ID and not an existing item. No new script definition is warranted simply to rename Base.WalkieTalkie5. Reuse remains a design recommendation for review; adding support to all pre-existing walkies needs a protected registration policy and existing-save tests. If a distinct acquisition pool is later required, a Lua/script-native base:radio definition may be investigated without changing ordinary radios. No custom Java subclass: Radio is final.

## Exact native surface and Lua boundary

| Exact signature | Reference | Availability/authority limits |
|---|---|---|
| DeviceData Radio.getDeviceData() | N01, method offsets 0-4 | Radio class registered in private initial LuaManager$Exposer snapshot:2211. S09 ISRadioAction.lua:1-120 exercises native radio behavior. Exact current Lua invocation still NOT TESTED. |
| boolean DeviceData.getIsTurnedOn(); void setIsTurnedOn(boolean); boolean getIsBatteryPowered(); float getPower(); void setPower(float); int getChannel(); void setChannel(int) | N02 public metadata; registered Exposer snapshot:2385 | Read native device state server-side for future eligibility. Setter existence is not authority approval to override tuning or battery. S09:51-75 validates native power before toggle. |
| void DeviceData.addBattery(DrainableComboItem) | N02 | Battery slot is typed; an identification card is not a battery. Never hijack battery/headphone controls for credentials. |
| void Radio.save(ByteBuffer,boolean); void load(ByteBuffer,int) | N01 save offsets 3/25, load 3/39/47 | Calls Moveable serialization and DeviceData save/load/reparent. Supports ordinary radio state serialization, not a new durable support transaction. Native serializer methods are not approved Lua save barriers. |
| KahluaTable InventoryItem.getModData(); int getID(); void setID(int); ItemContainer getContainer() | N03 | Registered InventoryItem candidate (Exposer snapshot:2217); writable ID and table are not sealed authorization. ID persistence does not establish global uniqueness/anti-cloning. |
| InventoryItem ItemContainer.getItemWithID(int); getItemWithIDRecursiv(int); boolean isInCharacterInventory(IsoGameCharacter) | N04 | Registered container (snapshot:2213). Resolve authoritative container/item, not an accepted client object or stale numeric ID. Recursive lookup requires a bounded owned inventory, not world scans. |
| InventoryItem ItemContainer.AddItem(InventoryItem); void Remove(InventoryItem) | N04 | Mutation primitives only. Their existence does not prove multiplayer send/ack, exclusivity or rollback. |
| ItemContainer InventoryContainer.getInventory() | N05 | A separate item subclass. Radio extends Moveable, not InventoryContainer; no verified radio-owned inventory slot is established. |

N01/N02 are packaged class metadata/body observations, not validation of the loose runtime override or all Kahlua overloads. Keep ordinary radio deviceData intact across authorization transitions; never replace the radio with a non-radio item to mark it spent.

## Proposed state and custody contract

UNUSED means no card held; ARMED means **that exact original card** is held exclusively for that exact radio; SPENT means immutable committed support event reference and no further support actions. The ordinary communications state is orthogonal. Unknown/unregistered/corrupt binding is not implicitly UNUSED.

Insertion/removal must move the original native item, preserve its native identity/metadata and be server-validated. No one card in two radios, no destructive serialization into a client-editable Lua table, no delete-and-recreate substitute, and no card left transferable while merely flagged as inserted. A hidden separate escrow inventory is not approved without native ownership, replication, transfer exclusion and durable recovery evidence. Cosmetic attachment slots do not prove storage semantics. MS01 remains unresolved.

Clients may submit bounded intent (insert/remove/request plus item lookup hints and a nonce). Server must re-resolve both objects from current connection-associated inventory, type, ownership and state, validate alive/power/equipment eligibility, and serialize competing operations. UI visibility is convenience only. Do not let a client supply ARMED/SPENT, card contents, persistent ID or event outcome. Native transfer actions, dropping, placing, trading, death inventory and container destruction must all participate in exclusion; see S10:632-655 delegating to ISTransferAction:transferItem.

Power-on/battery/condition requirements need a reviewed support contract; do not invent a special frequency requirement. For the smallest read-only probe use only carried, directly owned walkies. That is diagnostic scope, not permission to remove placed/transfer functionality from the full requirement.

## Persistence, MP and smallest tests

Global command candidates: void sendAddItemToContainer(ItemContainer,InventoryItem), void sendRemoveItemFromContainer(ItemContainer,InventoryItem), void sendReplaceItemInContainer(ItemContainer,InventoryItem,InventoryItem), and void syncItemModData(IsoPlayer,InventoryItem). Exposed @LuaMethod wrappers are in initial GlobalObject snapshot:7639-7678 and 7608-7613 (N17). Native GameServer send routing is retained snapshot:2469-2510: owning player, parent object relevance or inventory-container world item. A ground/placed radio may use a different IsoRadio representation and needs conversion-state verification. Sending is not saving or a transfer fence.

Before any custody code: inspect native compatible slot/storage choice. Then, after review/authorization, use disposable equipment with two clients: ordinary transmit/tune/battery first; exact-card insert/remove round-trip; move/drop/trade/equip/place/die during requests; save/restart in UNUSED/ARMED/SPENT; attempt resetting spent state via stale native inventory snapshots. Stop on mismatch. No active player saves and no automatic refund/replay. All tests NOT TESTED; G7/G8 blocked.
