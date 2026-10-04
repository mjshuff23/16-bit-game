import importlib.util
from pathlib import Path
import tempfile
import unittest
from io import BytesIO
from unittest.mock import patch
from hashlib import sha256
from zipfile import ZipFile

spec = importlib.util.spec_from_file_location('setup_gut', Path(__file__).with_name('setup_gut.py'))
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)

class SetupTests(unittest.TestCase):
    def archive(self, name):
        buffer = BytesIO()
        with ZipFile(buffer, 'w') as archive:
            archive.writestr(name, 'test')
        return buffer.getvalue()

    def test_bad_checksum_does_not_write(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                setup.install(b'invalid', Path(directory) / 'gut')
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_unsafe_archive_path_rejected(self):
        data = self.archive(setup.PREFIX + '../escape')
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                setup.unpack(data, Path(directory))
            self.assertFalse((Path(directory).parent / 'escape').exists())

    def test_incomplete_archive_leaves_no_install(self):
        data = self.archive(setup.PREFIX + 'LICENSE.md')
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / 'gut'
            with patch.object(setup, 'SHA256', sha256(data).hexdigest()):
                with self.assertRaises(ValueError):
                    setup.install(data, destination)
            self.assertFalse(destination.exists())
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_existing_install_is_preserved(self):
        data = self.archive(setup.PREFIX + 'LICENSE.md')
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory)
            sentinel = destination / 'local-change.txt'
            sentinel.write_text('keep')
            with patch.object(setup, 'SHA256', sha256(data).hexdigest()):
                with self.assertRaises(FileExistsError):
                    setup.install(data, destination)
            self.assertEqual(sentinel.read_text(), 'keep')
    def test_only_addon_files_extracted(self):
        data = self.archive(setup.PREFIX + 'LICENSE.md')
        with tempfile.TemporaryDirectory() as directory:
            setup.unpack(data, Path(directory))
            self.assertEqual((Path(directory) / 'LICENSE.md').read_text(), 'test')

if __name__ == '__main__':
    unittest.main()
