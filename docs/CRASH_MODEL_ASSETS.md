# Helicopter wreck authoring references

Current implementation annotation, 2026-10-17: [one bounded upright decorative probe](DECORATIVE_WRECK_PROBE.md) now has native definitions and locally prepared GLB/base-color assets. These are a source/offline candidate; earlier statements about absent game definitions refer to their dated audit/intake. No native rendering/collision or dedicated result is approved. Original inputs and earlier exports remain unchanged; new binary derivatives remain ignored.

2026-10-17 API follow-up: [native static-wreck loading/placement audit](STATIC_WRECK_API_AUDIT.md) identifies a packaged GLB/static-IsoObject route and preserved model-name serialization. Actual native asset appearance, collision/footprint, streaming, clean/dedicated runtime and recovery remain unverified. No asset bytes or game definitions changed; earlier intake/optimization evidence retains its original scope.

## Current single-model direction — 2026-10-17

The user's optimization request supersedes component separation for the current crash-site approach: **one static mesh per entire site**, retaining its existing ground/debris. [Completed offline optimization](STATIC_CRASH_MODEL_OPTIMIZATION.md) provides GLB/FBX working exports and editable .blend copies at the current authoring checkpoint. Source copies and the intake manifest below retain their original bytes/checkpoint. This changes the asset representation, not world-placement authorization. The earlier component-specific research remains historical/future scope rather than a requirement for these two static assets.

## Original intake record

Intake: 2026-10-17, authoring checkpoint 0.1.0-dev.4. User supplied four Meshy exports for future helicopter crash sites. **GO for local authoring references; CONDITIONAL for optimization/adaptation; NO-GO for runtime distribution or crash-site placement approval.** Runtime source and the existing selected thumbnail are unchanged. Military Air Support remains the first gameplay-release priority; these assets do not waive the existing crash blockers.

## Files and observed content

The [intake manifest](../assets/crash-sites/MANIFEST.json) records original filenames, SHA-256, byte counts, archive members, textures and GLB structure. Exact source copies are retained under ignored `assets/crash-sites/local-source/`. Downloads originals remain untouched. These four binary exports and local inspection previews are **not backed up to public GitHub**; the public review contains metadata/design only. There is no LFS migration, runtime asset, .blend file, release package or new dependency.

| GLB source | Vertices | Triangles | Embedded images | Source bounds, X/Y/Z extent | Likely FBX archive |
|---|---:|---:|---|---|---|
| Meshy_AI_Heli_1018042915_texture.glb | 561,767 | 942,658 | Three 2048x2048 JPEGs | 1.856 / 0.670 / 1.488 units | Meshy_AI_Heli_1018042910_texture_fbx.zip |
| Meshy_AI_Heli_1018043921_texture.glb | 456,936 | 785,434 | Three 2048x2048 JPEGs | 1.919 / 0.663 / 1.782 units | Meshy_AI_Heli_1018043917_texture_fbx.zip |

[VERIFIED: offline file inspection] Each GLB has one mesh, one triangle primitive, one material and one identity-transform node, with POSITION/NORMAL/TEXCOORD_0. All inspected positions, normals and UVs are finite, index references are in range, and indices divide into triangles. Both have no skins or animations. These checks do not prove manifold topology, correct shading, collision, named component ownership or physical aircraft dimensions. One primitive can contain disconnected islands; it is not a prepared component manifest.

Each ZIP contains one binary FBX plus base-color, metallic, normal and roughness PNG maps. Archive paths/case uniqueness, bounded expanded size and CRC checks PASS. Image decode checks PASS. The GLBs contain embedded textures, so their inspection requires no external texture paths. Base-color comparisons at 128px have RMSE 0.465 and 0.440 out of 255 for the proposed pairs, versus about 53.7 for crossed pairs. **[INFERRED] texture correspondence only**; timestamps and texture similarity do not establish FBX geometry/import equivalence.

## Visual inspection and provenance

A local comparison at `assets/crash-sites/local-previews/model-comparison.png` projects the dense textured GLB vertices from two viewpoints. It is a point-based inspection image, not a surface/PBR render, Blender screenshot or PZ screenshot. [INFERRED: visual] Both appear burned/damaged, with integrated ground/debris: the first is more upright and the second more collapsed. No exact aircraft model, military unit, historical configuration or 1993 authenticity is verified. Do not assign aircraft-specific scenario IDs from appearance alone.

At intake Blender MCP could not connect; no Blender import, topology repair, .blend authoring project, FBX conversion, decimation, rig, animation or game export was performed in that inspection. The subsequent isolated local Blender optimization is recorded separately above. No Meshy generation/conversion/paid job was requested or run. These static wreck candidates need no rig.

Provenance is limited to the user's supplied Meshy exports. Original source images/prompts, account/license terms and redistribution rights were not included or verified. Retaining and inspecting them locally does not establish public/Workshop distribution rights. Preserve originals and obtain the missing provenance before distributing binaries or derivatives. No external mod source or assets were inspected/copied in this intake.

## Revised authoring contract

Working copies have now been imported and optimized with isolated Blender; exact originals remain protected by hashes. GLB and FBX source geometry equivalence was not assumed: the verified GLBs are the optimization inputs, and new FBX files are geometry/UV-checked round trips of those working exports. Editable .blend projects are local outputs.

Keep each entire site as one static mesh/material; do not split fuselage, tail, rotors, ground or debris in this approach. The selected approximately 25k-triangle budget was visually and structurally assessed offline, not validated as a universal PZ performance budget. The 0.79-0.94 million-triangle originals remain authoring references. Original encoded textures and UV presence are retained; native shader/material support and packed PBR interpretation remain unverified. No rig or animated rotor is created.

The new files have stable site names and ground-level centered pivots; source scale and heading are retained, with axis conversion documented. Physical scale against game tiles/objects, placement footprint and native collision remain unresolved. Mesh shape does not supply world collision or neighboring-square ownership automatically. No collider, attachment, loot container, salvage behavior or persistence identity is inferred from an FBX/GLB.

[VERIFIED: installed source observation only] Build 42.21 `media/scripts/generated/models_isoobject.txt:3-8` defines a static-object model using `mesh`, `texture` and `undoCoreScale`. This is a loader-research lead, not proof these supplied exports load or a request to add definitions. Exact model format, Lua exposure/object creation, texture/shader binding, transforms, multi-tile rendering, collision, save/stream/replication and Linux case behavior must be verified before a later runtime asset slice. No direct GLB-loading API is assumed.

## Existing gates and actual validation

[Off-screen safety](OFFSCREEN_SAFETY_DESIGN.md), [structural destruction](STRUCTURAL_DESTRUCTION_AUDIT.md) and [crash persistence](CRASH_PERSISTENCE_DESIGN.md) retain NO-GO findings. No model import or optimization resolves a client visibility/stream fence, safe destruction or non-atomic crash persistence. Individual component semantics remain future design work. No world spawning, collision change or destructive crash is implemented.

[TESTED: offline] Byte-for-byte source retention/hashes; GLB headers/chunk/buffer/accessor/index checks; finite attribute/count checks; embedded image decode/dimensions; ZIP path/case/CRC checks; PNG map decode; diagnostic previews and texture comparisons. Exact commands and limitations are in [validation](VALIDATION.md). Blender/native/PZ SP/dedicated tests NOT TESTED. Project G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. No game/server launch, game-install modification, deployment or Workshop publication.
