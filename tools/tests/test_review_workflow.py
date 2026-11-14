import contextlib
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import apply_review
import approve_lesson
from review_integrity import approved_item, item_fingerprint, file_fingerprint


class ReviewWorkflowTest(unittest.TestCase):
    def test_stale_csv_cannot_approve_changed_answer_and_change_revokes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'content_src').mkdir()
            (root / 'docs/review').mkdir(parents=True)
            (root / 'content_src/rules.src.json').write_text('{"rules": []}')
            question = {'id': 'q1', 'topic': 't01', 'answer': 1}
            path = root / 'content_src/quiz.src.json'
            path.write_text(json.dumps({'questions': [question]}))
            csv = root / 'review.csv'
            fingerprint = item_fingerprint(question)
            csv.write_text(f'kind,id,decision,source_sha256\nquestion,q1,ok,{fingerprint}\n')
            with patch.object(apply_review, 'ROOT', str(root)), patch.object(sys, 'argv', ['apply_review.py', str(csv)]), contextlib.redirect_stdout(io.StringIO()):
                apply_review.main()
            question = json.loads(path.read_text())['questions'][0]
            self.assertTrue(approved_item(question))
            question['answer'] = 2
            path.write_text(json.dumps({'questions': [question]}))
            with patch.object(apply_review, 'ROOT', str(root)), patch.object(sys, 'argv', ['apply_review.py', str(csv)]), contextlib.redirect_stdout(io.StringIO()):
                apply_review.main()
            self.assertFalse(approved_item(json.loads(path.read_text())['questions'][0]))
            csv.write_text('kind,id,decision,source_sha256\nquestion,q1,change,\n')
            with patch.object(apply_review, 'ROOT', str(root)), patch.object(sys, 'argv', ['apply_review.py', str(csv)]), contextlib.redirect_stdout(io.StringIO()):
                apply_review.main()
            self.assertEqual(json.loads(path.read_text())['questions'][0]['review']['status'], 'draft')

    def test_lesson_command_refuses_stale_hash_without_writing_approval(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            lessons = root / 'content_src/lessons'
            lessons.mkdir(parents=True)
            source = lessons / 't01.en.txt'
            source.write_text('Reviewed lesson')
            fingerprint = file_fingerprint(source)
            source.write_text('Changed lesson')
            argv = ['approve_lesson.py', '--language', 'en', '--topic', 't01', '--reviewer', 'Teacher', '--sha256', fingerprint]
            with patch.object(approve_lesson, 'ROOT', root), patch.object(sys, 'argv', argv), contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit):
                    approve_lesson.main()
            self.assertFalse((lessons / 'reviewed.json').exists())


if __name__ == '__main__':
    unittest.main()
