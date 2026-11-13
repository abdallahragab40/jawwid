#!/usr/bin/env python3
"""Drafts "identify the rule" practice questions from the books' own examples.

Examples come from the Arabic lessons (tools/harvest_examples.py, which uses the
lesson builder's Tanzil resolver), so every word is one the book prints and is
copied verbatim from Tanzil; no Qur'anic text is typed here. Explanations are
filled from per-rule templates in four languages.

Writes the drafted questions into content_src/quiz.src.json, replacing the
questions this tool wrote before (ids q101 and up). Hand-written questions
(q01–q99) are never touched. All drafted questions are status "draft".

Usage: python3 -I tools/gen_identify_questions.py && ./tools/build_all.sh
"""
import io, json, os, random, sys
from contextlib import redirect_stdout

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
with redirect_stdout(io.StringIO()):
    import harvest_examples as hx  # noqa: E402
from build_content import FOLD, is_mark  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
QUIZ = os.path.join(ROOT, 'content_src', 'quiz.src.json')
RULES = os.path.join(ROOT, 'content_src', 'rules.src.json')
FIRST_ID = 101

TANWEEN = {'ً', 'ٌ', 'ٍ'}

# Distractor pools: plausible confusions for each rule.
_NOON = ['r01', 'r02', 'r03', 'r04', 'r05']
_LAM = ['r11', 'r12', 'r13', 'r14']
_MADD = ['r15', 'r16', 'r17', 'r18', 'r20', 'r21', 'r22']
POOL = {**{r: _NOON for r in _NOON}, **{r: _LAM for r in _LAM}, **{r: _MADD for r in _MADD},
        'r06': ['r07', 'r08', 'r02'], 'r07': ['r06', 'r08', 'r04', 'r05'],
        'r08': ['r06', 'r07', 'r01'], 'r09': ['r02', 'r06', 'r05'], 'r10': ['r01', 'r08', 'r09']}

# Per-rule explanation templates. {L} = the letter that decides the rule,
# {K} = noon sakinah or tanween (language-specific), {V}/{P} Arabic agreement.
KIND = {
    'n': {'ar': ('النون الساكنة', 'تلاها', 'تُ'), 'ckb': 'نونی ساکن', 'en': 'The noon sakinah', 'id': 'Nun sukun'},
    't': {'ar': ('التنوين', 'تلاه', 'يُ'), 'ckb': 'تەنوین', 'en': 'The tanween', 'id': 'Tanwin'},
}
T = {
    'r01': {'ar': '{K} {V} حرف ({L})، وهو من حروف الحلق، فالحكم إظهار حلقي.',
            'ckb': '{K} پیتی ({L})ی بەدوادا هاتووە کە پیتێکی گەرووە، بۆیە حوکمەکە ئیزهاری حەلقییە.',
            'en': '{K} is followed by ({L}), a throat letter, so the rule is Ithhar Halqy.',
            'id': '{K} diikuti huruf ({L}), salah satu huruf halq, sehingga hukumnya izhhar halqi.'},
    'r02': {'ar': '{K} {V} حرف ({L})، وهو من حروف (ينمو)، ف{P}دغم بغنة.',
            'ckb': '{K} پیتی ({L})ی بەدوادا هاتووە کە یەکێکە لە پیتەکانی (ينمو)، بۆیە بە مینگەوە تێهەڵکێش دەکرێت.',
            'en': '{K} is followed by ({L}), one of the letters of (ينمو), so it merges with ghunnah.',
            'id': '{K} diikuti huruf ({L}), salah satu huruf (ينمو), sehingga diidghamkan dengan ghunnah.'},
    'r03': {'ar': '{K} {V} حرف ({L})، ف{P}دغم بلا غنة.',
            'ckb': '{K} پیتی ({L})ی بەدوادا هاتووە، بۆیە بەبێ مینگە تێهەڵکێش دەکرێت.',
            'en': '{K} is followed by ({L}), so it merges without ghunnah.',
            'id': '{K} diikuti huruf ({L}), sehingga diidghamkan tanpa ghunnah.'},
    'r04': {'ar': '{K} {V} حرف الباء، ف{P}قلب ميمًا مخفاة مع الغنة.',
            'ckb': '{K} پیتی (ب)ی بەدوادا هاتووە، بۆیە دەگۆڕدرێت بۆ میمێکی شاراوە لەگەڵ مینگەدا.',
            'en': '{K} is followed by (ب), so it changes into a hidden meem with ghunnah.',
            'id': '{K} diikuti huruf ba, sehingga berubah menjadi mim tersembunyi dengan ghunnah.'},
    'r05': {'ar': '{K} {V} حرف ({L})، وهو من حروف الإخفاء، ف{P}خفى مع الغنة.',
            'ckb': '{K} پیتی ({L})ی بەدوادا هاتووە کە یەکێکە لە پیتەکانی ئیخفاء، بۆیە بە مینگەوە دەشاردرێتەوە.',
            'en': '{K} is followed by ({L}), one of the ikhfaa letters, so it is hidden with ghunnah.',
            'id': '{K} diikuti huruf ({L}), salah satu huruf ikhfa, sehingga disamarkan dengan ghunnah.'},
    'r06': {'ar': 'الميم الساكنة تلاها ميم، فتُدغم إدغامًا شفويًّا مع الغنة.',
            'ckb': 'میمی ساکن میمێکی بەدوادا هاتووە، بۆیە بە تێهەڵکێشکردنی لێوی و بە مینگەوە دەخوێنرێت.',
            'en': 'The meem sakinah is followed by another meem, so it is Idgham Shafawi with ghunnah.',
            'id': 'Mim sukun diikuti mim, sehingga hukumnya idgham syafawi dengan ghunnah.'},
    'r07': {'ar': 'الميم الساكنة تلاها حرف الباء، فتُخفى إخفاءً شفويًّا مع الغنة.',
            'ckb': 'میمی ساکن پیتی (ب)ی بەدوادا هاتووە، بۆیە بە شاردنەوەی لێوی دەخوێنرێت.',
            'en': 'The meem sakinah is followed by (ب), so it is Ikhfaa Shafawi.',
            'id': 'Mim sukun diikuti huruf ba, sehingga hukumnya ikhfa syafawi.'},
    'r08': {'ar': 'الميم الساكنة تلاها حرف ({L})، وهو ليس ميمًا ولا باءً، فتُظهَر.',
            'ckb': 'میمی ساکن پیتی ({L})ی بەدوادا هاتووە کە نە میمە و نە (ب)ە، بۆیە ئاشکرا دەکرێت.',
            'en': 'The meem sakinah is followed by ({L}), which is neither meem nor baa, so it is pronounced clearly.',
            'id': 'Mim sukun diikuti huruf ({L}), bukan mim dan bukan ba, sehingga dibaca jelas.'},
    'r09': {'ar': 'حرف ({L}) مشدَّد، فتظهر غنته كاملة.',
            'ckb': 'پیتی ({L}) شەددارە، بۆیە مینگەکەی بە تەواوی درێژ دەکرێتەوە.',
            'en': 'The ({L}) carries a shaddah, so its ghunnah is held in full.',
            'id': 'Huruf ({L}) bertasydid, sehingga ghunnahnya dipanjangkan dengan sempurna.'},
    'r10': {'ar': 'حرف ({L}) من حروف القلقلة (قُطْبُ جَدٍّ) وهو ساكن هنا، فيُقلقَل.',
            'ckb': 'پیتی ({L}) یەکێکە لە پیتەکانی قەلقەلە (قُطْبُ جَدٍّ) و لێرەدا ساکنە، بۆیە دەهەژێت.',
            'en': '({L}) is one of the qalqalah letters (قُطْبُ جَدٍّ) and is sakin here, so it is pronounced with qalqalah.',
            'id': 'Huruf ({L}) termasuk huruf qalqalah (قُطْبُ جَدٍّ) dan di sini sukun, sehingga dibaca qalqalah.'},
    'r11': {'ar': 'لام «ال» تلاها حرف ({L})، وهو من الحروف القمرية، فتُظهَر اللام.',
            'ckb': 'لامی «ال» پیتی ({L})ی بەدوادا هاتووە کە پیتێکی قەمەرییە، بۆیە لامەکە ئاشکرا دەکرێت.',
            'en': 'The laam of «ال» is followed by ({L}), a lunar letter, so the laam is pronounced clearly.',
            'id': 'Lam pada «ال» diikuti huruf ({L}), huruf qamariyah, sehingga lam dibaca jelas.'},
    'r12': {'ar': 'لام «ال» تلاها حرف ({L})، وهو من الحروف الشمسية، فتُدغم اللام فيه.',
            'ckb': 'لامی «ال» پیتی ({L})ی بەدوادا هاتووە کە پیتێکی شەمسییە، بۆیە لامەکە تێهەڵکێش دەکرێت.',
            'en': 'The laam of «ال» is followed by ({L}), a solar letter, so the laam merges into it.',
            'id': 'Lam pada «ال» diikuti huruf ({L}), huruf syamsiyah, sehingga lam diidghamkan.'},
    'r15': {'ar': 'حرف المد ({L}) لم يأتِ بعده همز ولا سكون، فهو مد طبيعي.',
            'ckb': 'پیتی مەد ({L}) نە هەمزە و نە ساکنی بەدوادا نەهاتووە، بۆیە مەدی سروشتییە.',
            'en': 'The madd letter ({L}) is followed by neither a hamzah nor a sukoon, so it is a natural madd.',
            'id': 'Huruf mad ({L}) tidak diikuti hamzah maupun sukun, sehingga ini mad asli.'},
    'r16': {'ar': 'تقدَّم الهمز على حرف المد ({L}) في كلمة واحدة، فهو مد بدل.',
            'ckb': 'لەم وشەیەدا هەمزە پێش پیتی مەد ({L}) کەوتووە، بۆیە مەدی بەدەلە.',
            'en': 'A hamzah comes before the madd letter ({L}) in the same word, so it is Madd al-Badal.',
            'id': 'Hamzah mendahului huruf mad ({L}) dalam satu kata, sehingga ini mad badal.'},
    'r17': {'ar': 'جاء الهمز بعد حرف المد ({L}) في كلمة واحدة، فهو مد واجب متصل.',
            'ckb': 'هەمزە لەدوای پیتی مەد ({L}) لە هەمان وشەدا هاتووە، بۆیە مەدی موتتەصیلە.',
            'en': 'A hamzah comes after the madd letter ({L}) in the same word, so it is Madd Wajib Mu\'tasil.',
            'id': 'Hamzah terletak setelah huruf mad ({L}) dalam satu kata, sehingga ini mad wajib muttashil.'},
    'r18': {'ar': 'حرف المد ({L}) في آخر كلمة والهمز في أول الكلمة التي بعدها، فهو مد جائز منفصل.',
            'ckb': 'پیتی مەد ({L}) لە کۆتایی وشەیەکە و هەمزە لە سەرەتای وشەی دواتردایە، بۆیە مەدی مونفەصیلە.',
            'en': 'The madd letter ({L}) ends one word and a hamzah begins the next, so it is Madd Ja\'ez Munfasil.',
            'id': 'Huruf mad ({L}) berada di akhir kata dan hamzah di awal kata berikutnya, sehingga ini mad jaiz munfashil.'},
    'r20': {'ar': 'جاء بعد حرف المد حرف مشدَّد في كلمة واحدة، فهو مد لازم كلمي مثقل.',
            'ckb': 'لەدوای پیتی مەدەوە پیتێکی شەددار لە هەمان وشەدا هاتووە، بۆیە مەدی لازمی کەلیمی قورسە.',
            'en': 'A letter with shaddah follows the madd letter in the same word, so it is Madd Lazim Kalimi Muthaqqal.',
            'id': 'Huruf mad diikuti huruf bertasydid dalam satu kata, sehingga ini mad lazim kalimi mutsaqqal.'},
    'r21': {'ar': 'عند الوقف على آخر الآية يُسكَّن الحرف الأخير بعد حرف المد ({L})، فهو مد عارض للسكون.',
            'ckb': 'لەکاتی وەستان لە کۆتایی ئایەتەکە پیتی کۆتایی لەدوای پیتی مەد ({L}) ساکن دەبێت، بۆیە مەدی عارض للسکونە.',
            'en': 'Stopping at the end of the verse makes the last letter sakin after the madd letter ({L}), so it is Madd \'Arid Lissukoon.',
            'id': 'Saat waqaf di akhir ayat, huruf terakhir menjadi sukun setelah huruf mad ({L}), sehingga ini mad \'aridh lissukun.'},
    'r22': {'ar': 'عند الوقف على آخر الآية يُسكَّن الحرف الأخير بعد حرف اللين ({L}) الساكن المفتوح ما قبله، فهو مد لين.',
            'ckb': 'لەکاتی وەستان لە کۆتایی ئایەتەکە پیتی کۆتایی ساکن دەبێت لەدوای پیتی لیینی ({L}) ساکن کە فەتحەی لەپێشە، بۆیە مەدی لیینە.',
            'en': 'Stopping at the end of the verse makes the last letter sakin after the leen letter ({L}), which follows a fathah, so it is Madd al-Leen.',
            'id': 'Saat waqaf di akhir ayat, huruf terakhir menjadi sukun setelah huruf lin ({L}) yang didahului fathah, sehingga ini mad lin.'},
}
# Laam of the name of Allah: the reason depends on what precedes it.
ALLAH = {
    'start': {'ar': 'ابتُدئ بلفظ الجلالة، فتُفخَّم لامه.',
              'ckb': 'دەستپێکردن بە وشەی (الله)ە، بۆیە لامەکە تەفخیم دەکرێت.',
              'en': 'The recitation starts with the name of Allah, so its laam is heavy.',
              'id': 'Bacaan dimulai dengan lafzhul jalalah, sehingga lam dibaca tebal.'},
    'fatha': {'ar': 'تقدَّم لفظَ الجلالة فتحٌ، فتُفخَّم لامه.',
              'ckb': 'فەتحە پێش وشەی (الله) کەوتووە، بۆیە لامەکە تەفخیم دەکرێت.',
              'en': 'A fathah comes before the name of Allah, so its laam is heavy.',
              'id': 'Lafzhul jalalah didahului fathah, sehingga lam dibaca tebal.'},
    'sukun_fatha': {'ar': 'تقدَّم لفظَ الجلالة ساكنٌ بعد فتح، فتُفخَّم لامه.',
                    'ckb': 'ساکنێک لەدوای فەتحە پێش وشەی (الله) کەوتووە، بۆیە لامەکە تەفخیم دەکرێت.',
                    'en': 'A sakin letter after a fathah comes before the name of Allah, so its laam is heavy.',
                    'id': 'Lafzhul jalalah didahului huruf sukun setelah fathah, sehingga lam dibaca tebal.'},
    'damma': {'ar': 'تقدَّم لفظَ الجلالة ضمٌّ، فتُفخَّم لامه.',
              'ckb': 'ضەممە پێش وشەی (الله) کەوتووە، بۆیە لامەکە تەفخیم دەکرێت.',
              'en': 'A dammah comes before the name of Allah, so its laam is heavy.',
              'id': 'Lafzhul jalalah didahului dhammah, sehingga lam dibaca tebal.'},
    'tanween': {'ar': 'تقدَّم لفظَ الجلالة تنوينٌ، فتُرقَّق لامه.',
                'ckb': 'تەنوین پێش وشەی (الله) کەوتووە، بۆیە لامەکە تەرقیق دەکرێت.',
                'en': 'A tanween comes before the name of Allah, so its laam is light.',
                'id': 'Lafzhul jalalah didahului tanwin, sehingga lam dibaca tipis.'},
}

# Hand-picked examples (ref, pattern, rule, letter-or-case). Patterns are the
# book's own words; highlights cover the letters that decide the rule.
PICKED = [
    # Meem sakinah (t11).
    ('106:4', 'اطعمه[م] [م]ن', 'r06', None),
    ('100:11', 'ربه[م] [ب]هم', 'r07', None),
    ('52:22', 'وا[م][د]دنهم', 'r08', 'د'), ('13:17', 'في[م][ك]ث', 'r08', 'ك'),
    ('3:198', 'له[م] [ج]نت', 'r08', 'ج'), ('44:37', 'اه[م] [خ]ير', 'r08', 'خ'),
    ('9:50', 'وه[م] [ف]رحون', 'r08', 'ف'), ('30:17', 'ت[م][س]ون', 'r08', 'س'),
    ('36:56', 'ه[م] [و]ازوجهم', 'r08', 'و'),
    # Noon and meem mushaddad (t12).
    ('8:43', 'ولك[ن] الله', 'r09', 'نّ'), ('36:68', 'ومن [ن]عمره', 'r09', 'نّ'),
    ('111:4', 'ح[م]الة الحطب', 'r09', 'مّ'), ('23:55', 'من [م]ال', 'r09', 'مّ'),
    ('2:20', 'ا[ن] الله', 'r09', 'نّ'),
    # Qalqalah (t08): sakin in the middle of the reading.
    ('106:4', 'ا[ط]عمهم', 'r10', 'ط'), ('18:48', 'ن[ج]عل', 'r10', 'ج'),
    ('100:4', 'ن[ق]عا', 'r10', 'ق'), ('111:5', 'ح[ب]ل', 'r10', 'ب'),
    ('4:124', 'ي[د]خلون', 'r10', 'د'), ('23:1', 'ق[د] افلح', 'r10', 'د'),
    ('20:24', 'اذه[ب] الي', 'r10', 'ب'),
    # Laam of «ال» (t18).
    ('15:3', 'ا[لا]مل', 'r11', 'ء'), ('59:24', 'ا[لب]اري', 'r11', 'ب'),
    ('6:133', 'ا[لغ]ني', 'r11', 'غ'), ('18:9', 'ا[لك]هف', 'r11', 'ك'),
    ('7:69', 'ا[لخ]لق', 'r11', 'خ'), ('2:32', 'ا[لع]ليم', 'r11', 'ع'),
    ('76:11', 'ا[لي]وم', 'r11', 'ي'), ('2:120', 'ا[له]دي', 'r11', 'ه'),
    ('5:4', 'ا[لط]يبت', 'r12', 'ط'), ('3:195', 'ا[لث]واب', 'r12', 'ث'),
    ('4:69', 'وا[لص]لحين', 'r12', 'ص'), ('51:58', 'ا[لر]زاق', 'r12', 'ر'),
    ('15:9', 'ا[لذ]كر', 'r12', 'ذ'), ('5:65', 'ا[لن]عيم', 'r12', 'ن'),
    ('2:127', 'ا[لس]ميع', 'r12', 'س'), ('21:105', 'ا[لز]بور', 'r12', 'ز'),
    # Laam of the name of Allah (t14).
    ('2:255', '[الل]ه لا اله', 'r13', 'start'), ('37:40', 'عبا[د] ا[لل]ه', 'r13', 'fatha'),
    ('2:210', 'وا[لي] ا[لل]ه', 'r13', 'sukun_fatha'), ('19:30', 'عب[د] ا[لل]ه', 'r13', 'damma'),
    # 7:164 «قَوْمًا ۙ ٱللَّهُ» is not used: the pause mark between the words
    # cannot be spanned by the quiz build.
    # Madd (t15).
    ('11:43', 'وح[ا]ل', 'r15', 'ا'), ('2:22', 'اند[ا]دا', 'r15', 'ا'),
    ('2:8', 'يق[و]ل', 'r15', 'و'), ('8:24', 'يح[و]ل', 'r15', 'و'),
    ('2:11', 'ق[ي]ل', 'r15', 'ي'), ('34:54', 'وح[ي]ل', 'r15', 'ي'),
    ('2:9', '[ءا]منوا', 'r16', 'ا'), ('2:101', '[او]توا', 'r16', 'و'),
    ('2:31', '[ءا]دم', 'r16', 'ا'), ('2:185', 'القر[ءا]ن', 'r16', 'ا'),
    ('17:34', 'مس[و]لا', 'r16', 'و'),
    ('35:37', 'وج[اء]كم', 'r17', 'ا'), ('69:19', 'ه[او]م', 'r17', 'ا'),
    ('24:31', 'وتو[بوا] [ا]لي', 'r18', 'و'), ('2:235', 'ف[ي] [ا]نفسكم', 'r18', 'ي'),
    ('2:4', 'بم[ا] [ا]نزل', 'r18', 'ا'), ('66:6', 'ق[وا] [ا]نفسكم', 'r18', 'و'),
    ('3:66', '[ها]نتم', 'r18', 'ا'), ('2:21', '[يا]يها', 'r18', 'ا'),
    ('5:2', 'ء[ام]ين', 'r20', None), ('10:59', 'ء[الل]ه', 'r20', None),
    ('6:143', 'ء[الذ]كرين', 'r20', None),
    ('2:207', 'بالعب[اد]', 'r21', 'ا'), ('9:20', 'الفايز[ون]', 'r21', 'و'),
    ('106:4', 'خ[وف]', 'r22', 'و'),
]


def base_letters(s):
    """[(folded letter, marks)] of a pattern, with the bracketed flag."""
    out, inside = [], False
    for ch in s:
        if ch == '[':
            inside = True; continue
        if ch == ']':
            inside = False; continue
        if is_mark(ch):
            if out:
                out[-1][1].add(ch)
            continue
        if ch == ' ':
            out.append((' ', set(), inside)); continue
        f = FOLD.get(ch, ch)
        if f:
            out.append((ch, set(), inside))
    return out


def noon_case(pattern):
    """(kind, letter) for a noon-sakinah/tanween table example."""
    hl = [(c, m) for c, m, ins in base_letters(pattern) if ins and c != ' ']
    first_c, first_m = hl[0]
    kind = 't' if (first_m & TANWEEN or first_c != 'ن') else 'n'
    last = hl[-1][0]
    return kind, {'أ': 'ء', 'إ': 'ء'}.get(last, last)


def noon_examples():
    """Rows of the noon sakinah / tanween example tables (t10)."""
    ex = hx.harvest('t10')
    out = []
    for e in ex:
        if not e['table']:
            continue
        h = e['h1'] + ' / ' + e['h2'] + ' / ' + e['h3']
        if 'الإظهار' in e['h1'] and e['h3'] == 'الأمثلة':
            rule = 'r01'
        elif 'بغُنَّة' in e['h2'] and 'بلا' not in e['h2']:
            rule = 'r02'
        elif 'بلا غُنَّة' in e['h2'] and not e['h3']:
            rule = 'r03'
        elif 'الإقلاب' in e['h1'] and e['h3'] == 'الأمثلة':
            rule = 'r04'
        elif 'الإخفاء' in e['h1'] and 'علامتُه' in e['h3'] and e['row']:
            rule = 'r05'
        else:
            continue
        hl = [c for c, _, ins in base_letters(e['pattern']) if ins and c != ' ']
        if len(hl) < 2:  # highlight must cover the noon/tanween and the next letter
            continue
        if e['ref'] in ('80:38', '80:39'):  # tanween across two verses
            continue
        out.append((e['ref'], e['pattern'], rule, noon_case(e['pattern'])))
        del h
    return out


def fill(rule, case):
    if rule in ('r13', 'r14'):
        return dict(ALLAH[case])
    t = T[rule]
    if rule in ('r01', 'r02', 'r03', 'r04', 'r05'):
        kind, letter = case
        k = KIND[kind]
        name, verb, prefix = k['ar']
        return {
            'ar': t['ar'].format(K=name, V=verb, P=prefix, L=letter),
            'ckb': t['ckb'].format(K=k['ckb'], L=letter),
            'en': t['en'].format(K=k['en'], L=letter),
            'id': t['id'].format(K=k['id'], L=letter),
        }
    return {lang: t[lang].format(L=case or '') for lang in ('ar', 'ckb', 'en', 'id')}


def main():
    quiz = json.load(open(QUIZ, encoding='utf-8'))
    rules = {r['id']: r for r in json.load(open(RULES, encoding='utf-8'))['rules']}
    manual = [q for q in quiz['questions'] if int(q['id'][1:]) < FIRST_ID]

    def key(ref, pattern):
        return (ref, ''.join(FOLD.get(c, c) for c, _, _ in base_letters(pattern) if c != ' '))

    used = {key(r['example']['ref'], r['example']['pattern']) for r in rules.values()}
    used |= {key(q['example']['ref'], q['example']['pattern']) for q in manual if q.get('example')}

    items = noon_examples() + PICKED
    topic_of = {rid: r['topic'] for rid, r in rules.items()}
    out, n = [], FIRST_ID
    for ref, pattern, rule, case in items:
        k = key(ref, pattern)
        if k in used:
            continue
        used.add(k)
        rng = random.Random(f'{ref}|{pattern}')
        pool = [r for r in POOL[rule] if r != rule]
        options = [rule] + rng.sample(pool, 3)
        out.append({
            'id': f'q{n}',
            'type': 'identify',
            'topic': topic_of[rule],
            'example': {'ref': ref, 'pattern': pattern},
            'options': options,
            'answer': rule,
            'explanation': fill(rule, case),
            'review': {'status': 'draft'},
            'generated': 'tools/gen_identify_questions.py',
        })
        n += 1
    quiz['questions'] = manual + out
    with open(QUIZ, 'w', encoding='utf-8') as f:
        json.dump(quiz, f, ensure_ascii=False, indent=1)
        f.write('\n')
    by_rule = {}
    for q in out:
        by_rule[q['answer']] = by_rule.get(q['answer'], 0) + 1
    print(f'{len(out)} drafted questions:', dict(sorted(by_rule.items())))


if __name__ == '__main__':
    main()
