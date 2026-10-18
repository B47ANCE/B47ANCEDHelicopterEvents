# B47ANCE'd Helicopter Events

Project Version: 0.1.0-dev.5

Selected project artwork: [thumbnail.png](thumbnail.png), the supplied helicopter image preserved exactly. The [context-menu contract](docs/CONTEXT_MENU_CONTRACT.md) records the required state-dependent military actions; these menus and support equipment are not implemented.

Two [optimized static wreck-site models](docs/STATIC_CRASH_MODEL_OPTIMIZATION.md) are available locally as editable Blender sources and GLB/FBX interchange exports, at about 25k triangles each. Each site is one mesh including its existing debris/ground. Originals remain untouched. These are offline authoring assets: no game model definition, collision, placement or runtime compatibility is implemented/verified.

First complete gameplay release direction: **Military Air Support**. Current runtime source contains the experimental rotor prototype and a [read-only radio preflight probe](docs/SUPPORT_PREFLIGHT_PROBE.md), independently disabled by default. The probe reports server-resolved device state only; support equipment, authorization, menus, loot and combat are not implemented. The [targeted support API audit](docs/MILITARY_SUPPORT_API_AUDIT.md) records current NO-GO contracts. Crash/wreck/destruction features remain deferred and blocked independently.

Public source: [B47ANCE/B47ANCEDHelicopterEvents](https://github.com/B47ANCE/B47ANCEDHelicopterEvents). These are **Lua-only, default-disabled development probes**, targeting Build 42.21 dedicated servers. The audio subsystem schedules one transient positional rotor bed, with server-owned configuration and expiring snapshots. No wrecks, destruction, loot, salvage, distress, world mutations or zombie attraction. Actual dedicated multiplayer remains **NOT TESTED**.

Authoritative source: `src/B47ANCEDHelicopterEvents/42`; Mod ID: `B47ANCEDHelicopterEvents`. Existing approved icon/poster bytes are reused. There are no custom Java/JAR dependencies, new sound assets, crash persistence, packages or Workshop item. SP/host modes are unsupported and silent. Preserve native helicopter behavior. Raw game source, private snapshots and local settings remain excluded from public Git.

See [implemented behavior, configuration and limitations](docs/AUDIO_PROTOTYPE.md) and [implementation API findings](docs/AUDIO_IMPLEMENTATION_EVIDENCE.md). EnableAudioFlights defaults to false; the server waits a full configured interval after an eligible player is present. Native Lua overloads, looping, stop tails, split-screen listening and packet isolation need actual engine tests. This source is an offline-tested development candidate, not a release or runtime approval.

Offline checks (Python with `lupa==2.6` for Lua 5.1 tests):

```text
python -B scripts/check_versions.py --root .
python -B scripts/validate_phase0_docs.py
python -B scripts/validate_audio_sources.py
python -B scripts/test_audio.py
python -B scripts/test_support_probe.py
git diff --check
```

No game/server launch, packaging, deployment or publication has been performed. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.

- [Military radio design](docs/MILITARY_RADIO_DESIGN.md)
- [Army Credentials loot audit](docs/ARMY_CREDENTIALS_LOOT_AUDIT.md)
- [Single-use authorization design](docs/SUPPORT_AUTHORIZATION_DESIGN.md)
- [Door gunner combat audit](docs/DOOR_GUNNER_COMBAT_AUDIT.md)
- [Lua-only gunner alternatives and ownership blocker](docs/DOOR_GUNNER_LUA_FEASIBILITY.md)
- [Ownership/result path and native hit proxy audit](docs/GUNNER_OWNERSHIP_RESULT_AUDIT.md)
- [Combat ordering, owner migration and ordinary damage contract](docs/COMBAT_ORDERING_CONTRACT.md)
- [A-Life, Remnants and Bandits clean-room comparison](docs/THIRD_PARTY_RESEARCH.md)
- [CSR Knox Syndicate air-support source research](docs/CSR_AIR_SUPPORT_RESEARCH.md)
- [Native lethal-result, replication and ordinary-hit audit](docs/NATIVE_LETHAL_RESULT_AUDIT.md)
- [Support dedicated test plan](docs/SUPPORT_MP_TEST_PLAN.md)
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
