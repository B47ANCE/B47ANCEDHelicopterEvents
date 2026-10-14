# Phase 0 follow-up validation record

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
