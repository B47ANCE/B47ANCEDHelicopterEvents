# B47ANCE'd Helicopter Events

Project Version: 0.1.0-dev.2

Public source: [B47ANCE/B47ANCEDHelicopterEvents](https://github.com/B47ANCE/B47ANCEDHelicopterEvents). This remains Phase 0 research with no runtime implementation. Current policy is **Lua-only**; earlier bridge/Java proposals in dated research are historical, not authorization. Raw game source, bytecode, linked local configuration and diagnostic snapshots stay local and are not published. See [repository governance](docs/REPOSITORY.md).

Phase 0 research workspace, originally created without Git. Target: Project Zomboid Build 42.21. Proposed Mod ID: `B47ANCEDHelicopterEvents`. Public Git onboarding was authorized on 2026-10-14; it is not game/runtime approval.

The handoff's proposed initial version is adopted for this new documentation-only workspace. This is an initial prerelease, not a PATCH/MINOR/MAJOR upgrade from an existing release. No gameplay, assets, mod.info, deployment, packages, or runtime execution are included. Phase 1 requires review of these findings and resolution of its blockers.

- [API audit and verdicts](docs/API_AUDIT.md)
- [Exact source evidence](docs/API_EVIDENCE.md)
- [Engine blockers](docs/ENGINE_BLOCKERS.md)
- [Multiplayer authority and sandbox design](docs/MP_AUTHORITY.md)
- [Runtime test plan](docs/RUNTIME_TEST_PLAN.md)
- [Lua-only audio feasibility](docs/AUDIO_FEASIBILITY.md)
- [Audio API evidence](docs/AUDIO_API_EVIDENCE.md)
- [Phase 1 audio implementation contract - design only](docs/PHASE1_AUDIO_IMPLEMENTATION_CONTRACT.md)
- [Off-screen safety follow-up](docs/OFFSCREEN_SAFETY_DESIGN.md)
- [Structural destruction follow-up](docs/STRUCTURAL_DESTRUCTION_AUDIT.md)
- [Crash persistence follow-up](docs/CRASH_PERSISTENCE_DESIGN.md)
- [Clean versus patched installation](docs/INSTALLATION_PROVENANCE.md)

The second development checkpoint expands source reconnaissance and design only; no public API, gameplay, configuration or save compatibility changes. The 2026-10-14 documentation correction adds a CONDITIONAL Lua-only audio candidate and dedicated MP tests without beginning Phase 1 or changing the version. Full crash-site requirements remain blocked. The accepted first audit and its offline validation remain historical in local docs/history/phase0-accepted; source snapshots remain unchanged and excluded from public Git.

Canonical version: root VERSION. Current mirrors: this README, newest changelog entry and docs/VALIDATION_STATUS.json, declared in version-inventory.json. PZ version, Steam build ID, framework/tool provenance, and future save/protocol schemas are independent. Earlier local validation/provenance snapshots retain the versions actually inspected.
