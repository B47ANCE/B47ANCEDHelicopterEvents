# Army Credentials loot and original-outfit audit

Date: 2026-10-15. Version: [root VERSION](../VERSION). **Vanilla item/outfit definitions: VERIFIED source. Exact required officer eligibility and probability-preserving replacement: NO-GO pending MS02.** No new item, icon, outfit, distribution override or loot handler was implemented.

## Clothing identity versus original military status

References S02-S08/S11 and N06/N07/N09/N10/N13 use [source index](SUPPORT_SOURCE_INDEX.json).

| Candidate | Exact installed references | Finding |
|---|---|---|
| Base.Jacket_CoatArmy | S03 clothing.txt:5274-5293; S04 ItemName.json:2258 | English name explicitly identifies an officer military jacket. File GUID b3c4c9cf-4eac-4b4b-b13d-30efd77b3626, S06:3684-3685. |
| Base.Trousers_ArmyService | S03:11244-11261; S04:4499 | English name is Military Pants, not officer-only pants. GUID decb1435-3232-4cb7-be7f-3daf4556c759, S06:5668-5669. Treat as an unapproved eligibility candidate; do not silently assert officer exclusivity. |
| Base.Shirt_OfficerWhite | S03:16903 onward; S04:3894 | Police shirt. The word Officer in an identifier is not Army eligibility. |
| ArmyServiceUniform | S05 clothing.xml:586 onward (female), 21521 onward (male) | Both outfit definitions reference coat and pants GUIDs. Female coat entry has probability 0.5 at S05:594; pants entry is present. A definition is not a natural spawn contract. |
| Natural military zones | S07 ZombiesZoneDefinition.lua:1248-1295 | Army and SecretBase select ArmyInstructor/camo/other outfits, not ArmyServiceUniform in these lists. No ArmyServiceUniform occurrence in the inspected zone-definition file. |
| Other references | S11 AttachedWeaponDefinitions.lua:661; HairOutfitDefinitions.lua:212 observed separately | An attachment/hair rule naming an outfit does not create a natural officer spawn. |

GUID lookup found the coat also in civilian/nonmilitary outfits (Goth, Resident, Bandit_Late, CostumeGeneral) and service pants in PrivateMilitia/CostumeCommandoIan. Therefore current clothing alone is insufficient even before corpse transfers. No rank inference from camo, instructor name, police clothing or one shared garment is accepted.

No qualifying **natural military spawn path** has been established. Do not claim the outfit cannot ever spawn: weighted default outfits, map/mannequin/story/special sources require separate trace/clean runtime evidence. Do not add a new officer type or widen to all military zombies as a workaround. If the required eligible natural population is unavailable, credential obtainability blocks the complete release.

## Identification sources and probability

Base.IDcard, Base.IDcard_Stolen, Base.IDcard_Blank, Base.IDcard_Female and Base.IDcard_Male are defined at S02 literature.txt:4801-4856. Blank/stolen IDs are not automatically the same loot event as the normal male/female corpse ID. S08 Distributions.lua:489-540 and 554-609 defines default inventoryfemale/inventorymale with rolls=1 and IDcard_Female/IDcard_Male weight 20 (lines 515/580). **20 is a loot-table weight, not a demonstrated 20% probability.** Outfit overrides, nested bag/wallet generation, loot modifiers and native roll logic affect actual results. Do not add a second identification roll.

N13 ItemCodeOnCreate public static void onCreateIDCard(InventoryItem), onCreateIDCardFemale(InventoryItem), onCreateIDCardMale(InventoryItem) delegate to private onCreateIDCard(InventoryItem,boolean). That method offsets 0-59 customizes name/lockedBy after item creation. It is not the zombie eligibility decision or proof of an ID probability. Tags base:idcard and base:applyownername in S02 do not establish military rank.

## Exact generation path and hook constraints

| Stage / exact native surface | Observation and reference |
|---|---|
| IsoZombie.onKilled(IsoGameCharacter,HandWeapon,boolean) | N07 offsets 38-52: when not client, DoZombieInventory(); then OnZombieDead(zombie). This rebuild includes original worn/attached/death-spawn items, not necessarily all later corpse loot rolls. |
| public void IsoZombie.DoZombieInventory(); public void DoCorpseInventory(); private void DoZombieInventory(boolean) | N07 private method offsets 15-73 dress persistent outfit on server if needed, clear inventory, rebuild from visuals; offsets 201-328 spawn queued death items. Private method is not a Lua extension hook. Never call a rebuild to add credentials. |
| RequestItemsForContainerPacket.processServer(PacketType,UdpConnection) | N10 offsets 8-33: reject null/explored, setExplored(true), then ItemPickerJava.fillContainer(container,actualPlayer); offsets 36-70 send resulting items. At least this ordinary first-open path is server-owned/lazy. |
| static void ItemPickerJava.fillContainer(ItemContainer,IsoPlayer) | N06 delegates to private fillContainerInternal; internal offsets 0-18 return on client/tutorial. Inventorymale/female branch recognizes IsoDeadBody and gets outfit name (offsets 106-133); outfit/default rolls at 360-414. |
| OnFillContainer("Zombie",outfitName,container) | N06 fillContainerInternal offsets 430-439, after rolls and before N10 sends results. Bag callbacks also exist with different first/third arguments; do not blindly treat every OnFillContainer as a corpse-root event. |

LuaManager$Exposer snapshot registers IsoZombie:1976, ItemPickerJava:2214 and ItemContainer:2213. OnFillContainer is a real native-triggered event, but original-piece provenance/first-fill classification is still missing. Native signatures and registration are source evidence, not runtime tests.

## Proposed replacement contract, not implementation approval

Use one bounded authoritative post-roll callback on a newly generated eligible corpse, after native ID roll but before publication. Replacement must consume no new RNG roll and leave unrelated loot/probability logic unchanged. Original military outfit and original officer-piece membership must have been recorded at a verified server birth/dress stage and survive corpse conversion; a post-loot clothing scan cannot supply that provenance. No usable protected birth/dress hook was established in this bounded audit. getOutfitName()/getPersistentOutfitID() are source candidates, not immutable original-item receipts.

Define exactly which normal ID FullTypes and which container levels count. Multiple native root/nested IDs may exist; one-for-one replacement versus one-card-per-corpse must be reconciled without changing the requested distribution. Do not collapse rolls, add rolls, rewrite global tables temporarily around a roll, or manufacture credentials where no normal ID was generated. Until that policy/provenance is proved, leave the original loot intact and report MS02.

No re-opening/repeated-fill replacement, periodic corpse scans or rewriting already generated historical corpses. Newly filled older corpses also require reliable eligible origin; unknown origin remains unmodified. Transferring officer clothing onto a corpse must never enroll it.

B47HE.ArmyCredentials remains provisional: transferable original card, no durability, removable before authorization and consumed only by a safe committed request. No artwork was created; early-1990s identification design needs historical/art provenance review, not a copied modern ID. The item cannot be production-integrated before custody/authorization and natural obtainability are resolved.

## Smallest dedicated test and limitations

After review and separate test permission: disposable natural military-zone population; record original outfit and piece GUID/full type at a verified native birth stage, death, first container request and post-fill outcome. Compare female/male/both/neither, civilian same-coat, police, transferred corpse clothing, duplicate requests, old explored/unexplored corpses and root/wallet IDs. Keep all native probabilities unchanged and perform no replacement initially. Then a separately authorized deterministic comparison must prove no extra roll/ID/credential and no change for ineligible populations. All NOT TESTED; clean provenance UNKNOWN; G7/G8 blocked.
