#!/usr/bin/env python3
"""Builds the platform app icons from the Flutter-rendered artwork.

Inputs (render first: flutter test test/rendering/app_icon_test.dart --update-goldens):
  test/rendering/goldens/app_icon_1024.png  full icon (opaque)
  test/rendering/goldens/app_icon_fg.png    foreground on transparency (Android adaptive icon)
Outputs: the iOS AppIcon set (sizes read from its Contents.json, alpha removed as
App Store requires) and Android legacy + adaptive launcher icons.
Needs Pillow.
"""
import json, os
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
G = os.path.join(ROOT, 'test', 'rendering', 'goldens')
full = Image.open(os.path.join(G, 'app_icon_1024.png')).convert('RGB')
fg = Image.open(os.path.join(G, 'app_icon_fg.png')).convert('RGBA')

ios = os.path.join(ROOT, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
for img in json.load(open(os.path.join(ios, 'Contents.json')))['images']:
    px = round(float(img['size'].split('x')[0]) * int(img['scale'][0]))
    full.resize((px, px), Image.LANCZOS).save(os.path.join(ios, img['filename']))

res = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
for d, s in {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}.items():
    out = os.path.join(res, f'mipmap-{d}')
    os.makedirs(out, exist_ok=True)
    full.resize((round(48 * s),) * 2, Image.LANCZOS).save(os.path.join(out, 'ic_launcher.png'))
    fg.resize((round(108 * s),) * 2, Image.LANCZOS).save(os.path.join(out, 'ic_launcher_foreground.png'))
anydpi = os.path.join(res, 'mipmap-anydpi-v26')
os.makedirs(anydpi, exist_ok=True)
open(os.path.join(anydpi, 'ic_launcher.xml'), 'w').write(
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
    '    <background android:drawable="@color/ic_launcher_background"/>\n'
    '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
    '</adaptive-icon>\n')
open(os.path.join(res, 'values', 'colors.xml'), 'w').write(
    '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
    '    <color name="ic_launcher_background">#1C6A55</color>\n'
    '    <color name="launch_background">#FBF8F1</color>\n</resources>\n')
print('icons written')
