"""Offline Blender authoring only. Run with Blender 4.5 Python/bpy, never PZ.

Preserves source files; generates isolated candidates with one static mesh/site.
Uses the project intake manifest, not downloaded executable/model scripts.
"""
import argparse
import hashlib
import json
import sys
from pathlib import Path

import bpy
from mathutils import Vector
sys.path.insert(0, str(Path(__file__).resolve().parent))
from validate_crash_models import glb as inspect_glb

ROOT = Path(__file__).resolve().parents[1]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def enum(prop, identifier):
    valid = {item.identifier for item in prop.enum_items}
    if identifier not in valid:
        raise ValueError(f'Unsupported Blender enum {identifier}: {sorted(valid)}')
    return identifier


def operator_enum(operator, name, identifier):
    rna = operator.get_rna_type()
    items = list(rna.properties[name].enum_items)
    if items:
        return enum(rna.properties[name], identifier)
    # Blender's dynamic Python enum callbacks can be empty in RNA introspection.
    cls = getattr(bpy.types, rna.identifier)
    for base in cls.__mro__:
        deferred = getattr(base, '__annotations__', {}).get(name)
        if deferred is not None:
            choices = deferred.keywords['items']
            if callable(choices):
                choices = choices(None, bpy.context)
            if identifier in {choice[0] for choice in choices if choice}:
                return identifier
    raise ValueError(f'Unsupported dynamic operator enum {name}={identifier}')


def mesh_stats(obj):
    obj.data.calc_loop_triangles()
    points = [obj.matrix_world @ Vector(p) for p in obj.bound_box]
    return {'vertices': len(obj.data.vertices), 'triangles': len(obj.data.loop_triangles),
            'uvLayers': len(obj.data.uv_layers), 'materials': len(obj.data.materials),
            'boundsMin': [min(p[i] for p in points) for i in range(3)],
            'boundsMax': [max(p[i] for p in points) for i in range(3)]}


def only_select(obj):
    bpy.ops.object.select_all(action=enum(bpy.ops.object.select_all.get_rna_type().properties['action'], 'DESELECT'))
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def render_setup(obj, reference_size=None):
    scene = bpy.context.scene
    # This is an isolated Python process, never the user's open Blender scene.
    try:
        scene.render.engine = 'CYCLES'
    except TypeError as exc:
        raise RuntimeError('This authoring build has no Cycles renderer') from exc
    scene.render.threads_mode = enum(scene.render.bl_rna.properties['threads_mode'], 'FIXED')
    scene.render.threads = 4
    scene.cycles.device = enum(scene.cycles.bl_rna.properties['device'], 'CPU')
    scene.cycles.samples = 16
    scene.cycles.use_denoising = True
    scene.cycles.seed = 0
    scene.render.resolution_x = scene.render.resolution_y = 512
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = enum(scene.render.image_settings.bl_rna.properties['file_format'], 'PNG')
    scene.render.image_settings.color_mode = enum(scene.render.image_settings.bl_rna.properties['color_mode'], 'RGBA')
    scene.world = bpy.data.worlds.new('neutral_world')
    scene.world.use_nodes = True
    background = next(n for n in scene.world.node_tree.nodes if n.type == 'BACKGROUND')
    background.inputs['Color'].default_value = (0.25, 0.25, 0.25, 1)
    background.inputs['Strength'].default_value = 0.5
    size = reference_size if reference_size is not None else max(obj.dimensions)
    for name, loc, power in [('key', (2, -2, 3), 500), ('fill', (-2, -1, 2), 300), ('rim', (0, 2, 3), 500)]:
        light = bpy.data.lights.new(name, enum(bpy.types.Light.bl_rna.properties['type'], 'AREA'))
        light.energy = power * size * size
        light.shape = enum(light.bl_rna.properties['shape'], 'DISK')
        light.size = size * 2
        holder = bpy.data.objects.new(name, light)
        scene.collection.objects.link(holder)
        holder.location = Vector(loc) * size
        holder.rotation_euler = (-holder.location).to_track_quat('-Z', 'Y').to_euler()
    camera = bpy.data.cameras.new('inspection_camera')
    camera.type = enum(camera.bl_rna.properties['type'], 'ORTHO')
    camera.ortho_scale = size * 1.3
    holder = bpy.data.objects.new('inspection_camera', camera)
    scene.collection.objects.link(holder)
    scene.camera = holder
    return size


def render(obj, folder, label, size, reference_height=None):
    obj.hide_render = False
    scene = bpy.context.scene
    height = reference_height if reference_height is not None else obj.dimensions.z
    target = Vector((0, 0, height * 0.4))
    for view, direction in enumerate([(2, -2, 1.5), (-2, 2, 1.5)]):
        scene.camera.location = target + Vector(direction) * size
        scene.camera.rotation_euler = (target - scene.camera.location).to_track_quat('-Z', 'Y').to_euler()
        scene.render.filepath = str(folder / f'{label}_view{view}.png')
        bpy.ops.render.render(write_still=True)
    obj.hide_render = True


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--targets', type=int, nargs='+', default=[25000, 50000])
    parser.add_argument('--site', choices=['upright', 'collapsed'], required=True)
    args = parser.parse_args()
    if any(not 5000 <= t <= 100000 for t in args.targets):
        raise ValueError('Candidate budget outside authoring safety bounds')
    out = args.output.resolve()
    if not (out.is_relative_to(ROOT / '.tmp-model-optimization') or out.is_relative_to(ROOT / 'assets/crash-sites/local-optimized')):
        raise ValueError('Output must remain in the isolated authoring workspace')
    if out.exists() and any(out.iterdir()):
        raise FileExistsError('Refuse to overwrite an existing authoring candidate')
    out.mkdir(parents=True, exist_ok=True)
    manifest = json.loads((ROOT / 'assets/crash-sites/MANIFEST.json').read_text(encoding='utf-8'))
    protected = [(ROOT / entry['localPath'], entry['sha256']) for entry in manifest['files']]
    for path, expected in protected:
        if sha(path) != expected:
            raise ValueError('Source fingerprint mismatch')
    source_name = {'upright': 'Meshy_AI_Heli_1018042915_texture.glb',
                   'collapsed': 'Meshy_AI_Heli_1018043921_texture.glb'}[args.site]
    source = next(path for path, _ in protected if path.name == source_name)
    print('Blender version:', bpy.app.version_string, flush=True)
    print('Isolated initial objects:', [obj.name for obj in bpy.data.objects], flush=True)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(source), merge_vertices=True, import_pack_images=True)
    meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    if len(meshes) != 1 or any(o.type == 'ARMATURE' for o in bpy.data.objects):
        raise ValueError('Expected one static source mesh, no armature')
    original = meshes[0]
    original.name = f'crash_site_{args.site}'
    only_select(original)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    # Center X/Y and move source minimum Z onto the ground, without inventing scale.
    points = [Vector(p) for p in original.bound_box]
    pivot = Vector(((min(p.x for p in points)+max(p.x for p in points))/2,
                    (min(p.y for p in points)+max(p.y for p in points))/2,
                    min(p.z for p in points)))
    for vertex in original.data.vertices:
        vertex.co -= pivot
    original.location = (0, 0, 0)
    original.data.update()
    bpy.context.view_layer.update()
    original_stats = mesh_stats(original)
    size = render_setup(original)
    height = original_stats['boundsMax'][2] - original_stats['boundsMin'][2]
    render(original, out, 'source', size, height)
    summary = {'schema': 1, 'authoringVersion': (ROOT/'VERSION').read_text().strip(),
               'blenderVersion': bpy.app.version_string, 'site': args.site,
               'sourceFile': source.name, 'sourceSha256': sha(source),
               'sourceStatsBlenderAxes': original_stats, 'sourcePivotShiftBlenderAxes': list(pivot),
               'physicalScale': 'Uncalibrated; preserve source size. Blender Z up, GLB Y up.',
               'render': 'Isolated Cycles CPU, 16 samples, 512px, two fixed views; not PZ.',
               'candidates': []}
    for target in args.targets:
        obj = original.copy()
        obj.data = original.data.copy()
        bpy.context.scene.collection.objects.link(obj)
        obj.name = f'crash_site_{args.site}_{target}'
        obj.hide_render = False
        only_select(obj)
        mod = obj.modifiers.new(name='offline_reduction',
            type=enum(obj.modifiers.bl_rna.functions['new'].parameters['type'], 'DECIMATE'))
        mod.decimate_type = enum(mod.bl_rna.properties['decimate_type'], 'COLLAPSE')
        mod.ratio = min(1.0, target / original_stats['triangles'])
        mod.use_collapse_triangulate = True
        bpy.ops.object.modifier_apply(modifier=mod.name)
        stats = mesh_stats(obj)
        if stats['triangles'] <= 0 or stats['triangles'] > target * 1.01 or stats['uvLayers'] != 1:
            raise ValueError('Unexpected reduction/UV result')
        render(obj, out, str(target), size, height)
        obj.hide_render = False
        only_select(obj)
        glb = out / f'{obj.name}.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb),
            export_format=operator_enum(bpy.ops.export_scene.gltf, 'export_format', 'GLB'),
            use_selection=True, export_animations=False, export_skins=False,
            export_morph=False, export_cameras=False, export_lights=False,
            export_extras=False, export_apply=True, export_keep_originals=False,
            will_save_settings=False)
        exported = inspect_glb(glb)
        source_entry = next(item for item in manifest['files'] if item['name'] == source.name)
        if {i['sha256'] for i in exported['images']} != {i['sha256'] for i in source_entry['images']}:
            raise ValueError('Export changed or dropped an original encoded texture')
        # Edit-ready optimized mesh only; do not embed the high-poly source object.
        original_data = original.data
        bpy.data.objects.remove(original, do_unlink=True)
        bpy.data.meshes.remove(original_data)
        bpy.ops.file.pack_all()
        blend = out / f'{obj.name}.blend'
        bpy.ops.wm.save_as_mainfile(filepath=str(blend), compress=True, check_existing=False)
        entry = {'targetTriangles': target, 'statsBlenderAxes': stats,
                 'glb': {'name': glb.name, 'bytes': glb.stat().st_size, 'sha256': sha(glb)},
                 'blend': {'name': blend.name, 'bytes': blend.stat().st_size, 'sha256': sha(blend)}}
        summary['candidates'].append(entry)
        # Restore source from its unmodified disk bytes for the next independent candidate.
        bpy.data.objects.remove(obj, do_unlink=True)
        bpy.ops.import_scene.gltf(filepath=str(source), merge_vertices=True, import_pack_images=True)
        original = next(o for o in bpy.context.scene.objects if o.type == 'MESH')
        only_select(original)
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        for vertex in original.data.vertices:
            vertex.co -= pivot
        original.location = (0,0,0)
        original.data.update()
        bpy.context.view_layer.update()
        original.hide_render = True
        print('CANDIDATE:', target, stats, 'GLB bytes', glb.stat().st_size, flush=True)
    for path, expected in protected:
        if sha(path) != expected:
            raise ValueError('Original changed during processing')
    (out/'report.json').write_text(json.dumps(summary, indent=2)+'\n', encoding='utf-8')
    print('COMPLETE', out, flush=True)


if __name__ == '__main__':
    main()
