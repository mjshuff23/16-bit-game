"""Package tracked and non-ignored source, including uncommitted work.

Run with Python 3 from any directory. Git is required only to create the ZIP.
The resulting source can be opened in Godot without Python or Git.
"""

from pathlib import Path
import subprocess
from zipfile import ZIP_DEFLATED, ZipFile


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    result = subprocess.run(
        ["git", "-C", str(root), "ls-files", "--cached", "--others",
         "--exclude-standard", "-z"],
        check=True, capture_output=True,
    )
    names = sorted(set(result.stdout.decode("utf-8").rstrip("\0").split("\0")))
    destination = root / "builds" / "16-bit-game-source.zip"
    destination.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(destination, "w", ZIP_DEFLATED) as archive:
        for name in names:
            source = root / name
            if source.is_file():
                archive.write(source, name)
    with ZipFile(destination) as archive:
        damaged = archive.testzip()
        if damaged:
            raise RuntimeError(f"Source archive failed validation: {damaged}")
        print(f"Packaged {len(archive.namelist())} files: {destination}")


if __name__ == "__main__":
    main()
