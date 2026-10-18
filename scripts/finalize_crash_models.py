"""Offline Blender final export of a reviewed single-mesh crash-site candidate."""
import argparse
import json
import sys
from pathlib import Path

import bpy
from mathutils import Vector

sys.path.insert(0, str(Path(__file__).resolve().parent))
from optimize_crash_models import ROOT, mesh_stats, only_select, operator_enum, render, sha


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--site', choices=['upright', 'collapsed'], required=True)
    args = parser.parse_args()
    candidate, out = args.candidate.resolve(), args.output.resolve()
    if not candidate.is_relative_to(ROOT/'.tmp-model-optimization'):
        raise ValueError('Only isolated reviewed candidates may be finalized')
    if not out.is_relative_to(ROOT/'assets/crash-sites/local-optimized'):
        raise ValueError('Final output must stay in local authoring assets')
    if out.exists() and any(out.iterdir()):
        raise FileExistsError('Refuse to overwrite an existing optimized artifact')
    out.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(candidate))
    meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    if len(meshes) != 1:
        raise ValueError('Exactly one mesh per crash site is required')
    obj = meshes[0]
    obj.name = obj.data.name = f'crash_site_{args.site}'
    before = mesh_stats(obj)
    pivot = Vector(((before['boundsMin'][0]+before['boundsMax'][0])/2,
                    (before['boundsMin'][1]+before['boundsMax'][1])/2,
                    before['boundsMin'][2]))
    for vertex in obj.data.vertices:
        vertex.co -= pivot
    obj.data.update()
    bpy.context.view_layer.update()
    obj.hide_render = False
    only_select(obj)
    # Preserve the original encoded texture bytes; no resampling or repainting.
    texture_dir = out/'textures'
    texture_dir.mkdir()
    images = {node.image for mat in obj.data.materials for node in mat.node_tree.nodes
              if node.type == 'TEX_IMAGE' and node.image is not None}
    textures = []
    for index, image in enumerate(sorted(images, key=lambda i: i.name)):
        if not image.packed_file:
            raise ValueError('Candidate image is not packed')
        raw = bytes(image.packed_file.data)
        extension = '.jpg' if raw.startswith(b'\xff\xd8') else '.png' if raw.startswith(b'\x89PNG') else None
        if extension is None:
            raise ValueError('Unexpected packed texture encoding')
        file = texture_dir/f'{obj.name}_{index}{extension}'
        file.write_bytes(raw)
        image.filepath_raw = '//textures/'+file.name
        textures.append({'name': 'textures/'+file.name, 'sha256': sha(file),
                         'bytes': len(raw), 'dimensions': list(image.size),
                         'colorspace': image.colorspace_settings.name})
    bpy.context.preferences.filepaths.save_version = 0  # isolated process only
    bpy.ops.file.pack_all()
    blend = out/f'{obj.name}.blend'
    bpy.ops.wm.save_as_mainfile(filepath=str(blend), compress=True, check_existing=False, relative_remap=False)
    glb = out/f'{obj.name}.glb'
    bpy.ops.export_scene.gltf(filepath=str(glb),
        export_format=operator_enum(bpy.ops.export_scene.gltf, 'export_format', 'GLB'),
        use_selection=True, export_animations=False, export_skins=False, export_morph=False,
        export_cameras=False, export_lights=False, export_apply=True,
        export_keep_originals=False, will_save_settings=False)
    fbx = out/f'{obj.name}.fbx'
    bpy.ops.export_scene.fbx(filepath=str(fbx), use_selection=True,
        object_types={operator_enum(bpy.ops.export_scene.fbx, 'object_types', 'MESH')},
        bake_anim=False, use_mesh_modifiers=True, add_leaf_bones=False,
        path_mode=operator_enum(bpy.ops.export_scene.fbx, 'path_mode', 'COPY'),
        embed_textures=True, use_triangles=True)
    stats = mesh_stats(obj)
    render(obj, out, 'optimized', max(obj.dimensions))
    # The edit-ready source opens with the only mesh visible, regardless of preview state.
    obj.hide_render = False
    bpy.ops.wm.save_as_mainfile(filepath=str(blend), compress=True, check_existing=False, relative_remap=False)
    report = {'schema': 1, 'authoringVersion': (ROOT/'VERSION').read_text().strip(),
              'site': args.site, 'blenderVersion': bpy.app.version_string,
              'staticMeshCount': 1, 'statsBlenderAxes': stats,
              'finalPivotCorrectionBlenderAxes': list(pivot), 'textures': textures,
              'outputs': [{'name': p.name, 'bytes': p.stat().st_size, 'sha256': sha(p)}
                          for p in [glb, fbx, blend]],
              'limits': 'Offline interchange/authoring assets only. FBX material interpretation and PZ runtime NOT TESTED. No collision or world placement.'}
    (out/'export-report.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(report, indent=2), flush=True)


if __name__ == '__main__':
    main()
