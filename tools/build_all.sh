#!/bin/sh
# Rebuilds all generated content in the right order.
set -e
# PYTHON may point to an interpreter with PyMuPDF (needed only for new !crop images).
cd "$(dirname "$0")/.."
python3 -I tools/build_content.py   # rules, quiz, and quran.json (rule/quiz verses)
${PYTHON:-python3} -I tools/build_lessons.py   # lessons_<lang>.json, adds lesson verses to quran.json
