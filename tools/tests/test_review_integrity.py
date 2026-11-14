import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('review_integrity', Path(__file__).parents[1] / 'review_integrity.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ReviewIntegrityTest(unittest.TestCase):
    def test_changed_answer_or_translation_revokes_approval(self):
        item = {'id': 'q1', 'answer': 1, 'prompt': {'en': 'Original'}}
        item['review'] = {'status': 'reviewed', 'source_sha256': module.item_fingerprint(item)}
        self.assertTrue(module.approved_item(item))
        item['review']['by'] = 'Human reviewer'
        self.assertTrue(module.approved_item(item))
        item['prompt']['en'] = 'Changed translation'
        self.assertFalse(module.approved_item(item))
        self.assertFalse(module.approved_item({'id': 'q1', 'review': {'status': 'reviewed'}}))

    def test_lesson_approval_only_applies_to_reviewed_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / 't01.en.txt'
            source.write_text('Original source')
            approvals = {'en': {'t01': {'status': 'reviewed', 'source_sha256': module.file_fingerprint(source)}}}
            self.assertTrue(module.approved_lesson(approvals, 'en', 't01', source))
            source.write_text('Edited source')
            self.assertFalse(module.approved_lesson(approvals, 'en', 't01', source))
            self.assertFalse(module.approved_lesson({'en': ['t01']}, 'en', 't01', source))


if __name__ == '__main__':
    unittest.main()
