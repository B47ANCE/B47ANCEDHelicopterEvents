# Repository governance

The [decorative diagnostic](DECORATIVE_WRECK_PROBE.md) is an independently default-disabled server world-mutation probe. Authoritative definitions/Lua and offline tests/asset recipe are source; local GLB/PNG derivatives under the two explicitly ignored `media/models_X/B47HE/` and `media/textures/B47HE/` source directories are not public GitHub backups. They are source-preparation outputs, not installed/deployed files. [Receipt](../assets/crash-sites/WRECK_PROBE_ASSETS.json) binds them to the optimized source checkpoint. Redistribution provenance remains unresolved. Missing local assets deny manual placement. No package, native import or runtime evidence inferred.

Canonical version: root VERSION. Current public mirrors: README, mod.info, docs/BRANDING.md authoring header, newest docs/CHANGELOG entry and docs/VALIDATION_STATUS.json, selected by version-inventory.json.

The current source also includes the independently default-disabled [read-only radio preflight probe](SUPPORT_PREFLIGHT_PROBE.md), with its own Lua namespace and fake-boundary tests. No support gameplay or persistent state is introduced.

Deferred wreck authoring references are inventoried in [assets/crash-sites/MANIFEST.json](../assets/crash-sites/MANIFEST.json); binary sources/local previews are explicitly ignored and not GitHub backups. See [asset assessment](CRASH_MODEL_ASSETS.md). The reviewed [project overview](MOD_OVERVIEW.json) distinguishes current probe foundations, planned gameplay and blocked crash work; its digest covers runtime source/README/VERSION, not private authoring binaries.

Current wreck authoring is [one static mesh per site](STATIC_CRASH_MODEL_OPTIMIZATION.md). Local optimized GLB/FBX/.blend outputs are under `assets/crash-sites/local-optimized/v0.1.0-dev.5/` and remain ignored. The public [optimization receipt](../assets/crash-sites/OPTIMIZATION_REPORT.json) records hashes/measurements, not a backup or PZ compatibility approval. Four new Python tools in scripts/ are Blender/standard-library authoring checks only, never runtime mod dependencies.

Authoritative Lua runtime source: src/B47ANCEDHelicopterEvents/42; confirmed Mod ID B47ANCEDHelicopterEvents under the authorized bounded contract. Existing approved assets/branding icon/poster bytes are mirrored into the source tree without regeneration. The selected custom project thumbnail is root [thumbnail.png](../thumbnail.png); assets/branding retains fallback art, with provenance in [BRANDING.md](BRANDING.md). No Workshop item, release package or generated staging exists. No package script was created or executed. Python/Lupa and tests/requirements.txt are offline tools, never game dependencies. Prior Phase 0 source snapshots/design remain historical evidence; see [current scope](AUDIO_PROTOTYPE.md).

Public repository: https://github.com/B47ANCE/B47ANCEDHelicopterEvents. Main holds the initial research baseline; subsequent changes use feature branches and PRs. No stable tags or runtime approvals are implied by Git history. No license/redistribution permission is invented for the game or its source.

Current runtime policy is Lua-only: no custom Java, JAR dependencies, agents, injected classes, bridges or native extensions. Vanilla engine classes already exposed to Lua may be called. Earlier Java-permitted text is historical and grants no authority. Native Java inspection is research, not a mod dependency.

Local docs/evidence, docs/evidence-followup and docs/history retain original game source/bytecode snapshots, diagnostic files and reports. They are ignored and must not be published. The original collectors and validate_audit.py are also retained locally and ignored: they have machine-specific assumptions and may overwrite reports. Do not refresh old snapshots or relabel historical results to satisfy a current checker. Public API/line references into these local bundles are reference-only; missing bundles in a fresh clone must be reported as unavailable evidence, not a validation PASS of those sources.

No current claim of clean-baseline provenance or dedicated multiplayer correctness. Separate clean and patched environments remain mandatory. Preserve user files and the installed game.

Offline public checks, from repository root:

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python -B scripts/test_audio.py
python -B scripts/test_support_probe.py
python -B scripts/test_wreck_probe.py
python -B scripts/test_wreck_asset_preparation.py
python -B scripts/validate_wreck_probe.py
```

The audio documentation update supplies the second validator; the initial baseline used the version check and a staged-file security review. Packages are deferred. scripts/check_versions.py --release is only applicable after separately authorized artifacts and release gates. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.
