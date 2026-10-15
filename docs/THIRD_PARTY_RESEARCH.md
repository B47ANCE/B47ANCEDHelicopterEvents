# NPC mod combat comparison: clean-room research ledger

Date: 2026-10-15. Project version: [root VERSION](../VERSION), unchanged at 0.1.0-dev.3. Baseline cc494cf2f6cd92dd9295643eacdf2f7431920490. Purpose: determine whether A-Life, Project Remnants or another installed NPC mod demonstrates a Lua-only, server-authoritative ownership/result path for helicopter damage to ordinary zombies. **No third-party code/assets imported; no integration or gameplay implementation. MS04 remains NO-GO under the examined contracts.**

## Provenance and rights

| Reference | Author / identity / version | Access and license status |
|---|---|---|
| [Project A-Life](https://steamcommunity.com/sharedfiles/filedetails/?id=3803984183) | Vice / A-Life team; Workshop 3803984183, Mod ID ProjectALifeNPCs. Selected local mod.info declares 1.4.2 and versionMin 42.21.0, despite its 42.20 directory name. | User confirmed queued download. Files became readable in Steam's downloads staging, not installed content. No affirmative reuse license established; inspection only, no permission to import. |
| [Project Remnants](https://steamcommunity.com/sharedfiles/filedetails/?id=3738362476&l=english), [author installation guide](https://github.com/Patricklumowa/ProjectRemnants-Installation-Guide) | Patrick / Datpat and Klosop; Workshop 3738362476, Mod ID ProjectRemnants. Public page advertises v0.3.0; examined local metadata does not declare an exact version. | Queued/staged files inspected read-only. Public author notice reserves rights and requires permission for copying. No reuse permission obtained; no JAR implementation decompiled. |
| [Bandits NPC](https://steamcommunity.com/sharedfiles/filedetails/?id=3268487204) | Slayer / Piotr Pawlowski; Workshop 3268487204, Mod ID Bandits2. Installed 42.21 folder; metadata says V2 / B42.20+ SP/MP, exact local release version UNKNOWN. | Existing installed content inspected read-only as an additional NPC comparison. Author restricts copying/reupload without permission. No reuse permission obtained. |

[THIRD_PARTY_RESEARCH_INDEX.json](THIRD_PARTY_RESEARCH_INDEX.json) fingerprints 17 selected files with item-relative paths and exact line ranges: A01-A07, B01-B07, R01-R03. Absolute machine paths, full source bodies, assets, installers, logs and downloaded packages are excluded from Git. A-Life and Remnants staging is explicitly **not** a verified complete Workshop package. Selected hashes are rechecked before final validation; a changed/missing file invalidates that snapshot rather than becoming proof of a different version.

Web descriptions identify author claims/requirements; local files establish the observations below. [VERIFIED: source] is not engine execution or a dedicated acceptance result. No third-party mod, installer or JAR was executed, subscribed, moved, repaired or installed by this task; Steam's existing user-controlled queue was left alone. No assertion about either mod's overall quality, security or all unexamined combat paths follows from this bounded review.

## A-Life: delegated execution and separate NPC health

[VERIFIED: source] A02 ALifeExecutor.lua:238-283 defines multiplayer execution on a client, server delegation and body ownership checks. Its start at 2262-2265 refuses the wrong execution side; 3292-3309 register client start/tick handling. A04 ALifeAIFence.lua:1827-1830 explicitly refuses to drive bodies on the dedicated server. These checks matter more than the directory containing a behavior module: a file under server is not evidence that every function in it executes exclusively on the server.

There are distinct target paths:

- **Ordinary zombies:** A05 ALifeModuleGunner.lua:247-272 requires authority over the shooter body; on a client it refuses a remote target, then attempts native Hit with a real zombie shell as attacker. A06 ALifeCombatStrike.lua:843-866 contains another path that computes a wound, directly changes zombie health and invokes native Kill for a lethal result; 890-945 separates NPC targets from ordinary zombies. The target-ownership check observed in A05 must not be generalized to every path in A06. These are client-execution/body-control leads, not a discovered dedicated server lease or generic server-origin native result API.
- **A-Life NPC targets:** A07 ALifeNPCHitRelay.lua:54-68 sends an actor-to-actor hit request with actor identities. A02:523-566 checks the reporting player's body binding/ownership, generation and rate/state conditions. A02:669-740 sends NPC health to the relevant owner; A03 ALifeShellSimulation.lua:510-543 checks matching execution/body generation and health revision before applying it. This is meaningful server participation, not merely an unconditional client relay. Its scope is the mod's registered NPCs and health state, not every vanilla zombie.
- **Native ownership observation:** A03:329-333 recognizes a local body using isClient and isRemoteZombie. No use of NetworkZombieManager, NetworkZombiePacker, setOwner/setAuthOwner, parseZombie or syncHealth/syncDamage was found in a targeted text search of this staged Lua tree. Absence of these literal names is bounded negative evidence, not a complete alias/call-graph proof.

[VERIFIED: source inventory] No .java/.class/.jar members were found in the selected staged A-Life mod root. The author's public description also says no Java installation is required. No runtime dependency/load-order audit or completed-package verification was performed.

**Result:** A-Life demonstrates a source-backed Lua approach built around native client body ownership and additional control of its own NPC health. It does not establish the requested server-only target choice, damage resolution and native synchronization against ordinary zombies. Its custom NPC health acknowledgements must not be mistaken for a hook that rejects stale native zombie packets. No A-Life code, formulas, schemas or system layout is proposed for transplantation.

## Remnants: native extension, not a Lua-only comparison

[VERIFIED: author documentation] The current Workshop page describes a single-player-focused alpha and requires a Java agent. Its installation guide adds NPCFW.jar and a javaagent launch argument. [VERIFIED: staged metadata] R03 NPCFW.jar has a Premain-Class manifest entry. R02 NPCFW_Main.lua:24-32 checks custom npcfw readiness/init/load functions; those are extension APIs, not verified vanilla Lua bindings. R01 supplies the current Mod ID but no local version field.

**Result:** Remnants can provide human-actor features through a different engine surface. Its Java requirement excludes it as a dependency or solution under this project's current rules; its published scope is not dedicated MP evidence. Inspecting/decompiling the agent or running its setup would not help establish an authorized vanilla Lua route, so neither was done. No inference that its combat solves vanilla headless ownership is made.

## Bandits: client hits and health rebroadcast

[VERIFIED: source] B02 BanditUpdate.lua:2071-2076 excludes the server, processes tasks at 2267-2274 and registers the zombie update at 2632-2639. B03 ZAShoot.lua:25-48 consumes ammunition in the shooting action; its later line-of-fire call reaches B04 BanditUtils.lua:551-575 and the local hit helper at 243 onward. B04:350-379 applies native Hit and sends a health report. B07 ZASmack.lua:418-451 also applies a local hit and reports resulting health.

B05 BanditServerSync.lua:1-6 rebroadcasts the health message. The larger server-side health/death mutation examples in that file are commented out, not active proof. Its command dispatch is at 47-57. B06 BanditClientCommands.lua:28-40 looks up a local cached body and only lowers its health to the received value. This identifies an inspected client-generated result/rebroadcast path; it is not evidence of a server-resolved shot, lease, native queue fence or the behavior of every Bandits subsystem.

**Result:** Existing Lua NPC combat is feasible with a different trust/execution boundary. Copying that boundary would conflict with this project's requirement that the server choose targets, resolve hits and own damage/ammunition. A lower-health-only client correction also does not demonstrate composition with healing, delayed normal attacks, native ownership reassignment or restart. No code, constants or compatibility dependency is imported.

## Neutral behavior contract for our independent work

The comparison changes the research direction, not the mandatory release requirements. A full invisible human NPC is unnecessary just to obtain a native attacker argument. The next independent design question is whether the server can resolve a shot while the current native owner acts only as a constrained result applicator. That could preserve server gameplay authority **only if** native result ordering, stale-write exclusion and owner migration are established; simply asking a client to calculate damage is outside scope.

Inputs would be an already server-approved mission/shot, exact currently loaded target identity and authoritative damage outcome. Outputs must be one native health/death result shared by owner, observers and subsequent owners. The server must retain targeting, ammunition, RNG, range/cover checks and terminal decisions. Missing/changed owner, target identity or result contract rejects the shot before unsafe mutation. Ordinary player damage must compose in both orders; late/reconnecting clients must receive current state without replaying damage. These requirements derive from our existing [ownership/result contracts](GUNNER_OWNERSHIP_RESULT_AUDIT.md), not a copied third-party algorithm.

No reviewed mod supplies a proved native packet fence for that contract. In particular, claiming all vanilla zombies as custom NPCs, writing health repeatedly, assigning a fabricated player or requiring an agent are not accepted fallbacks. Source-backed owner-side result application remains an **UNKNOWN research candidate**, not an approved implementation or a cleared blocker. Existing MS01-MS03 authorization/loot/persistence blockers remain independent.

## Review and validation

- [x] Purpose, author/identity, version limits, URLs and local fingerprints recorded.
- [x] No third-party source, pseudocode, nontrivial algorithm, assets, installer or dependency imported; production source untouched.
- [x] Description/MP claims separated from source inspection and unexecuted runtime behavior.
- [x] Unknown/restrictive reuse rights preserved; no license or permission inferred from visibility. Any later import would require separate rights/approval review and applicable notices.
- [ ] Independent clean-room reviewer signoff: PENDING. This research PR is not approved for merging or implementation by this self-check.

Offline document/version/source checks and the unchanged audio mock regression are recorded in [VALIDATION.md](VALIDATION.md). Hashes verify the inspected bytes, not a complete download, engine binding, native ordering, dedicated behavior or legal clearance. No SP/dedicated test was performed. G-R01..10 and S-R01..24 stay NOT TESTED; MS04 remains NO-GO for mutating combat; G7 BLOCKED / NOT TESTED, stable-release G8 BLOCKED. Stop for findings review.
