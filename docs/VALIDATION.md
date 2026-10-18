# Phase 0 validation records

## Deferred wreck-model intake — 2026-10-17

Baseline main f9c55d7911bda580c0cdc21b55a4776e2a52345b; named branch assets/crash-model-intake. Earlier PRs #4/#5/#6 were merged; old feature source tree was identical, and no user files were reconciled/reset. Root version remains 0.1.0-dev.4: asset-reference/documentation work only, no new runtime/export/API/config/save checkpoint. [CRASH_MODEL_ASSETS.md](CRASH_MODEL_ASSETS.md) records the source/preview limitations and pending adaptation. [Manifest](../assets/crash-sites/MANIFEST.json) pins four supplied sources and archive/image/mesh observations. Sources/previews are locally retained and ignored, never claimed as public backups. No original Download was modified.

Exact offline commands (bundled Python, NumPy/Pillow for local file inspection):

```text
python -B .tmp-model-intake/inspect.py
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python <installed-hub>/tools/mod_overview.py --describe-repository <repository> --project-id heli
python -B .tmp-model-intake/verify.py
git diff f9c55d7911bda580c0cdc21b55a4776e2a52345b -- src tests scripts VERSION thumbnail.png assets/branding
git diff --check
git diff --cached --check
```

[TESTED: offline] Version consistency PASS before/after; document links/gates and unchanged runtime source checks STATIC PASS. Private inspection validates exact byte copies/hashes for four files, GLB headers/chunk/accessor/index bounds, finite position/normal/UV data and counts, identity nodes, texture decoding/dimensions, ZIP path/case uniqueness/expanded-size bounds and CRC. An initial preview guard correctly stopped on explicit identity matrices; it was narrowed to permit verified identity matrices and the complete inspection then passed. Textured vertex projections were visually inspected; they are not surface/PBR or game renders. Base-color similarity supports only inferred GLB/FBX pairings. FBX geometry import/triangulation and model topology were not validated.

Blender MCP status reported no connection; no live scene could be inspected or changed. No paid Meshy call, .blend, rig, conversion or game export. No gameplay regression suites rerun because src/tests/scripts are byte-unchanged from baseline; earlier tests retain their original environments. First project-owned MOD_OVERVIEW descriptor adopts catalog ID heli, binds existing version/runtime-source digest and separates foundations/planned/blocked work; adding its version mirror does not alter canonical VERSION. Its digest excludes local authoring binaries and is not a model integrity proof. No dependency/integration was invented. Public staged/tracked review excludes binary models/derivatives, source snapshots, logs, credentials and local settings. Commit/remote/PR status is reported separately.

Native SP/dedicated, Blender import and engine asset/placement/collision/streaming/persistence NOT TESTED. Crash NO-GO findings unchanged; project G7 BLOCKED / NOT TESTED, stable-release G8 BLOCKED. No game/server launch, installed-file edit, packaging, deployment or Workshop publication.

## Read-only support preflight implementation — 2026-10-16

Baseline 6eb56fa011f43ab2ac9acebdfe67ad7bf5e348d7; feature/support-preflight-probe branches from the existing audit PR. Canonical version advances from 0.1.0-dev.3 to 0.1.0-dev.4 with all declared mirrors synchronized. This is an additive diagnostic checkpoint within the pending initial 0.1.0 feature line, no incompatible API/config/save change. The [implementation contract/evidence](SUPPORT_PREFLIGHT_PROBE.md) documents the source-only native boundary and the restricted manual API. This change introduces no support gameplay, military equipment, context menus, persistent authorization, missions, following, loot, attraction or combat. Rotor Lua modules and artwork are byte-unchanged; historical evidence retains its original checkpoint.

Exact offline commands (bundled Python interpreter; Lupa Lua 5.1 only):

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python -B scripts/test_audio.py
python -B scripts/test_support_probe.py
python -B .tmp-support-preflight/verify.py
python <pz-api-audit>/scripts/api_library.py record --entry .tmp-support-preflight/api-entry.json
python <pz-api-audit>/scripts/api_library.py validate --library <user-profile>/.codex/pz-api-audit/library.local.json
python -B .tmp-support-preflight/public_review.py
git diff --check
git diff --cached --check
```

[TESTED: offline] Version consistency PASS before/after edits; source/require-case/options/English localization/art checks and document links/gates STATIC PASS. Support suite: 14 core scenarios and four fake server/host/client/SP adapters PASS, including injected API exceptions that deliberately print diagnostic-stopped messages. Existing audio suite: 17 behavior cases and three adapters PASS. Both test runners compile the current Lua source but neither imports PZ, Kahlua, native classes, FMOD or real network transport. No new ordering/lethal model run was necessary: those models and combat remain unchanged.

[VERIFIED: source/bytecode] Local read-only javap -c -p inspection of ItemContainer and DeviceData plus private checks rechecked Steam/JAR, two text files, four packaged/loose fingerprints, the nonrecursive direct-ID lookup and four direct-field device getters without native calls/writes. No custom Java was compiled or engine class instantiated. Source index is portable; native bodies/verifier output stay private. One reusable source-call observation was recorded in the unmanaged local API draft; helper record/validate PASS (245 total draft records). Managed catalog untouched. Private helpers are not public reproducibility dependencies; missing private installed evidence means unavailable evidence, never an inferred PASS.

Eight new P-R dedicated scenarios remain NOT TESTED; earlier audio/support/gunner/lethal/menu scenarios are not promoted. Staged/tracked public boundaries, secret-pattern scan and manual diff review exclude raw native/third-party source, assets from external mods, logs, private settings, credentials and packages. Git backup/PR status is reported separately. No CI success inferred; inherited third-party research signoff stays pending. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. No game/server launch, installed-file modification, package, deployment or Workshop publication.

## Selected thumbnail and context-menu requirements — 2026-10-15

Asset/documentation-only change from baseline 8a6f44c7d031316fc4506a830058ecf4f27bbccb on docs/military-support-audit. Current/target authoring version stays 0.1.0-dev.3: no gameplay, public API, configuration or save compatibility change and no new implementation checkpoint. Root thumbnail.png is the exact supplied helicopter image; [BRANDING.md](BRANDING.md) records size/hash/provenance. Icon/poster, fallback art, production source, tools, tests and version inventory are byte-unchanged from baseline. [CONTEXT_MENU_CONTRACT.md](CONTEXT_MENU_CONTRACT.md) records the direct user requirements, distinguishes reference handoffs from current authorization, and adds eight unexecuted U-R cases. No new native API finding, resolved blocker or completed broader handoff audit is claimed.

Commands executed with the bundled Python interpreter (Pillow used only to inspect the PNG):

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python -B -c "from pathlib import Path; from PIL import Image; import hashlib; p=Path('thumbnail.png'); b=p.read_bytes(); assert len(b)==1532650; assert hashlib.sha256(b).hexdigest()=='46dd0ab5bc851ca2443a182db3be35eb0c3e3a69a304ec8f2ae27183fd7beb69'; im=Image.open(p); assert (im.format,im.size,im.mode)==('PNG',(1254,1254),'RGB'); im.verify(); print('PNG integrity PASS')"
git diff 8a6f44c7d031316fc4506a830058ecf4f27bbccb -- src assets VERSION version-inventory.json scripts tests
git diff --check
git diff --cached --check
```

[TESTED: offline] Version consistency PASS before/after edits; document links/gates and bounded Lua-only audio source checks STATIC PASS. PNG metadata/decode/hash PASS; an additional in-memory comparison against the original user attachment confirmed exact byte equality. Source-invariance diff is empty; eight U-R rows are all NOT TESTED. Supplied image visually inspected. No new test script or runtime regression suite was needed for unchanged gameplay. Whitespace and staged/tracked public-surface review recorded with this change; no private attachment text, native/third-party implementation, logs, credentials or package included. Git commit/push status is reported separately.

Exact Build 42.21 menu hooks, localization, controller behavior, custody/authorization and targeting integration still need source review before affected implementation. Game/server/Workshop rendering and all new UI/MP cases NOT TESTED. Existing API and persistence/combat verdicts unchanged. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. No game/server launch, gameplay implementation, installed-file modification, packaging, deployment or Workshop publication.

## Native lethal result and replication - 2026-10-15

Source/design/tooling extension of docs/military-support-audit at baseline 736c490f89c07eab56d740bfead273694b489784. Root version stays 0.1.0-dev.3; no gameplay/API/configuration/save compatibility change. [NATIVE_LETHAL_RESULT_AUDIT.md](NATIVE_LETHAL_RESULT_AUDIT.md) identifies the terminal Lua binding/lifecycle/native publication route and its limits. [L01-L32 index](NATIVE_LETHAL_SOURCE_INDEX.json) fingerprints packaged members and loose counterparts. New scripts/audit_lethal_interleavings.py is a standalone offline abstract branch model, not a PZ combat probe. No additional third-party implementation inspection or imports; earlier clean-room signoff remains PENDING.

Exact repository validation commands (bundled Python interpreter):

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/audit_combat_interleavings.py
python -B scripts/audit_lethal_interleavings.py
python -B scripts/audit_lethal_interleavings.py --json
python -B .tmp-lethal-audit/verify.py
git diff --check
git diff --cached --check
git diff 736c490f89c07eab56d740bfead273694b489784 -- src assets VERSION version-inventory.json tests scripts/check_versions.py scripts/audit_combat_interleavings.py scripts/validate_audio_sources.py scripts/validate_phase0_docs.py scripts/test_audio.py
```

[TESTED: offline] Version consistency PASS before/after edits; portable documentation/gates STATIC PASS. Private standard-library verify.py rechecks Steam/JAR and 32 native/loose fingerprints, selected metadata/method observations, public/final/no-HiddenFromLua filters, native sender/removal/auth pruning and finite corpse predicate; STATIC PASS. Native inspection used javap -c -p and -v metadata against the packaged JAR, never engine class instantiation. Its detailed output remains private/ignored. Five INFERRED / NOT_TESTED reusable API findings were recorded in the unmanaged local draft; helper record/validate PASS (209 total records), no managed catalog changes. Private source verification is not a public reproducibility dependency for either standalone model.

New model assertions PASS: 17 cases, seven expected limitation counterexamples. The existing nonlethal model still passes 28 schedules (11 expected counterexamples). These are bounded branch models, not native calls, engine failures or proof of client completion. No new audio suite run: runtime/source/assets/tests and all existing check scripts are byte-unchanged from baseline; earlier audio results retain their recorded environment. Ten new L-R rows join the ten G-R and 24 S-R rows, all 44 NOT TESTED. Runtime guards/VALIDATION_STATUS remain unchanged. Whitespace and staged/tracked public-surface checks PASS; only intended project documentation, fingerprints and the new offline model included, with no native bodies, third-party sources/assets, credentials, logs, private settings or packages. Git/remote backup is reported separately; no CI result inferred.

Conclusion: a source-supported terminal entry/result sender and post-removal map protection are identified, narrowing that sub-blocker. A disposable loaded-target lethal probe is CONDITIONAL for review only, not implemented/approved to run. Immediate owner-field clearing is not assumed; invalid-ID authorization pruning is recorded. Nonlethal synchronization, expired/missing corpse guards, streaming/ID reuse, native attribution and restart durability remain explicit limitations/gates. Complete armed-support scope is not approved by a terminal candidate. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. No gameplay implementation, engine launch, installed-file edit, package, deployment or Workshop publication. Stop for findings review.

## CSR Knox Syndicate comparison - 2026-10-15

Documentation-only extension of docs/military-support-audit at baseline 7df75bcaf57a15b75146e021ca5a922b39eef084. Root version stays 0.1.0-dev.3; no gameplay/API/configuration/save compatibility change. [CSR_AIR_SUPPORT_RESEARCH.md](CSR_AIR_SUPPORT_RESEARCH.md) records the user's confirmation of explicit author inspection/reporting permission, the official 2.0.25 package and neutral source findings. No reuse/source-redistribution permission inferred. [CSR_AIR_SUPPORT_SOURCE_INDEX.json](CSR_AIR_SUPPORT_SOURCE_INDEX.json) records eight text/two optional JAR fingerprints plus three native members. Package/source remain private and ignored, outside installed mods. No third-party code/assets adopted.

Exact repository commands (bundled Python interpreter):

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/audit_combat_interleavings.py
python -B .tmp-csr-research/verify_csr.py
git diff --check
git diff --cached --check
git diff 7df75bcaf57a15b75146e021ca5a922b39eef084 -- src assets VERSION scripts tests version-inventory.json
```

[TESTED: offline] Version consistency PASS before/after edits; portable documentation/gates STATIC PASS. Official archive byte count and SHA-256 match the manifest/listing; full ZIP CRC PASS. Private verify_csr.py re-reads the archive and eight selected research copies, checks text/JAR hashes and inclusive ranges, three packaged/loose native fingerprints, JAR/Steam build and negative literal-symbol inventories; STATIC PASS. The source summary does not claim its member-name/symbol scan proves runtime binding or excludes dynamic injection. Optional JAR inspection was limited to archive/class-symbol metadata, not implementation decompilation or execution. Native javap -c -p inspection never instantiated engine classes. Three uncertain/negative API records were added to the unmanaged draft; helper record/validate PASS (204 total records), no managed catalog edits.

The unchanged abstract ordering model still passes its 28 schedule assertions: 17 preserving under assumptions and 11 counterexamples reproduced. This is not a test of CSR or a terminal-death contract. Existing audio regression results remain historical at their recorded baseline; not rerun because runtime/tooling/assets/tests are byte-unchanged. All ten G-R and 24 S-R rows remain NOT TESTED. Whitespace and staged/tracked public-surface checks PASS; no package, raw third-party/native body, private diagnostics/settings or credentials staged. Exact Git/remote backup status is reported separately. Independent clean-room signoff stays PENDING; no CI result manufactured.

Result: CSR establishes a source-backed server target/terminal-mutation loop; a native terminal-death/publication route is a narrower CONDITIONAL audit candidate. Its guarded becomeCorpseSilently call is not a verified vanilla Build 42.21 entry; setHealth alone has no death/send in its body. No runtime failure reproduced, no native nonlethal ownership/result contract cleared, no mutating probe implemented or approved. MS01-MS04 remain open; G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. No installer, mod module/JAR or engine run, installed-file changes, release packaging, deployment or Workshop publication.

## Combat ordering and ordinary damage - 2026-10-15

Research/tooling extension of docs/military-support-audit, baseline e63e5c05e861f27753835155e8f16fb733552621. Root version remains 0.1.0-dev.3; no runtime/API/configuration/save compatibility change or new version checkpoint. [COMBAT_ORDERING_CONTRACT.md](COMBAT_ORDERING_CONTRACT.md) and [T01-T15 source index](COMBAT_ORDERING_SOURCE_INDEX.json) record native transport configuration, current-owner acceptance and unresolved handoff/result contracts. New scripts/audit_combat_interleavings.py is a project-owned offline integer-state model, not gameplay/probe implementation or an engine simulation.

Exact repository commands (bundled Python interpreter):

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python -B scripts/test_audio.py
python -B scripts/audit_combat_interleavings.py
python -B scripts/audit_combat_interleavings.py --json
python -B .tmp-ordering-audit/verify_sources.py
git diff --check
git diff --cached --check
git diff e63e5c05e861f27753835155e8f16fb733552621 -- src assets VERSION version-inventory.json tests
```

[TESTED: offline] Version consistency PASS before/after edits; documentation/source checks STATIC PASS; unchanged audio suite 17 fake-boundary cases and three event adapters PASS. Model assertions PASS: 28 bounded schedules, 17 preserving assumed damage and 11 expected counterexamples reproduced. These numbers are model coverage, not protocol success rates or engine outcomes. Stable-owner delta arithmetic is conditional on one intact context and exactly one application; native Hit, death and transport are not exercised.

The ignored/private verify_sources.py uses standard-library ZipFile/hashlib, Steam manifest matching, row checks and the model's JSON output: current JAR/Steam build, all 15 member/loose fingerprints and 34 NOT TESTED G-R/S-R rows STATIC PASS. It exports three project-summary records to the unmanaged local API draft; record/validate helper actions PASS (201 total draft records). No managed catalog edited. Native inspection uses javap -c -p, with -v for annotation/constants metadata, against the indexed packaged classes; exact observations/offsets are in the contract. No native class instantiated or engine launched. Private extractor/inspection output is deliberately not a public reproducibility dependency for the standalone model.

Runtime source/assets/VERSION/version inventory/tests remain byte-unchanged from baseline; the only new executable file is the offline model. Whitespace and targeted staged/tracked public-surface review PASS; no raw native/third-party bodies, private logs/settings, credentials or generated packages included. Existing clean-room independent signoff remains PENDING. Public Git backup/PR update are reported separately; no CI or runtime result is inferred from them.

Result: supported common ordering, owner-transfer operation inclusion and preservation of ordinary damage are not established. MS04/mutating probe NO-GO; no health clamp, player-hit interception, fake player attribution or client-selected outcome workaround. All G-R/S-R cases NOT TESTED; G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. No gameplay implementation, engine launch, installed-file change, package, deployment or Workshop publication. Stop for findings review.

## Third-party NPC comparison - 2026-10-15

Documentation-only extension of docs/military-support-audit, baseline cc494cf2f6cd92dd9295643eacdf2f7431920490. Version remains 0.1.0-dev.3; no gameplay/API/configuration/save compatibility change. [THIRD_PARTY_RESEARCH.md](THIRD_PARTY_RESEARCH.md) is a neutral behavior/provenance ledger for staged A-Life 1.4.2, staged Remnants metadata and installed Bandits. [THIRD_PARTY_RESEARCH_INDEX.json](THIRD_PARTY_RESEARCH_INDEX.json) records 17 selected file fingerprints/ranges and explicit source states. Steam's user-controlled queue was not operated; readable staged files do not authenticate a completed package.

Exact repository validation commands (bundled Python interpreter):

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python -B scripts/test_audio.py
git diff --check
git diff --cached --check
git diff cc494cf2f6cd92dd9295643eacdf2f7431920490 -- src assets VERSION version-inventory.json scripts tests
```

[TESTED: offline] Version consistency PASS; document/source checks STATIC PASS; unchanged 17 fake-boundary audio cases and three event adapters PASS. Inline Python hashlib/range checks re-read all 17 indexed third-party files and confirm their selected hashes/line bounds unchanged; STATIC PASS. Remnants JAR was opened only for its Java-agent manifest metadata, not class bodies. A staged A-Life source inventory found no .java/.class/.jar files in the selected mod root; this is not a full dependency/runtime audit. Ten G-R and 24 S-R rows remain NOT TESTED. Runtime source/assets/version/scripts/tests are byte-unchanged from this baseline. Whitespace and targeted staged/tracked public-surface checks PASS; no third-party bodies/assets, private snapshots, credentials or generated outputs included. Two INFERRED / NOT_TESTED reusable observations were recorded in the unmanaged API draft.

Clean-room self-check records no imports or adopted implementation; independent reviewer signoff remains PENDING, not fabricated. No permissions/license clearance for code reuse was inferred. Public primary descriptions were consulted alongside local selected source, not substituted for runtime evidence. No third-party or PZ game/server/installer/JAR was executed, installed, deployed or published by this work. No mutating combat probe implemented. MS04 unchanged; G7 BLOCKED / NOT TESTED, stable-release G8 BLOCKED. Findings await review.

## Ownership/result path trace - 2026-10-15

Documentation-only extension of docs/military-support-audit, baseline 88443396b76781a95635a25ce41eab2323fca72e. Version remains 0.1.0-dev.3; no gameplay/API/configuration/save compatibility change. [GUNNER_OWNERSHIP_RESULT_AUDIT.md](GUNNER_OWNERSHIP_RESULT_AUDIT.md) records six unresolved contracts and a NO-GO for the mutating combat probe. [OWNERSHIP_RESULT_SOURCE_INDEX.json](OWNERSHIP_RESULT_SOURCE_INDEX.json) fingerprints 24 packaged native members, targeted loose counterparts and one installed server Lua caller. Raw native output stays private/ignored.

Exact commands from repository root, using the bundled Python interpreter:

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python -B scripts/test_audio.py
git diff --check
git diff --cached --check
git diff 88443396b76781a95635a25ce41eab2323fca72e -- src assets VERSION version-inventory.json scripts tests
```

[TESTED: offline] Version consistency PASS; document/source checks STATIC PASS; 17 unchanged fake-boundary audio scenarios and three event adapters PASS. Inline Python ZipFile/hashlib checks revalidated JAR/Steam build, 24 native members, loose comparisons and L01 Lua file; STATIC PASS. Constant-pool manager-reference inventory still matches the recorded five members. Static inspected-text checks confirm empty inherited syncHealth/syncDamage and no NetworkZombieAI override. Ten G-R and 24 S-R rows remain NOT TESTED. Runtime source/assets/version/scripts/tests remain byte-unchanged from the stated baseline. Whitespace and staged/tracked public-surface checks PASS; no raw native bodies, private snapshots, credentials or generated outputs included.

[TESTED: offline ordering models only] A queued owner A health=1.0 packet can replace server health=0.7 after a Lua result acknowledgement while A is current owner; A-to-B-to-A reassignment has the same counterexample. The native delay predicate applies to a recent non-null owner but not null. Assertions PASS; these are models of inspected branches, not an engine reproduction or a working barrier. Five INFERRED / NOT_TESTED reusable observations were recorded in the unmanaged local API draft; catalog structure validation PASS.

No custom Java, gameplay/probe implementation, native proxy/actor allocation, hit, packet send, engine launch, installed-file mutation, package, deployment or Workshop publication. No complete supported ownership/result path established. No CI or runtime PASS claimed. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.

## Lua-only gunner follow-up - 2026-10-15

Documentation-only extension of docs/military-support-audit, baseline 8fefbe0f90b9ccdab0f1d6339d62f7c35b3d8611. Version remains 0.1.0-dev.3; no gameplay/API/configuration/save compatibility change. [DOOR_GUNNER_LUA_FEASIBILITY.md](DOOR_GUNNER_LUA_FEASIBILITY.md) records the genuine native survivor candidate, native Hit consequences, current-owner health overwrite counterexample and unresolved lifecycle/ownership/result contracts. [GUNNER_SOURCE_INDEX.json](GUNNER_SOURCE_INDEX.json) contains 19 native member and one installed Lua caller fingerprints. Raw inspection output stays private/ignored.

Exact repository commands (bundled Python interpreter):

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python -B scripts/test_audio.py
git diff --check
git diff --cached --check
git diff HEAD -- src assets VERSION version-inventory.json scripts tests
```

[TESTED: offline] Version consistency PASS; documentation links/gates and bounded unchanged Lua source checks STATIC PASS; 17 existing fake-boundary audio cases plus three event-adapter fixtures PASS. An inline Python ZipFile/hashlib check rechecked JAR/Steam build, all 19 native members, loose-class comparisons and L01 installed Lua file against the new index; STATIC PASS. Ten G-R and 24 S-R cases remain NOT TESTED. The final diff command returns no changes: source/assets/version/scripts/tests are unchanged from this follow-up baseline. Whitespace checks PASS; targeted staged/tracked review excludes credentials, private snapshots, native bodies and generated output.

[TESTED: offline ordering model only] Start health=1.0 with queued owner A snapshot=1.0; subtract 0.3 on server; accepting that owner restores 1.0. A hypothetical owner=None fence rejects that snapshot, but reassigning A while it retains the snapshot accepts 1.0 again. Assertions PASS. This models inspected assignments; it is not an engine failure reproduction or a tested ownership solution. Four reusable INFERRED/NOT_TESTED findings were recorded in the unmanaged local API draft; neither catalog membership nor source fingerprints verify dedicated behavior.

No actor allocation, weapon creation, hit, packet send, game/server launch, installed-file edit, packaging, deployment or publication. MS04 remains NO-GO for complete combat; native survivor context is only CONDITIONAL research. Source inspection/offline checks do not satisfy G7. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.

## Military support API audit - 2026-10-15

Documentation-only branch docs/military-support-audit based on 81563f78ae0179f34f49385909c645bf6f9cf14e (open audio prototype PR #4). Six requested reports plus source fingerprint index; source, assets, metadata, canonical VERSION and runtime validation fields remain unchanged. Targeted installed script/native inspection, not engine execution. Military Air Support is the first complete release direction; crash blockers remain independent.

Commands: python -B scripts/check_versions.py --root .; python -B scripts/validate_phase0_docs.py; python -B scripts/validate_audio_sources.py; python -B scripts/test_audio.py; git diff --check; git diff --cached --check. A separate inline Python check verifies six document files, verdict labels, 24 NOT TESTED support rows, all current S01-S11 source hashes and N01-N19 packaged member hashes against SUPPORT_SOURCE_INDEX.json. No raw native/decompiled bodies are committed.

Results: version consistency PASS; documentation/source boundary checks STATIC PASS; all 17 existing audio fake-boundary scenarios and three fake event-adapter fixtures PASS (unchanged prototype regression, not support evidence). Six support reports, 24 NOT TESTED support rows and 11 text/19 native source fingerprints STATIC PASS; installed Steam build ID rechecked. Whitespace PASS. Public-surface review excludes private snapshots/raw native bodies, generated output and credentials. Runtime source/assets/metadata/VERSION are byte-unchanged relative to the audit baseline. No support gameplay, item/save changes, runtime tests, game/server launch, packaging, deployment or publication. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.

## Bounded audio implementation - 2026-10-15

Current version: root VERSION (0.1.0-dev.3), retained at the user's requested existing artwork checkpoint. Baseline main 126da35b65d0cecf39d251ba722e543cbc935ecc; clean startup, zero divergence from origin/main. Work occurs on feature/audio-prototype. Authoritative Lua source and metadata now exist under src/B47ANCEDHelicopterEvents/42; prior no-runtime assertions below describe their original dates. No historical reports/private game snapshots were regenerated.

Exact commands from repository root, using the bundled Python interpreter rather than the Windows Store alias:

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python -B scripts/test_audio.py
git diff --check
git diff --cached --check
```

[TESTED: offline Python / Lua 5.1 through Lupa 2.6] Version consistency PASS; document links/gates STATIC PASS (12 dedicated scenarios still NOT TESTED; 102 private links deliberately not validated). Bounded Lua-only source/metadata, exact-case requires, three option/English translation keys, payload ceiling and copied artwork byte checks STATIC PASS. All four Lua modules compile under Lua 5.1; 17 fake-boundary behavior scenarios PASS, including two clients and admin cancellation; three additional fake event-adapter fixtures PASS (server/client/SP) for registration, no immediate OnConnected handshake, headless isolation and disconnect/menu cleanup. Whitespace checks PASS. Source/tracked-file review excludes custom Java/dependencies, generated packages, private snapshots, diagnostic logs and credentials before push. Offline dependencies are listed in tests/requirements.txt and are not runtime requirements.

Installed JAR/member observations remain source inspection, not authenticated clean provenance or a Lua invocation. [AUDIO_IMPLEMENTATION_EVIDENCE.md](AUDIO_IMPLEMENTATION_EVIDENCE.md) records the current assumptions. Remaining gates include Kahlua overloads/native autoload, actual looping/stop tails/resource return, settings UI/fallback/existing saves, synchronization/event order/reconnect, packet isolation/no attraction, split-screen/acoustics and prolonged resource behavior. No game/server launch, packaging, deployment or publication. G6/SP NOT TESTED; G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. Do not run --release without separately authorized artifacts; there are none.

## Phase 1 contract preparation - 2026-10-14

Documentation only, current root VERSION unchanged. Baseline 17454de4b3c75d70288932968a1217760101ca76 is the merged Phase 0 audio review. The earlier feature branch differed from main only by that merge commit and had the same tracked file tree; this contract branch starts from verified origin/main. No runtime source, assets, mod.info, implementation, game/server launch, package, deployment or Workshop publication.

Commands: python -B scripts/check_versions.py --root .; python -B scripts/validate_phase0_docs.py; git diff --check. Use the existing bundled Python interpreter where the system alias is unavailable. Checks cover current documentation/version/links and unchanged NOT TESTED runtime gates; they are not execution of the new contract. Security review excludes private game snapshots, local settings and credentials before Git push. Results: version consistency PASS; portable documentation STATIC PASS (12 NOT TESTED audio cases, 102 private evidence links deliberately not validated); whitespace PASS; tracked public-surface audit found no prohibited artifacts or credential patterns. Freshness was REVIEW solely for these six intended documentation changes, with zero divergence from origin/main and no unfinished Git operation. Contract review remains PENDING; G6 NOT TESTED, G7 BLOCKED / NOT TESTED and stable-release G8 BLOCKED.

## Current documentation correction - 2026-10-14

Project version: ../VERSION, unchanged. This is a correction/extension of the existing documentation checkpoint, not a gameplay/API/config/save change or a new version iteration. No Phase 1, game/server launch, mod assets, packaging, deployment or Workshop publication. The public Git repository was created with user approval; initial main baseline ec5b9e5a9d090e5b1264c34f772de425c022a32c was pushed and remote-SHA verified before this feature-branch edit.

Exact commands from repository root (using the developer's existing Python interpreter):

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
git diff --check
git diff --cached --check
```

Version checks run before/after edits. The portable checker validates current links, twelve NOT TESTED dedicated audio scenarios, preserved runtime gates and tracked-file boundaries. It explicitly excludes private game-source links from source-validation claims. Staged/trackable content is inspected for credentials, private player data, logs, generated packages, local diagnostic snapshots and raw game source before each public push. Current validation status is in VALIDATION_STATUS.json. No CI or runtime result is manufactured.

Original evidence manifests still match 61 initial and 125 follow-up local files. The installed JAR still matches the earlier fingerprint; ten loose zombie classes changed, so current patched-install equivalence is NOT established. Source findings remain CONDITIONAL, and SP/dedicated audio are NOT TESTED. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. Original collectors/validate_audit.py are retained locally, ignored and not rerun to overwrite earlier evidence.

Current public mirrors are README, newest changelog entry and VALIDATION_STATUS.json. Earlier OFFLINE_VALIDATION.json and evidence-followup/environment.json retain their actual earlier provenance and are classified historical, not rewritten as current mirrors. Raw game/diagnostic/config files stay local. Git backup is verified separately in the final iteration report; a PR is not a merge or runtime approval.

## Historical 2026-10-09 follow-up record

The record below describes the original non-Git workspace and checks at that time. Its machine paths, no-Git assertion, original installed-file hashes and PASS counts are historical only; they are not current clean-install or runtime results.

Date: 2026-10-09 (America/Phoenix). Current project version: ../VERSION. Environment: Windows, offline source/document checks only. No PZ/server launch, installed-file edits, live deployment, assets/gameplay or packaging.

## Baseline and checkpoint

Before edits, scripts/check_versions.py and scripts/validate_audit.py passed against the accepted first audit. Its actual original offline-validation JSON and documents are preserved in docs/history/phase0-accepted with baseline-hashes.json. The initial 61-file evidence bundle was not refreshed or relabeled. This follow-up uses a separate evidence-followup bundle.

The target is the next documentation prerelease checkpoint; no PATCH/MINOR/MAJOR core bump, gameplay feature, public API/config/save compatibility change. Current mirrors: README, newest changelog entry, current offline-validation JSON and follow-up environment snapshot. Prior changelog/report entries remain explicitly historical. No mod.info/production constants exist.

## Executed validation commands

PowerShell from C:/Users/willi/Desktop/Repositories/Project Zomboid:

```powershell
$auditPython = 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $auditPython 'B47ANCEDHelicopterEvents\scripts\check_versions.py' --root 'B47ANCEDHelicopterEvents'
& $auditPython 'B47ANCEDHelicopterEvents\scripts\validate_audit.py' --game 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'
# Above were baseline runs using the original checker/audit validator.
# After follow-up evidence extraction and document edits:
& $auditPython 'B47ANCEDHelicopterEvents\scripts\inventory_followup.py' --game 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'
& $auditPython 'B47ANCEDHelicopterEvents\scripts\validate_audit.py' --game 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'
& $auditPython 'B47ANCEDHelicopterEvents\scripts\check_versions.py' --root 'B47ANCEDHelicopterEvents'
```

[TESTED: offline] Current validator PASS: unchanged original 61 evidence files/25 class snapshots/86 signature references; follow-up 125 evidence files/55 class snapshots/149 exact signature references; all 433 inventoried installed loose zombie class hashes and membership unchanged at final validation; copied launchers/Lua/installer metadata and JAR hash unchanged; current local Markdown targets/line bounds exist; no src/dist/.git tree.

Version consistency PASS for declared current mirrors. Missing packages remain correctly deferred; --release was not run because packaging is unauthorized and G8 blocked. This check proves version consistency only. No Python packages/tools were installed; CFR was run only as a decompiler through the existing JRE, not as a PZ entry point.

Evidence extraction used the initial API_EVIDENCE.md ZipFile/CFR procedure with the output root changed to docs/evidence-followup. Each member is enumerated in evidence-followup/class-manifest.json; reads are from the installed JAR, writes are research copies in this workspace. Missing guessed packet/helper namespaces were resolved from actual imports/JAR member inventory rather than inventing signatures. Patched implementations were not used as design source.

## Scoped change and limitations

Updated the five requested audit documents; added the four requested designs. Supporting changes: version/changelog/inventory/README, historical accepted reports, source/hash/signature inventories and documentation validation scripts. FOLLOWUP_DIFF.patch is the explicit before/after diff for the nine requested documents; new documents have an empty before-state. No other suite project or installed file was edited. The hash checks cover inspected inputs/loose zombie files, not every possible external/native/Workshop resource.

Source reconstruction warnings and missing CFR dependency types remain limitations. Signatures/branch inspection is not bytecode corroboration, clean-depot authentication or runtime behavior. The collector is a research/documentation tool, not gameplay implementation. Independent original installation acquisition, actual class-origin diagnostics and all runtime scenarios remain unexecuted.

G6 NOT TESTED. G7 BLOCKED / NOT TESTED. G8 BLOCKED. Tasks A-D are ready for findings review; Phase 1 remains unstarted. NO-GO findings are not waived by acceptance of source reconnaissance.
