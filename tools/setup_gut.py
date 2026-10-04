"""Install the pinned GUT addon. Python 3 standard library only."""
from hashlib import sha256
from io import BytesIO
from pathlib import Path, PurePosixPath
import tempfile
from urllib.request import urlopen
from zipfile import ZipFile

VERSION = '9.7.1'
URL = f'https://codeload.github.com/bitwes/Gut/zip/refs/tags/v{VERSION}'
SHA256 = '14969aa46adc84aa08cdd21b9f6d1a64addd92ae60b36f02d0521ed305aa4086'
PREFIX = f'Gut-{VERSION}/addons/gut/'
MARKER = '.setup-sha256'


def unpack(data: bytes, destination: Path) -> None:
    with ZipFile(BytesIO(data)) as archive:
        for entry in archive.infolist():
            if not entry.filename.startswith(PREFIX):
                continue
            relative = PurePosixPath(entry.filename[len(PREFIX):])
            if relative.is_absolute() or '..' in relative.parts or '\\' in str(relative) or ':' in str(relative):
                raise ValueError('Unsafe archive path')
            if entry.is_dir():
                continue
            target = destination.joinpath(*relative.parts)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(archive.read(entry))


def install(data: bytes, destination: Path) -> None:
    if sha256(data).hexdigest() != SHA256:
        raise ValueError('GUT checksum mismatch; installation refused')
    if destination.exists():
        raise FileExistsError(f'{destination} already exists; move it aside before reinstalling')
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=destination.parent) as temporary:
        staged = Path(temporary) / 'gut'
        staged.mkdir()
        unpack(data, staged)
        if not (staged / 'gut_cmdln.gd').is_file() or not list(staged.glob('LICENSE*')):
            raise ValueError('GUT archive is missing its runner or license')
        (staged / MARKER).write_text(SHA256 + '\n', encoding='utf-8')
        staged.rename(destination)


def main() -> None:
    destination = Path(__file__).resolve().parents[1] / 'addons' / 'gut'
    marker = destination / MARKER
    if marker.is_file() and marker.read_text().strip() == SHA256 and (destination / 'gut_cmdln.gd').is_file():
        print(f'GUT {VERSION} already installed')
        return
    if destination.exists():
        raise SystemExit(f'Unmanaged or incomplete GUT at {destination}. Move it aside and rerun setup; no files were overwritten.')
    print(f'Downloading GUT {VERSION}...')
    with urlopen(URL, timeout=60) as response:
        data = response.read()
    install(data, destination)
    print(f'Installed GUT {VERSION} (SHA-256 verified)')


if __name__ == '__main__':
    main()
