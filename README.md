# B47ANCE'd Helicopter Events

Project Version: 0.1.0-dev.3

Public source: [B47ANCE/B47ANCEDHelicopterEvents](https://github.com/B47ANCE/B47ANCEDHelicopterEvents). This is a **Lua-only, default-disabled audio prototype**, targeting Build 42.21 dedicated servers. It schedules one transient positional rotor bed, with server-owned configuration and expiring snapshots. No wrecks, destruction, loot, salvage, distress, world mutations or zombie attraction. Actual dedicated multiplayer remains **NOT TESTED**.

Authoritative source: `src/B47ANCEDHelicopterEvents/42`; Mod ID: `B47ANCEDHelicopterEvents`. Existing approved icon/poster bytes are reused. There are no custom Java/JAR dependencies, new sound assets, crash persistence, packages or Workshop item. SP/host modes are unsupported and silent. Preserve native helicopter behavior. Raw game source, private snapshots and local settings remain excluded from public Git.

See [implemented behavior, configuration and limitations](docs/AUDIO_PROTOTYPE.md) and [implementation API findings](docs/AUDIO_IMPLEMENTATION_EVIDENCE.md). EnableAudioFlights defaults to false; the server waits a full configured interval after an eligible player is present. Native Lua overloads, looping, stop tails, split-screen listening and packet isolation need actual engine tests. This source is an offline-tested development candidate, not a release or runtime approval.

Offline checks (Python with `lupa==2.6` for Lua 5.1 tests):

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python -B scripts/test_audio.py
git diff --check
```

No game/server launch, packaging, deployment or publication has been performed. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.

- [API audit and verdicts](docs/API_AUDIT.md)
- [Exact source evidence](docs/API_EVIDENCE.md)
- [Engine blockers](docs/ENGINE_BLOCKERS.md)
- [Multiplayer authority and sandbox design](docs/MP_AUTHORITY.md)
- [Runtime test plan](docs/RUNTIME_TEST_PLAN.md)
- [Lua-only audio feasibility](docs/AUDIO_FEASIBILITY.md)
- [Audio API evidence](docs/AUDIO_API_EVIDENCE.md)
- [Merged Phase 1 audio implementation contract](docs/PHASE1_AUDIO_IMPLEMENTATION_CONTRACT.md)
- [Off-screen safety follow-up](docs/OFFSCREEN_SAFETY_DESIGN.md)
- [Structural destruction follow-up](docs/STRUCTURAL_DESTRUCTION_AUDIT.md)
- [Crash persistence follow-up](docs/CRASH_PERSISTENCE_DESIGN.md)
- [Clean versus patched installation](docs/INSTALLATION_PROVENANCE.md)

The bounded audio implementation was authorized on 2026-10-15 at the requested existing 0.1.0-dev.3 artwork checkpoint. It adds configuration/behavior to a project with no previous runtime API or saves; no migration or stable compatibility claim. Earlier Phase 0 work remains dated research. Full crash-site requirements remain blocked. Original private snapshots stay unchanged and excluded from Git; no historical test becomes current proof.

Canonical version: root VERSION. Current mirrors include this README, mod.info, branding authoring header, newest changelog entry and docs/VALIDATION_STATUS.json, declared in version-inventory.json. PZ build and protocol version are independent. Earlier validation retains its original environment and status.
