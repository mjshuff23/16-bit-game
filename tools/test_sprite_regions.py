"""Exercise the metadata builder in disposable projects, preserving real assets."""
import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
GODOT = str(Path.home() / '.local/bin/godot')

class BuilderTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'project.godot').write_text('config_version=5\n')
        self.assets = self.root / 'assets/characters'
        self.assets.mkdir(parents=True)
        for source in (ROOT / 'assets/characters').glob('*.png'):
            shutil.copyfile(source, self.assets / source.name)
        shutil.copyfile(ROOT / 'tools/build_sprite_regions.gd', self.root / 'builder.gd')
        self.output = self.assets / 'regions.gd'

    def run_builder(self):
        return subprocess.run([GODOT, '--headless', '--path', str(self.root), '--script', 'builder.gd'], capture_output=True, text=True, timeout=30)

    def test_valid_sheets_reproduce_checked_in_metadata(self):
        result = self.run_builder()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.output.read_text(), (ROOT / 'assets/characters/regions.gd').read_text())

    def test_missing_or_corrupt_sheet_preserves_previous_metadata(self):
        sheet = self.assets / 'patryn.png'
        for corrupt in (False, True):
            with self.subTest(corrupt=corrupt):
                self.output.write_text('preserve me')
                if corrupt:
                    sheet.write_bytes(b'not a png')
                else:
                    sheet.unlink()
                result = self.run_builder()
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.output.read_text(), 'preserve me')

    def test_unwritable_output_fails(self):
        self.output.mkdir()
        result = self.run_builder()
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('SCRIPT ERROR', result.stdout + result.stderr)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--godot', default=GODOT)
    args, remaining = parser.parse_known_args()
    GODOT = args.godot
    unittest.main(argv=[__file__, *remaining])
