# Repository governance

Canonical version: root VERSION. Current public mirrors: README, newest docs/CHANGELOG entry and docs/VALIDATION_STATUS.json, selected by version-inventory.json.

This is a documentation-only Phase 0 project. No authoritative runtime source root, mod.info, assets, game dependencies, packages or Workshop item exist. B47ANCEDHelicopterEvents remains the proposed Mod ID. Future src/B47ANCEDHelicopterEvents/42 plus sibling common is a proposal, not a discovered active source tree. Never package this research repository as a mod.

Public repository: https://github.com/B47ANCE/B47ANCEDHelicopterEvents. Main holds the initial research baseline; subsequent changes use feature branches and PRs. No stable tags or runtime approvals are implied by Git history. No license/redistribution permission is invented for the game or its source.

Current runtime policy is Lua-only: no custom Java, JAR dependencies, agents, injected classes, bridges or native extensions. Vanilla engine classes already exposed to Lua may be called. Earlier Java-permitted text is historical and grants no authority. Native Java inspection is research, not a mod dependency.

Local docs/evidence, docs/evidence-followup and docs/history retain original game source/bytecode snapshots, diagnostic files and reports. They are ignored and must not be published. The original collectors and validate_audit.py are also retained locally and ignored: they have machine-specific assumptions and may overwrite reports. Do not refresh old snapshots or relabel historical results to satisfy a current checker. Public API/line references into these local bundles are reference-only; missing bundles in a fresh clone must be reported as unavailable evidence, not a validation PASS of those sources.

No current claim of clean-baseline provenance or dedicated multiplayer correctness. Separate clean and patched environments remain mandatory. Preserve user files and the installed game.

Offline public checks, from repository root:

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
```

The second validator is added with the audio documentation update; the initial baseline uses the version check and a staged-file security review. Packages are deferred. scripts/check_versions.py --release is only applicable after separately authorized artifacts and release gates. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.
