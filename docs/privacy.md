# Privacy statement (for the store listings and the app's About page)

Verified against the code on 2026-11-13: the release Android manifest has no INTERNET permission (it exists only in the debug and profile manifests, for Flutter tooling); its only permissions serve the optional daily reminder — POST_NOTIFICATIONS (asked only when the learner turns the reminder on), RECEIVE_BOOT_COMPLETED (to keep the reminder after a restart) and VIBRATE (added by the notifications plugin). The app has no networking, analytics, advertising, crash-reporting or account libraries (`pubspec.yaml`: flutter_riverpod, pdfrx, path_provider, intl, flutter_local_notifications, timezone, flutter_timezone — the last three schedule the reminder on the device and make no network requests); the books, fonts and content are bundled. Re-check this list before each release.

The Kurdish text below and new translations need fluent-language review before publication.

Implementation update — 2026-11-14: favorites, recent searches, study preference, weekly learning days and quiz checkpoints are also local. Backup export uses an explicit system file save or clipboard copying, not an automatic server upload. Files saved to a cloud-backed location use the provider you choose in the system picker. The app does not erase copies saved outside its storage. Feedback/email and payment links open external services selected by the learner; no automatic study-data transfer was added.

## English

**Jawwid collects no data.** The app works fully offline and makes no network connections. It has no accounts, no advertising, no analytics and no tracking.

Jawwid has no analytics or tracking. Study data, search history, favorites and settings stay on your device. You can save a backup file or copy backup text, including notes, to a location you choose; copies outside the app remain after uninstalling. Feedback opens your email app and support links open an external payment app or website. Those services handle what you choose to send under their own privacy policies.

The app asks for one permission, and only if you turn on the optional daily reminder: permission to show notifications. The reminder is scheduled on your device; nothing is sent anywhere.

## العربية

**لا يجمع تطبيق «جَوِّد» أيَّ بيانات.** يعمل التطبيق كاملًا دون اتصال بالإنترنت ولا يتصل بأي خادم. لا حسابات فيه ولا إعلانات ولا إحصاءات ولا تتبُّع.

لا يحتوي «جَوِّد» على إحصاءات استخدام أو تتبّع. تبقى بيانات التعلم وسجل البحث والمفضلة والإعدادات على جهازك. يمكنك نسخ بياناتك، بما فيها الملاحظات، إلى الحافظة وحفظها خارج التطبيق؛ وتبقى النسخ الخارجية بعد حذف التطبيق. تفتح الملاحظات المرسلة تطبيق البريد، وتفتح روابط الدعم تطبيق دفع أو موقعًا خارجيًا. تتعامل تلك الخدمات مع ما تختار إرساله وفق سياساتها الخاصة.

لا يطلب التطبيق إلا إذنًا واحدًا، وفقط إذا فعّلتَ التذكير اليومي الاختياري: إذن عرض الإشعارات. ويُجدوَل التذكير على جهازك ولا يُرسل شيء إلى أي جهة.

## کوردی (سۆرانی)

**ئەپی «جَوِّد» هیچ زانیارییەک کۆ ناکاتەوە.** ئەپەکە بە تەواوی بەبێ ئینتەرنێت کار دەکات و پەیوەندی بە هیچ ڕاژەکارێکەوە ناکات. هیچ هەژمار، ڕیکلام، ئامار یان بەدواداچوونێکی تێدا نییە.

ڕێکخستنەکانت، شوێنی خوێندنەوەت، نیشانەکان، تێبینییەکان، پێشکەوتن و ئەنجامی ڕاهێنانەکانت تەنها لەسەر ئامێرەکەت، لە شوێنی تایبەتی ئەپەکەدا، پاشەکەوت دەکرێن و بۆ هیچ لایەک نانێردرێن. بە سڕینەوەی ئەپەکە دەسڕدرێنەوە.

ئەپەکە تەنها داوای یەک مۆڵەت دەکات، ئەویش تەنها ئەگەر بیرخستنەوەی ڕۆژانەی ئارەزوومەندانە چالاک بکەیت: مۆڵەتی پیشاندانی ئاگادارکردنەوە. بیرخستنەوەکە لەسەر ئامێرەکەت ڕێکدەخرێت و هیچ شتێک بۆ هیچ لایەک نانێردرێت.

## Bahasa Indonesia

**Jawwid tidak mengumpulkan data apa pun.** Aplikasi ini berjalan sepenuhnya secara luring dan tidak terhubung ke server mana pun. Tidak ada akun, iklan, analitik, maupun pelacakan.

Jawwid tidak memiliki analitik atau pelacakan. Data belajar, riwayat pencarian, favorit, dan pengaturan tetap di perangkat Anda. Anda dapat menyalin cadangan, termasuk catatan, ke papan klip dan menyimpannya di luar aplikasi; salinan tersebut tetap ada setelah aplikasi dihapus. Umpan balik membuka aplikasi email dan tautan dukungan membuka aplikasi pembayaran atau situs eksternal. Layanan tersebut menangani informasi yang Anda pilih untuk dikirim menurut kebijakan privasinya sendiri.

Aplikasi ini hanya meminta satu izin, dan hanya jika Anda menyalakan pengingat harian opsional: izin untuk menampilkan notifikasi. Pengingat dijadwalkan di perangkat Anda; tidak ada yang dikirim ke mana pun.
