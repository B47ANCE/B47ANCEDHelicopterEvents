"""Independent Blender-process readback of finalized working exports. Not PZ."""
import argparse
import json
import math
from pathlib import Path
import sys

import bpy

sys.path.insert(0, str(Path(__file__).resolve().parent))
from optimize_crash_models import ROOT, mesh_stats, render_setup, render


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--folder', type=Path, required=True)
    parser.add_argument('--site', choices=['upright', 'collapsed'], required=True)
    parser.add_argument('--reference-report', type=Path)
    args = parser.parse_args()
    folder = args.folder.resolve()
    if not folder.is_relative_to(ROOT/'assets/crash-sites/local-optimized'):
        raise ValueError('Readback must use isolated optimized outputs')
    exported = json.loads((folder/'export-report.json').read_text(encoding='utf-8'))
    expected_triangles = exported['statsBlenderAxes']['triangles']
    if not 0 < expected_triangles <= 25000:
        raise ValueError('Final export exceeds the selected triangle budget')
    results = {}
    for extension in ['blend', 'glb', 'fbx']:
        path = folder/f'crash_site_{args.site}.{extension}'
        bpy.ops.wm.read_factory_settings(use_empty=True)
        if extension == 'blend':
            bpy.ops.wm.open_mainfile(filepath=str(path), load_ui=False, use_scripts=False)
        elif extension == 'glb':
            bpy.ops.import_scene.gltf(filepath=str(path), merge_vertices=True, import_pack_images=True)
        else:
            bpy.ops.import_scene.fbx(filepath=str(path), use_image_search=False)
        meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
        if len(meshes) != 1 or any(o.type == 'ARMATURE' or o.animation_data for o in bpy.data.objects):
            raise ValueError('Expected one nonanimated mesh, no armature')
        obj = meshes[0]
        stats = mesh_stats(obj)
        if stats['triangles'] != expected_triangles or stats['uvLayers'] != 1 or stats['materials'] != 1:
            raise ValueError('Unexpected mesh/UV/material count on readback')
        if abs(stats['boundsMin'][2]) > 1e-5:
            raise ValueError('Ground pivot did not survive export/readback')
        if not all(math.isfinite(v) for vertex in obj.data.vertices for v in vertex.co):
            raise ValueError('Nonfinite vertex on readback')
        images = {n.image for m in obj.data.materials for n in m.node_tree.nodes
                  if n.type == 'TEX_IMAGE' and n.image is not None}
        if extension != 'fbx' and len(images) != 3:
            raise ValueError('GLB/BLEND must retain all three material images')
        results[extension] = {'meshCount': 1, 'statsBlenderAxes': stats,
                              'boundMaterialImages': len(images),
                              'imageSizes': [list(i.size) for i in sorted(images, key=lambda i: i.name)],
                              'packedImages': sum(bool(i.packed_file) for i in images)}
        if extension == 'glb' and args.reference_report:
            reference_data = json.loads(args.reference_report.read_text(encoding='utf-8'))
            bounds = reference_data['sourceStatsBlenderAxes']
            dimensions = [b-a for a,b in zip(bounds['boundsMin'],bounds['boundsMax'])]
            size = render_setup(obj, reference_size=max(dimensions))
            render(obj, folder, 'readback', size, reference_height=dimensions[2])
    reference = results['blend']['statsBlenderAxes']
    for result in results.values():
        if any(abs(a-b)>1e-5 for field in ['boundsMin', 'boundsMax']
               for a,b in zip(reference[field], result['statsBlenderAxes'][field])):
            raise ValueError('Round-trip geometry bounds drift')
    (folder/'readback-report.json').write_text(json.dumps(results, indent=2)+'\n', encoding='utf-8')
    print('OFFLINE READBACK PASS', args.site, json.dumps(results), flush=True)


if __name__ == '__main__':
    main()
