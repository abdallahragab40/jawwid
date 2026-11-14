import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('release_audit', Path(__file__).parents[1] / 'release_audit.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ReleaseAuditTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.content = self.root / 'assets' / 'content'
        self.content.mkdir(parents=True)
        self.write('curriculum.json', {'topics': [{'id': 't01', 'pages': {lang: [1, 2] for lang in module.LANGUAGES}}]})
        self.write('rules.json', {'rules': [{'id': 'r01', 'topic': 't01', 'review': {'status': 'draft'}}]})
        self.write('quiz.json', {'questions': [{'id': 'q01', 'topic': 't01', 'type': 'identify', 'review': {'status': 'reviewed'}, 'options': ['r01']}]})
        for lang in module.LANGUAGES:
            self.write(f'lessons_{lang}.json', {'lessons': {'t01': {'review': 'reviewed' if lang == 'en' else 'draft'}}})

    def write(self, name, value):
        (self.content / name).write_text(json.dumps(value))

    def test_language_specific_reviews_and_dependency_blocking(self):
        report = module.audit(self.root)
        self.assertEqual(report['lessons']['en']['reviewed'], 1)
        self.assertEqual(report['lessons']['ar']['reviewed'], 0)
        self.assertEqual(report['reviewed_questions_with_unavailable_options'], [{'id': 'q01', 'unavailable_rule_options': ['r01']}])
        self.assertFalse(report['all_content_reviewed'])
        module.write_report(report, self.root / 'report')
        self.assertTrue((self.root / 'report' / 'review-matrix.csv').exists())
        # Reporting does not approve or modify a source asset.
        self.assertEqual(json.loads((self.content / 'rules.json').read_text())['rules'][0]['review']['status'], 'draft')

    def test_missing_lessons_and_asset_changes_are_visible(self):
        original = module.audit(self.root)
        self.write('lessons_en.json', {'lessons': {}})
        changed = module.audit(self.root)
        self.assertEqual(changed['missing_native_lessons'], [{'topic': 't01', 'language': 'en'}])
        self.assertNotEqual(original['files']['lessons_en.json'], changed['files']['lessons_en.json'])
        self.assertFalse(changed['all_content_reviewed'])


if __name__ == '__main__':
    unittest.main()
