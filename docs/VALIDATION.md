# Phase 0 validation records

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
