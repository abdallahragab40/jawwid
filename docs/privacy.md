# Privacy statement (for the store listings and the app's About page)

Verified against the code on 2026-11-13: the release Android manifest has no INTERNET permission (it exists only in the debug and profile manifests, for Flutter tooling); its only permissions serve the optional daily reminder — POST_NOTIFICATIONS (asked only when the learner turns the reminder on), RECEIVE_BOOT_COMPLETED (to keep the reminder after a restart) and VIBRATE (added by the notifications plugin). The app has no networking, analytics, advertising, crash-reporting or account libraries (`pubspec.yaml`: flutter_riverpod, pdfrx, path_provider, intl, flutter_local_notifications, timezone, flutter_timezone — the last three schedule the reminder on the device and make no network requests); the books, fonts and content are bundled. Re-check this list before each release.

The Kurdish text below needs review by a fluent Sorani speaker, like the rest of the Kurdish wording.

## English

**Jawwid collects no data.** The app works fully offline and makes no network connections. It has no accounts, no advertising, no analytics and no tracking.

Your settings, reading positions, bookmarks, notes, progress and practice results are saved only on your device, in the app's private storage. They are never sent anywhere. Deleting the app deletes them.

The app asks for one permission, and only if you turn on the optional daily reminder: permission to show notifications. The reminder is scheduled on your device; nothing is sent anywhere.

## العربية

**لا يجمع تطبيق «جَوِّد» أيَّ بيانات.** يعمل التطبيق كاملًا دون اتصال بالإنترنت ولا يتصل بأي خادم. لا حسابات فيه ولا إعلانات ولا إحصاءات ولا تتبُّع.

تُحفظ إعداداتك ومواضع قراءتك وعلاماتك وملاحظاتك وتقدّمك ونتائج تدريبك على جهازك فقط، في مساحة التطبيق الخاصة، ولا تُرسَل إلى أي جهة. وتُحذف بحذف التطبيق.

لا يطلب التطبيق إلا إذنًا واحدًا، وفقط إذا فعّلتَ التذكير اليومي الاختياري: إذن عرض الإشعارات. ويُجدوَل التذكير على جهازك ولا يُرسل شيء إلى أي جهة.

## کوردی (سۆرانی)

**ئەپی «جَوِّد» هیچ زانیارییەک کۆ ناکاتەوە.** ئەپەکە بە تەواوی بەبێ ئینتەرنێت کار دەکات و پەیوەندی بە هیچ ڕاژەکارێکەوە ناکات. هیچ هەژمار، ڕیکلام، ئامار یان بەدواداچوونێکی تێدا نییە.

ڕێکخستنەکانت، شوێنی خوێندنەوەت، نیشانەکان، تێبینییەکان، پێشکەوتن و ئەنجامی ڕاهێنانەکانت تەنها لەسەر ئامێرەکەت، لە شوێنی تایبەتی ئەپەکەدا، پاشەکەوت دەکرێن و بۆ هیچ لایەک نانێردرێن. بە سڕینەوەی ئەپەکە دەسڕدرێنەوە.

ئەپەکە تەنها داوای یەک مۆڵەت دەکات، ئەویش تەنها ئەگەر بیرخستنەوەی ڕۆژانەی ئارەزوومەندانە چالاک بکەیت: مۆڵەتی پیشاندانی ئاگادارکردنەوە. بیرخستنەوەکە لەسەر ئامێرەکەت ڕێکدەخرێت و هیچ شتێک بۆ هیچ لایەک نانێردرێت.

## Bahasa Indonesia

**Jawwid tidak mengumpulkan data apa pun.** Aplikasi ini berjalan sepenuhnya secara luring dan tidak terhubung ke server mana pun. Tidak ada akun, iklan, analitik, maupun pelacakan.

Pengaturan, posisi membaca, penanda, catatan, kemajuan, dan hasil latihan Anda hanya disimpan di perangkat Anda, di penyimpanan pribadi aplikasi, dan tidak pernah dikirim ke mana pun. Semuanya terhapus jika aplikasi dihapus.

Aplikasi ini hanya meminta satu izin, dan hanya jika Anda menyalakan pengingat harian opsional: izin untuk menampilkan notifikasi. Pengingat dijadwalkan di perangkat Anda; tidak ada yang dikirim ke mana pun.
