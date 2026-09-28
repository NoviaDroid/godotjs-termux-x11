"""Create an isolated godotjs recipe using the upstream 4.6.1 patches."""
import pathlib
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
revision = '177b74a5677ad0d9d6cca46ec597ed37c389be3e'
package = root / 'x11-packages/godotjs'
if package.exists():
    raise SystemExit('Recipe already exists; inspect it before rebuilding.')
subprocess.run(['git', '-C', str(root), 'fetch', '--depth', '1', 'origin', revision], check=True)
names = subprocess.check_output(['git', '-C', str(root), 'ls-tree', '-r', '--name-only', revision, 'x11-packages/godot'], text=True).splitlines()
package.mkdir()
for name in names:
    # Upstream forces OpenGL by default. Keep upstream Godot renderer selection.
    if name.endswith('/main.cpp.patch') or name.endswith('/build.sh'):
        continue
    data = subprocess.check_output(['git', '-C', str(root), 'show', revision + ':' + name])
    (package / pathlib.Path(name).name).write_bytes(data)
recipe = pathlib.Path(__file__).resolve().parent.parent / 'termux/build.sh'
(package / 'build.sh').write_bytes(recipe.read_bytes())
subprocess.run(['git', '-C', str(root), 'apply', str(recipe.parent / 'no-fuse.patch')], check=True)
print('Prepared:', package)
