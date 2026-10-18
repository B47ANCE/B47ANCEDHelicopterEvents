"""Read-only offline GLB and original-file integrity checks. No PZ/Blender launch."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]


def glb(path):
    raw = path.read_bytes()
    if struct.unpack_from('<4sII', raw) != (b'glTF', 2, len(raw)):
        raise ValueError('Invalid GLB header')
    chunks, pos = {}, 12
    while pos < len(raw):
        size, kind = struct.unpack_from('<I4s', raw, pos)
        if size % 4 or pos+8+size > len(raw) or kind in chunks:
            raise ValueError('Invalid GLB chunk')
        chunks[kind] = raw[pos+8:pos+8+size]
        pos += 8+size
    data, binary = json.loads(chunks[b'JSON']), chunks[b'BIN\0']
    if len(data['buffers']) != 1 or 'uri' in data['buffers'][0]:
        raise ValueError('External buffers are not permitted')
    if data['buffers'][0]['byteLength'] > len(binary):
        raise ValueError('Buffer length exceeds binary data')
    for view in data['bufferViews']:
        if view.get('buffer', 0) != 0 or view.get('byteOffset', 0)+view['byteLength'] > len(binary):
            raise ValueError('Buffer view outside binary data')
    if len(data['meshes']) != 1 or len(data['nodes']) != 1 or len(data['meshes'][0]['primitives']) != 1:
        raise ValueError('Expected one node, one mesh and one primitive')
    if len(data.get('materials', [])) != 1 or data.get('skins') or data.get('animations'):
        raise ValueError('Expected one material, no skin/animation')
    primitive = data['meshes'][0]['primitives'][0]
    if primitive.get('mode', 4) != 4:
        raise ValueError('Only triangle primitives are permitted')

    def values(index):
        accessor = data['accessors'][index]
        if 'sparse' in accessor:
            raise ValueError('Unexpected sparse accessor')
        view = data['bufferViews'][accessor['bufferView']]
        typ, size = {5126: ('f', 4), 5125: ('I', 4), 5123: ('H', 2), 5121: ('B', 1)}[accessor['componentType']]
        width = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4}[accessor['type']]
        start = view.get('byteOffset', 0)+accessor.get('byteOffset', 0)
        stride = view.get('byteStride', width*size)
        if accessor['count'] <= 0 or start < view.get('byteOffset', 0) or stride < width*size:
            raise ValueError('Invalid accessor range')
        if start+(accessor['count']-1)*stride+width*size > view.get('byteOffset', 0)+view['byteLength']:
            raise ValueError('Accessor outside buffer view')
        return [struct.unpack_from('<'+typ*width, binary, start+i*stride) for i in range(accessor['count'])]

    positions = values(primitive['attributes']['POSITION'])
    normals = values(primitive['attributes']['NORMAL'])
    uv = values(primitive['attributes']['TEXCOORD_0'])
    if len(positions) != len(normals) or len(positions) != len(uv):
        raise ValueError('Attribute counts differ')
    if not all(math.isfinite(v) for rows in [positions, normals, uv] for row in rows for v in row):
        raise ValueError('Nonfinite mesh attribute')
    indices = [v[0] for v in values(primitive['indices'])]
    if len(indices) % 3 or min(indices) < 0 or max(indices) >= len(positions):
        raise ValueError('Invalid triangle indices')
    images = []
    for image in data.get('images', []):
        if 'uri' in image or 'bufferView' not in image:
            raise ValueError('Expected self-contained embedded textures')
        view = data['bufferViews'][image['bufferView']]
        start = view.get('byteOffset', 0)
        blob = binary[start:start+view['byteLength']]
        if not blob.startswith((b'\xff\xd8', b'\x89PNG')):
            raise ValueError('Invalid encoded texture header')
        images.append({'bytes': len(blob), 'sha256': hashlib.sha256(blob).hexdigest()})
    if len(images) != 3:
        raise ValueError('All three original texture maps must remain embedded')
    material = data['materials'][0]
    for info in [material['normalTexture'], material['pbrMetallicRoughness']['baseColorTexture'],
                 material['pbrMetallicRoughness']['metallicRoughnessTexture']]:
        texture = data['textures'][info['index']]
        if texture['source'] >= len(images) or info.get('texCoord', 0) != 0:
            raise ValueError('Invalid material/UV binding')
    return {'vertices': len(positions), 'triangles': len(indices)//3,
            'boundsMin': [min(p[i] for p in positions) for i in range(3)],
            'boundsMax': [max(p[i] for p in positions) for i in range(3)], 'images': images}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--folder', type=Path, required=True)
    args = parser.parse_args()
    manifest = json.loads((ROOT/'assets/crash-sites/MANIFEST.json').read_text(encoding='utf-8'))
    for item in manifest['files']:
        if hashlib.sha256((ROOT/item['localPath']).read_bytes()).hexdigest() != item['sha256']:
            raise ValueError('An original source has changed')
    for site, source_name in [('upright', 'Meshy_AI_Heli_1018042915_texture.glb'),
                               ('collapsed', 'Meshy_AI_Heli_1018043921_texture.glb')]:
        folder = args.folder/site
        report = json.loads((folder/'export-report.json').read_text(encoding='utf-8'))
        stats = glb(folder/f'crash_site_{site}.glb')
        source = next(row for row in manifest['files'] if row['name'] == source_name)
        if {i['sha256'] for i in stats['images']} != {i['sha256'] for i in source['images']}:
            raise ValueError('Original encoded textures were not retained exactly')
        if not 0 < stats['triangles'] <= 25000:
            raise ValueError('Triangle budget exceeded')
        for output in report['outputs']:
            path = folder/output['name']
            if path.stat().st_size != output['bytes'] or hashlib.sha256(path.read_bytes()).hexdigest() != output['sha256']:
                raise ValueError('Optimized output hash/size mismatch')
        print(json.dumps({'site': site, 'stats': stats}))
    print('OFFLINE PASS: original fingerprints, single static meshes, attributes/indices, embedded original textures and export hashes. NOT PZ/native/runtime proof.')


if __name__ == '__main__':
    main()
