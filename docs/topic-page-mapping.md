# Verified topic / page mapping — Level 2

Source of truth: `assets/content/curriculum.json` (this file is generated from it).

**How it was verified.** Every page of the four PDFs was rendered and inspected; each topic start was matched to the section heading printed on the page. The 30-topic list and its order come from the printed topic list on page 4 of the Arabic and Kurdish editions (the Indonesian page 4 list has 28 entries, see notes). English/Indonesian start pages were cross-checked against the text layer. Ranges are automatically tested in `test/content/content_test.dart`.

**Page numbers.** All values are *physical PDF page indices* (1-based). In all four editions the printed page number equals the physical index on every numbered page, with two exceptions found during transcription: **AR physical page 36** (the characteristics table) visibly prints **٤٠** — a stray number carried by the inserted table — and **CKB physical page 42** shows no number because its table covers the footer. These are recorded as `numbering.printedOverrides` in `editions.json`; the app shows what is printed and "go to page" resolves by position. Unnumbered pages: AR 1–2, 100–102 · CKB 1–2, 111–112 · EN 1–2, 108–109 · ID 1–2, 111–112. The app keeps the two concepts separate (`Edition.printedNumberOf` / `physicalForPrinted`) so a future edition with an offset only needs `numbering.offset` changed.

| Pages per edition | AR | CKB | EN | ID |
|---|---|---|---|---|
| Physical pages | 102 | 112 | 109 | 112 |
| Introduction | 3 | 3 | 3 | 3 |
| Printed topic list | 4 | 4 | — | 4 |
| References | 99 | 110 | 107 | 110 |

## Topics

| # | Arabic title (AR p.4) | Group (app aid) | AR | CKB | EN | ID |
|---|---|---|---|---|---|---|
| 1 | تعريف علم التجويد | g1 | 5 | 5–6 | 4–5 | 5–6 |
| 2 | اللَّحنُ في تلاوةِ القرآنِ الكريم | g1 | 6 | 7–8 | 6–7 | 7–8 |
| 3 | مراتبُ التلاوة (سُرعاتُ القراءة) | g1 | 7 | 9 | 8 | 9 |
| 4 | الاستعاذة | g2 | 8–10 | 10–13 | 9–12 | 10–13 |
| 5 | البسملة | g2 | 11–12 | 14–15 | 13–14 | 14–15 |
| 6 | مخارجُ الحروف | g3 | 13–23 | 16–26 | 15–24 | 16–25 |
| 7 | ألقابُ الحروف | g3 | 24 | 27 | **absent** | **absent** |
| 8 | صفاتُ الحروف | g3 | 25–36 | 28–42 | 25–36 | 26–37 |
| 9 | أبرزُ الأخطاءِ عند نطقِ حروفِ الهجاء | g3 | 37–40 | 43–46 | 37–40 | 38–41 |
| 10 | أحكامُ النُّونِ السَّاكِنةِ والتَّنوين | g4 | 41–47 | 47–55 | 41–49 | 42–50 |
| 11 | أحكامُ الميمِ السَّاكِنة | g4 | 48–49 | 56–57 | 50–51 | 51–52 |
| 12 | النُّونُ والميمُ المُشدَّدتين | g4 | 50 | 58 | 52 | 53 |
| 13 | مَراتِبُ الغُنَن | g4 | 51 | 59 | 53 | 54 |
| 14 | التَّفخيمُ والتَّرقيق | g5 | 52–57 | 60–66 | 54–59 *(partial)* | 55–62 |
| 15 | المدُّ والقصر | g5 | 58–66 | 67–75 | 60–70 | 63–72 |
| 16 | أقوى المُدودِ والعملُ بقاعدةِ أقوى السَّببين | g5 | 67 | 76 | 71–72 | 73–74 |
| 17 | الإدغامُ ومَبحثُ عِلاقاتِ الحُروف | g6 | 68–72 | 77–82 | 73–78 | 75–80 |
| 18 | أحكامُ اللَّامِ السَّاكِنة | g6 | 73–74 | 83–84 | 79–81 | 81–83 |
| 19 | هَمزَتا القَطعِ والوَصل | g6 | 75–78 | 85–88 | 82–85 | 84–87 |
| 20 | الوَقف | g7 | 79–83 | 89–93 | 86–90 | 88–92 |
| 21 | الابتِداء | g7 | 84 | 94 | 91 | 93 |
| 22 | السَّكت | g7 | 85 | 95 | 86 *(partial)* | 94 |
| 23 | الألِفاتُ السَّبع | g7 | 86 | 96 | 92 | 95 |
| 24 | النَّبرُ في القرآنِ الكريم | g7 | 87 | 97 | 93 | 96 |
| 25 | ما يُراعى لحفص | g7 | 88–89 | 98–99 | 94–95 | 97–98 |
| 26 | الرَّومُ والإشمامُ والسُّكونُ المَحض | g7 | 90–95 | 100–105 | 96–101 | 99–104 |
| 27 | حكمُ التقاءِ السَّاكِنين | g7 | 96 | 106–107 | 102–103 | 105–106 |
| 28 | سُجودُ التِّلاوة | g8 | 97 | 108 | 104 | 107 |
| 29 | إسنادُ روايةِ حفص | g8 | 98 | 108 | 105 | 108 |
| 30 | أسماءُ القُرَّاءِ العشرةِ ورواتِهم | g8 | 98 | 109 | 106 | 109 |

## Titles per edition

| # | Kurdish (CKB p.4) | English (page heading) | Indonesian (ID p.4 / heading) |
|---|---|---|---|
| 1 | پێناسەی زانستی تەجوید | Definition of the Science of Tajweed | Definisi Ilmu Tajwid |
| 2 | هەڵەکردن لە خوێندنەوەی قورئاندا | Lahn in the Recitation of the Qur'an | Lahn dalam Membaca Al-Qur'an |
| 3 | پلەکانی خوێندنەوە لە ڕووی خێراییەوە | Ranks of Recitation (Speeds of Recitation) | Tingkatan Membaca Al-Qur'an |
| 4 | ئیستیعازە (پەناگرتن) | Isti'adhah (Seeking Refuge) | Isti'adzah (Memohon Perlindungan) |
| 5 | بەسمەلە | Basmalah | Basmallah |
| 6 | دەرچەی پیتەکانی زمانی عەرەبی | Articulation Points of Letters | Makharijul Huruf |
| 7 | نازناوی پیتەکان | Titles of the Letters (Alqab al-Huruf) *(authored — no source heading)* | Julukan Huruf (Alqab al-Huruf) *(authored — no source heading)* |
| 8 | سیفاتی پیتەکان | Characteristics of Letters | Sifat-Sifat Huruf |
| 9 | دیارترینی ئەو هەڵانەی کە دەکرێن لەکاتی دەربڕینی پیتەکاندا | The Most Prominent Mistakes When Pronouncing the Letters | Kesalahan-Kesalahan yang Sering Terjadi dalam Pengucapan Huruf Hijaiyyah |
| 10 | ئەحکامەکانی نونی ساکن و تەنوین | Rules of Noon Sakinah and Tanween | Hukum Nun Sukun dan Tanwin |
| 11 | حوکمەکانی میمی زەنەدار | Rules of Meem Sakinah | Hukum Mim Sukun |
| 12 | نون و میمی توندکراو | Noon and Meem Mushaddad | Nun dan Mim Bertasydid |
| 13 | ماوەی مینگەکان | Timings of Ghunnah | Tingkatan Ghunnah |
| 14 | قەڵەوکردن و ناسکردن | Heaviness and Lightness (Tafkheem and Tarqeeq) | Tebal dan Tipis |
| 15 | درێژکردنەوە و کورتکردنەوە | Madd and Qasr (Lengthening and Shortening) | Mad dan Qashar |
| 16 | بەهێزترینی مەدەکان و کارکردن بە ڕێسای بەهێزترینی هۆکار | The Strongest Madd and the Rule of the Stronger of Two Causes | Tingkatan Kekuatan Mad dan Penerapannya dengan Kaidah Sebab Terkuat |
| 17 | ئیدغام و باسی پەیوەندی پیتەکان | Idgham and the Relationships Between Letters | Idgham dalam Al-Qur'an dan Pembahasan Hubungan Huruf |
| 18 | ئەحکامەکانی لامی ساکن | Rules of the Non-Voweled Laam | Hukum Lam Sukun |
| 19 | هەمزەی بچڕاو و هەمزەی گەیاندن | Hamzat Qat' and Hamzat Wasl | Hamzah Qatha' dan Hamzah Washal |
| 20 | وەستان | Waqf (Stop) | Al-Waqf (Berhenti) |
| 21 | دەست پێکردن | Ibtida' (Start) | Ibtida' (Permulaan) |
| 22 | سەکت | Sakt (Slight Pause) | Sakt |
| 23 | حەوت ئەلیفەکە | The Seven Alifs | Alif Tujuh |
| 24 | نەبر لە قورئانی پیرۆزدا | Nabr (Accent) in the Qur'an | Nabr (Penekanan) dalam Al-Qur'an |
| 25 | ئەوەی ڕەچاو دەکرێت لە ریوایەتی حەفص | What Must Be Considered for Hafs | Hal-Hal yang Diperhatikan untuk Riwayat Hafsh |
| 26 | ڕەوم و ئیشمام و سکونی تەواو | Rawm, Ishmam and Sukoon Mahd | Raum, Isymam, dan Sukun Murni |
| 27 | حوکمی بەیەکگەیشتنی دوو ساکن | The Rule of Meeting Two Sakin Letters | Hukum Pertemuan Dua Huruf Sukun |
| 28 | سوجدەی تیلاوە | Sujood at-Tilawah (Prostration of Recitation) | Sujud Tilawah |
| 29 | سەنەدی ریوایەتی حەفص | The Chain of Transmission of the Narration of Hafs | Sanad Riwayat Hafs |
| 30 | ناوی هەر دە قورئان خوێنەکە و گێڕەرەوەکانیان | Names of the Ten Reciters and Their Narrators | Nama 10 Ulama Qira'at dan Perawinya |

## Findings that differ from the earlier report

* **30 topics confirmed** (AR and CKB topic lists). The **8 groups are not in the books**; they are an app navigation aid, kept contiguous and in source order.
* **Alqab al-Huruf (topic 7)** — present in AR (p.24) and CKB (p.27); **absent** from EN and ID (no page, no table). The app says so instead of jumping elsewhere.
* **Sakt (topic 22)** — dedicated section in AR (85), CKB (95), ID (94). The **English edition has no Sakt section**; Sakt is only defined inside the Waqf/Qat'/Sakt comparison on EN p.86 (mapped as *partial*).
* **Tafkheem & Tarqeeq (topic 14)** — the English edition omits the subsections on Alif and on the Laam of the name of Allah (AR p.54, CKB pp.62–63, ID pp.58–59) — mapped as *partial*.
* **Indonesian topic list (p.4)** lists 28 entries: it omits "the strongest madd" and "the isnad of Hafs", and splits Idgham from the letter-relationships topic. The content is nevertheless present: strongest madd at ID pp.73–74, isnad at ID p.108; Idgham (75–76) and relationships (77–80) are mapped together as topic 17, following the AR/CKB list.
* **Shared pages** — AR p.98 holds both topic 29 (isnad) and 30 (ten reciters); CKB p.108 holds 28 (sujood) and 29.
* **Sub-elements missing from EN/ID** (not separate topics): the summary table of articulation points (AR p.16, CKB pp.19–20) and the per-letter characteristics table (AR p.36, CKB p.42).
* **Kurdish table typo** — the Kurdish articulation table (CKB p.20) prints "ط ذ ث" for the letters the Arabic edition gives as ظ ذ ث. The app's letter data uses ظ ذ ث; the PDF is untouched.
* **Indonesian translation difference** — ID p.22 places noon "di atas makhraj huruf lam" (above), whereas AR/CKB/EN say *below* (تحت). Kept verbatim in the Indonesian description; flagged for reviewer.

