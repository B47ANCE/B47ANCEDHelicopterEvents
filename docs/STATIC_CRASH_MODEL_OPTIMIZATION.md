# Single static crash-site model optimization

Authoring checkpoint: 0.1.0-dev.5, 2026-10-17. **GO for locally optimized authoring/interchange assets; native PZ compatibility NOT TESTED.** User direction is now one static model for each whole crash site. Body, rotors, tail and existing ground/debris remain one mesh with one material; no separately persistent parts or animation were created. This is an additive authoring checkpoint within the pending initial 0.1.0 line; no runtime/API/config/save change or migration.

## Delivered local working assets

Files live under `assets/crash-sites/local-optimized/v0.1.0-dev.5/`, separately from protected `local-source/` originals. Each `upright/` and `collapsed/` folder contains `crash_site_<site>.glb`, `.fbx`, editable `.blend`, the original encoded texture maps in `textures/`, export/readback receipts and inspection renders. The GLBs are self-contained. These binary originals/derivatives/previews remain ignored and **not backed up to public GitHub**; recipes, hashes and reviewed documentation are pushed. No release archive, source installation, deployment or Workshop upload was made.

| Site | Original triangles | Final triangles | Reduction | Original GLB bytes | Final GLB bytes | File reduction |
|---|---:|---:|---:|---:|---:|---:|
| Upright | 942,658 | 24,969 | 97.351% | 40,356,636 | 12,173,832 | 69.834% |
| Collapsed | 785,434 | 24,986 | 96.819% | 35,188,660 | 12,130,536 | 65.527% |

Each has one static mesh/node/triangle primitive and one material in GLB; one mesh/material/UV layer is independently read back from GLB, FBX and .blend. GLB vertex counts differ from Blender's editable vertices because UV/normal seams split renderer vertices. Export cleanup results in slightly fewer triangles than the selected 25k collapse target. Triangles, not raw vertex equivalence, are compared across formats.

## Geometry, textures and transforms

Inputs were the two verified GLBs, not an assumed equivalent FBX import. Blender collapse candidates at 25k and 50k triangles were compared with the sources. The selected 25k variants preserve the main silhouette, rotors, tail and site patch in the reviewed views. No paid remesh, new geometry generation, rig, skin or animation service was used.

All three 2048x2048 source JPEGs are embedded **byte-for-byte unchanged** in each final GLB and packed in its .blend. Base color, normal and metallic/roughness material bindings are present in those two formats. No retexturing, resampling, repainting or texture compression was applied. Keeping those source maps explains why file reduction is less than triangle reduction.

FBX geometry, UVs, material count, bounds and pivot read back correctly. Blender's FBX round trip binds two images (base color and normal); the packed metallic/roughness map does not round-trip as a bound PBR input. All original maps are supplied separately in `textures/`. **Use GLB/.blend for the complete source material setup.** FBX is geometry/UV interchange plus maps, not a claim of equivalent PBR shading or native PZ readiness.

The horizontal bounding center is the origin; the minimum vertex height is at Z=0 in Blender. GLB uses Y-up. Rotation/scale are applied to working copies and the source's size/heading is retained apart from decimation's small bounds drift and explicit origin translations. No arbitrary aircraft dimension or tile scale was invented. Source units remain uncalibrated against PZ. No collider, attachment, world footprint, item/script definition, loot, salvage or persistence identity was added.

## Actual tooling and QA

The live Blender MCP connection remained unavailable. Work ran in a separate local Python/bpy process using **Blender 4.5.3 LTS**, with an isolated CPython 3.11.9 embedded runtime. No open user Blender scene or saved preferences were touched. Python's executable signature was Valid/Python Software Foundation. The bpy wheel hash matched the official PyPI metadata. [Optimization receipt](../assets/crash-sites/OPTIMIZATION_REPORT.json) records toolchain fingerprints, output hashes, counts, readback and render measurements. Tool versions are authoring dependencies, never mod runtime dependencies. Official references: [bpy 4.5.3](https://pypi.org/project/bpy/4.5.3/), [Blender Decimate documentation](https://docs.blender.org/manual/en/4.5/modeling/modifiers/generate/decimate.html).

[TESTED: offline Blender] Each final GLB/FBX/.blend was opened in an independent Blender process. All returned one nonanimated mesh, the recorded final triangle count, one material and one UV layer; bounds agree within 0.00001 source units and minimum height within that tolerance of zero. GLB/.blend retained three 2048px material images. Native format/import invocation was Blender only, never PZ.

[TESTED: offline image/geometry comparison] Actual re-imported final GLBs were rendered at 512px from two opposite views using source-fixed camera/framing/lighting, Cycles CPU, 16 samples. Source renders used the same setup. Silhouette IoU ranges 0.98486-0.99384; foreground RGB NRMSE ranges 0.06036-0.07165. The offline art criteria (IoU >= 0.98, NRMSE <= 0.10) pass all four views. These measure only the sampled authoring views and include sampling/shading differences; they are not a full-angle geometric error proof or an engine performance test. The before/after comparison is local `assets/crash-sites/local-previews/optimized-static-comparison.png` and was visually reviewed.

[TESTED: offline structural validation] GLB header/chunk/buffer/accessor bounds, finite positions/normals/UVs, valid triangle indices, single-mesh/material/no-skin/no-animation shape, all three embedded texture hashes and output file hashes PASS. All eight input fingerprints (four retained copies and four Downloads originals) still match the original intake. No source or intake-manifest bytes changed.

Recipes and exact commands are in [validation](VALIDATION.md): `scripts/optimize_crash_models.py`, `finalize_crash_models.py`, `check_crash_model_readback.py`, and standalone `validate_crash_models.py`. They are offline development tools outside the runtime source tree. Missing local originals or outputs must fail/be reported unavailable, never manufacture a native PASS.

## Remaining gates

Changing to one static asset supersedes component separation for this approach. Earlier per-component ownership/salvage/tombstone research is historical or optional future scope; it is not implemented here. This does not establish a supported model loader/world-object representation, calibrated scale, collision, culling/streaming, observer-safe admission or object persistence contract. Existing [off-screen](OFFSCREEN_SAFETY_DESIGN.md), [destruction](STRUCTURAL_DESTRUCTION_AUDIT.md) and [persistence](CRASH_PERSISTENCE_DESIGN.md) findings are not cleared by mesh optimization. No destructive crash or world spawning is implemented.

Original generation/license/redistribution provenance remains limited to the user-supplied exports; binary distribution rights were not established. PZ SP/dedicated/rendering/performance/collision/save tests remain NOT TESTED. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. No game/server launch, game-install modification, deployment or publication.
