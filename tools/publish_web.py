"""Publish the verified web build to this repository's GitHub Pages branch.
Run export_web.sh first. Requires Git authentication and gh for Pages setup.
"""
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]

def run(*args, cwd=ROOT):
    return subprocess.run(args, cwd=cwd, check=True, text=True, capture_output=True).stdout.strip()

def main():
    build = ROOT / 'builds/web'
    for name in ('index.html', 'index.js', 'index.wasm', 'index.pck'):
        if not (build / name).is_file():
            raise SystemExit('Missing web build. Run bash tools/export_web.sh first.')
    remote = run('git', 'remote', 'get-url', 'origin')
    revision = run('git', 'rev-parse', '--short', 'HEAD')
    with tempfile.TemporaryDirectory(prefix='temple-pages-') as directory:
        dest = Path(directory)
        run('git', 'init', '-b', 'gh-pages', cwd=dest)
        run('git', 'remote', 'add', 'origin', remote, cwd=dest)
        exists = run('git', 'ls-remote', '--heads', 'origin', 'gh-pages', cwd=dest)
        if exists:
            run('git', 'fetch', '--depth=1', 'origin', 'gh-pages', cwd=dest)
            run('git', 'reset', '--hard', 'FETCH_HEAD', cwd=dest)
        for source in build.iterdir():
            if source.is_file():
                shutil.copyfile(source, dest / source.name)
        (dest / '.nojekyll').touch()
        (dest / 'build.txt').write_text(revision + '\n')
        run('git', 'add', '.', cwd=dest)
        if run('git', 'status', '--porcelain', cwd=dest):
            run('git', 'commit', '-m', 'Publish web preview ' + revision, cwd=dest)
            print(run('git', 'push', 'origin', 'gh-pages', cwd=dest))
    print('Published gh-pages branch. Configure Pages to deploy gh-pages / (root).')

if __name__ == '__main__':
    main()
