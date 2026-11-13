// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get navHome => 'Beranda';

  @override
  String get navLessons => 'Pelajaran';

  @override
  String get navRules => 'Kaidah';

  @override
  String get navPractice => 'Latihan';

  @override
  String get navMore => 'Lainnya';

  @override
  String get actionCancel => 'Batal';

  @override
  String get actionDelete => 'Hapus';

  @override
  String get actionDone => 'Selesai';

  @override
  String get actionGo => 'Buka';

  @override
  String get actionOk => 'OK';

  @override
  String get actionSave => 'Simpan';

  @override
  String get editionArabic => 'Edisi bahasa Arab';

  @override
  String get editionKurdish => 'Edisi bahasa Kurdi';

  @override
  String get editionEnglish => 'Edisi bahasa Inggris';

  @override
  String get editionIndonesian => 'Edisi bahasa Indonesia';

  @override
  String pageLabel(String number) {
    return 'Halaman $number';
  }

  @override
  String pageRangeLabel(String start, String end) {
    return 'Halaman $start–$end';
  }

  @override
  String get pageCover => 'Sampul';

  @override
  String get pageBackCover => 'Sampul belakang';

  @override
  String get pageUnnumbered => 'Halaman tanpa nomor';

  @override
  String get homeContinueTitle => 'Lanjutkan membaca';

  @override
  String get homeStartTitle => 'Mulai dari pelajaran pertama';

  @override
  String homeContinueOtherEdition(String current, String other) {
    return 'Topik ini tidak ada di $current, jadi dibuka di $other.';
  }

  @override
  String get homeCurriculum => 'Indeks topik tajwid';

  @override
  String homeCurriculumSummary(String topics, String groups) {
    return '$topics topik dalam $groups unit';
  }

  @override
  String get homeProgressTitle => 'Kemajuanmu';

  @override
  String homeLessonsDone(String done, String total) {
    return '$done dari $total selesai';
  }

  @override
  String homePracticeAccuracy(String percent) {
    return '$percent% benar';
  }

  @override
  String get homePracticeTeaser => 'Uji dirimu dalam dua menit';

  @override
  String homeUnitLabel(String number) {
    return 'Unit $number';
  }

  @override
  String get homeSeeAll => 'Semua topik';

  @override
  String get homeRecentBookmarks => 'Penanda terbaru';

  @override
  String get homeReviewSuggestion => 'Saran untuk diulang';

  @override
  String reviewMissed(String correct, String answered, String topic) {
    return 'Anda menjawab benar $correct dari $answered di «$topic». Ulangi pelajarannya, lalu coba lagi.';
  }

  @override
  String reviewTryPractice(String topic) {
    return 'Anda sudah membaca «$topic». Coba soal latihannya untuk memantapkan.';
  }

  @override
  String reviewFinishLesson(String topic) {
    return 'Anda sudah memulai «$topic». Selesaikan dan tandai selesai bila sudah.';
  }

  @override
  String reviewNextLesson(String topic) {
    return 'Pelajaran berikutnya: «$topic».';
  }

  @override
  String get reviewOpenLesson => 'Buka pelajaran';

  @override
  String streakDays(String count) {
    return 'Hari belajar berturut-turut: $count';
  }

  @override
  String get streakNone => 'Setiap hari adalah kesempatan baru untuk belajar.';

  @override
  String get curriculumTitle => 'Topik tajwid';

  @override
  String curriculumIntro(String count) {
    return '$count topik sesuai urutan buku. Topik mana pun dapat langsung dibuka.';
  }

  @override
  String curriculumProgress(String read, String completed, String total) {
    return 'Dimulai: $read · Selesai: $completed · dari $total';
  }

  @override
  String get curriculumGroupsNote =>
      'Pembagian unit hanya alat bantu aplikasi dan bukan bagian dari buku.';

  @override
  String get statusNotStarted => 'Belum dimulai';

  @override
  String get statusRead => 'Sudah dibaca';

  @override
  String get statusCompleted => 'Selesai';

  @override
  String topicNumber(String number) {
    return 'Topik $number';
  }

  @override
  String get topicInTheBook => 'Di dalam buku';

  @override
  String topicReadHint(String edition) {
    return 'Halaman asli $edition ditampilkan apa adanya.';
  }

  @override
  String get topicOpenPages => 'Buka halaman pelajaran';

  @override
  String get topicUnavailableTitle => 'Tidak ada di edisi ini';

  @override
  String topicUnavailableInEdition(String topic, String edition) {
    return 'Topik «$topic» tidak terdapat di $edition. Anda dapat membacanya di edisi lain.';
  }

  @override
  String topicNotInEditionShort(String edition) {
    return 'Tidak ada di $edition';
  }

  @override
  String get topicPartialShort => 'sebagian';

  @override
  String get topicAvailableIn => 'Tersedia di:';

  @override
  String get topicMarkCompleted => 'Tandai selesai';

  @override
  String get topicOtherEditions => 'Topik ini di edisi lain';

  @override
  String get topicRelatedRules => 'Kartu kaidah';

  @override
  String get topicPractice => 'Latihan';

  @override
  String get readerLoading => 'Membuka buku…';

  @override
  String get readerError =>
      'Edisi ini tidak dapat dibuka. Pasang ulang aplikasi jika masalah berlanjut.';

  @override
  String readerPageSemantics(String edition, String page) {
    return 'Halaman buku: $edition, $page. Ketuk untuk menampilkan atau menyembunyikan kontrol.';
  }

  @override
  String readerPositionOf(String current, String total) {
    return '$current dari $total';
  }

  @override
  String get readerAddBookmark => 'Tambah penanda';

  @override
  String get readerRemoveBookmark => 'Hapus penanda';

  @override
  String get bookmarkAdded => 'Penanda ditambahkan';

  @override
  String get bookmarkRemoved => 'Penanda dihapus';

  @override
  String get readerNotes => 'Catatan halaman';

  @override
  String get readerMore => 'Opsi lain';

  @override
  String get readerGoToPage => 'Pergi ke halaman';

  @override
  String get goToPageFieldLabel => 'Nomor halaman tercetak';

  @override
  String goToPageInvalid(String min, String max) {
    return 'Masukkan angka antara $min dan $max.';
  }

  @override
  String get readerChooseEdition => 'Baca di edisi lain';

  @override
  String get lessonPrevSection => 'Bagian sebelumnya';

  @override
  String get lessonNextSection => 'Bagian berikutnya';

  @override
  String get lessonSourceInfo => 'Tentang teks ini';

  @override
  String get settingsAppearance => 'Tampilan';

  @override
  String get themeSystem => 'Otomatis';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get settingsTextSize => 'Ukuran teks pelajaran';

  @override
  String get textSmaller => 'Perkecil teks';

  @override
  String get textLarger => 'Perbesar teks';

  @override
  String get readerAppearance => 'Tampilan membaca';

  @override
  String get readerThemeLight => 'Terang';

  @override
  String get readerThemeSepia => 'Sepia';

  @override
  String get readerThemeNight => 'Malam';

  @override
  String get readerDimPages => 'Redupkan halaman';

  @override
  String get readerDimPagesHint =>
      'Mengurangi kecerahan secara merata tanpa mengubah warna.';

  @override
  String get readerColorsNote =>
      'Warna dalam buku memiliki makna pembelajaran, sehingga halaman tidak pernah dibalik atau diwarnai ulang.';

  @override
  String get readerShowThumbnails => 'Tampilkan gambar mini halaman';

  @override
  String get readerHideThumbnails => 'Sembunyikan gambar mini halaman';

  @override
  String get readerLessonDetails => 'Detail pelajaran';

  @override
  String notesForPage(String page) {
    return 'Catatan $page';
  }

  @override
  String get notesPrivateHint =>
      'Catatan Anda hanya disimpan di perangkat ini.';

  @override
  String get notesHint => 'Tulis catatan…';

  @override
  String get notesAdd => 'Tambah catatan';

  @override
  String get notesEdit => 'Ubah catatan';

  @override
  String get notesOpenPage => 'Buka halaman';

  @override
  String get notesEmpty => 'Belum ada catatan. Tambahkan dari layar membaca.';

  @override
  String get notesTab => 'Catatan';

  @override
  String get bookmarksTab => 'Penanda';

  @override
  String get bookmarksEmpty =>
      'Belum ada penanda. Tambahkan dari layar membaca.';

  @override
  String get bookmarksAndNotes => 'Penanda dan catatan';

  @override
  String get rulesTitle => 'Panduan kaidah';

  @override
  String get rulesIntro =>
      'Kartu ringkas untuk kaidah yang dijelaskan dalam buku, masing-masing dengan contoh terverifikasi dan tautan ke pelajarannya.';

  @override
  String get rulesAwaitingReview =>
      'Kartu kaidah sedang ditinjau ahli dan akan tersedia setelah disetujui. Buku lengkap tersedia di Pelajaran.';

  @override
  String get ruleCardTitle => 'Kartu kaidah';

  @override
  String ruleFromLesson(String topic) {
    return 'Dari pelajaran: $topic';
  }

  @override
  String get ruleDefinition => 'Definisi';

  @override
  String ruleSourceLine(String edition, String page) {
    return 'Dari $edition, halaman $page';
  }

  @override
  String ruleNotInEdition(String edition) {
    return '$edition tidak membahas bagian ini dalam teks tersendiri; ringkasan di atas ditulis untuk aplikasi.';
  }

  @override
  String get ruleArabicSource => 'Teks edisi bahasa Arab:';

  @override
  String get ruleLetters => 'Huruf';

  @override
  String get ruleAllLettersExcept => 'Semua huruf kecuali:';

  @override
  String get ruleExample => 'Contoh';

  @override
  String get ruleHighlightedLetters => 'Huruf yang ditandai';

  @override
  String get ruleInTheBooks => 'Di dalam buku';

  @override
  String get ruleOpenLesson => 'Pelajaran';

  @override
  String get rulePractice => 'Berlatih';

  @override
  String quranExcerptFrom(String reference) {
    return 'Kutipan dari $reference';
  }

  @override
  String quranExcerptSemantics(
    String text,
    String highlighted,
    String reference,
  ) {
    return 'Contoh Al-Qur’an: $text. Huruf yang ditandai: $highlighted. $reference';
  }

  @override
  String get previewBadge => 'Pratinjau pengembangan';

  @override
  String get previewExplanation =>
      'Materi tambahan ini belum ditinjau ahli dan hanya muncul di versi pengembangan.';

  @override
  String get makharijTitle => 'Makharijul huruf';

  @override
  String get makharijSubtitle => 'Diagram dengan tujuh belas makhraj';

  @override
  String makharijIntro(String areas, String points) {
    return 'Buku ini menyajikan $areas makhraj umum dan $points makhraj khusus. Pilih makhraj untuk melihat letak dan penjelasannya.';
  }

  @override
  String get makharijDiagramSource =>
      'Ilustrasi dari buku itu sendiri. Cubit untuk memperbesar.';

  @override
  String get makharijOpenDiagramPage => 'Halaman diagram';

  @override
  String get makharijAllPoints => 'Semua makhraj';

  @override
  String get makharijAllAreas => 'Semua';

  @override
  String get makharijNotMarked =>
      'Tempat ini tidak ditandai pada diagram; lihat halaman buku untuk ilustrasi rincinya.';

  @override
  String makharijReadInBook(String edition, String page) {
    return '$edition, halaman $page';
  }

  @override
  String get practiceTitle => 'Latihan';

  @override
  String get practiceIntro =>
      'Soal tambahan yang ditulis untuk aplikasi. Contohnya diambil dari tabel buku dan sudah diverifikasi.';

  @override
  String get practiceAwaitingReview =>
      'Soal latihan sedang ditinjau dan akan tersedia setelah disetujui.';

  @override
  String get practiceOverall => 'Hasil Anda';

  @override
  String practiceNotTried(String count) {
    return '$count soal — belum dimulai.';
  }

  @override
  String practicePerformance(String correct, String answered, String total) {
    return 'Benar: $correct dari $answered dijawab · total $total';
  }

  @override
  String get practiceSeparateFromReading =>
      'Kemajuan membaca dicatat terpisah dari hasil latihan.';

  @override
  String get practiceStart => 'Mulai latihan';

  @override
  String get practiceContinue => 'Lanjutkan latihan';

  @override
  String get practiceByLesson => 'Per pelajaran';

  @override
  String get practiceThisLesson => 'Latih pelajaran ini';

  @override
  String get practiceReset => 'Hapus hasil latihan';

  @override
  String get practiceResetConfirm =>
      'Hanya hasil latihan yang dihapus. Penanda, catatan, dan kemajuan membaca tetap tersimpan.';

  @override
  String quizProgress(String current, String total) {
    return 'Soal $current dari $total';
  }

  @override
  String get quizSupplementary => 'Soal tambahan, bukan dari teks buku.';

  @override
  String get quizIdentifyPrompt =>
      'Hukum apa yang berlaku pada huruf yang ditandai?';

  @override
  String get quizTrueFalsePrompt => 'Benar atau salah?';

  @override
  String get quizTrue => 'Benar';

  @override
  String get quizFalse => 'Salah';

  @override
  String quizCounts(String value) {
    return '$value harakat';
  }

  @override
  String get quizFeedbackCorrect => 'Benar';

  @override
  String get quizFeedbackIncorrect => 'Belum tepat';

  @override
  String get quizCorrectAnswer => 'jawaban benar';

  @override
  String get quizYourAnswer => 'jawaban Anda';

  @override
  String get quizReviewRule => 'Kartu kaidah';

  @override
  String get quizOpenLesson => 'Pelajaran';

  @override
  String get quizNext => 'Soal berikutnya';

  @override
  String get quizSeeResult => 'Lihat hasil';

  @override
  String get quizFinished => 'Bagus, terus berlatih';

  @override
  String quizScore(String correct, String total) {
    return '$correct dari $total benar';
  }

  @override
  String get quizFinishedHint =>
      'Soal yang terlewat akan muncul lebih dulu lain kali.';

  @override
  String get practiceQuick => 'Latihan cepat';

  @override
  String practiceQuickHint(String count) {
    return '$count soal dari semua pelajaran, dimulai dari kesalahan sebelumnya.';
  }

  @override
  String practiceMistakes(String count) {
    return 'Ulangi kesalahan saya ($count)';
  }

  @override
  String get lessonCheckTitle => 'Uji pemahamanmu';

  @override
  String lessonCheckBody(String count) {
    return '$count soal singkat tentang pelajaran ini';
  }

  @override
  String get lessonCheckStart => 'Mulai';

  @override
  String get quizLessonCompleted => 'Bagus! Pelajaran ditandai selesai.';

  @override
  String get quizPracticeAgain => 'Satu putaran lagi';

  @override
  String get quizMissedHeading => 'Untuk diulang';

  @override
  String get quizPerfect => 'Semua benar. Luar biasa!';

  @override
  String get searchTitle => 'Cari';

  @override
  String get searchHint => 'Cari topik, kaidah, dan istilah';

  @override
  String get searchCoverage =>
      'Mencari judul topik, nama kaidah, dan istilah dalam keempat bahasa. Teks halaman hanya dicari pada edisi bahasa Inggris dan Indonesia, karena teks edisi Arab dan Kurdi tidak dapat diekstrak dengan andal.';

  @override
  String get searchLessons => 'Topik';

  @override
  String get searchRules => 'Kartu kaidah';

  @override
  String searchPagesIn(String edition) {
    return 'Halaman di $edition';
  }

  @override
  String get searchPagesNote =>
      'Kata ditemukan dalam teks halaman ini; posisi tepatnya di halaman tidak ditandai.';

  @override
  String searchMatched(String text) {
    return 'Cocok: $text';
  }

  @override
  String searchNoResults(String query) {
    return 'Tidak ada hasil untuk «$query»';
  }

  @override
  String get searchNoResultsHint =>
      'Coba nama hukum atau sebagiannya, misalnya ikhfa, qalqalah, atau mad.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageHint =>
      'Antarmuka dan edisi buku berubah bersamaan. Posisi membaca disimpan per edisi, dan pelajaran saat ini dipindahkan ke padanannya.';

  @override
  String get settingsStudy => 'Belajar';

  @override
  String get settingsStreak => 'Penghitung hari berturut-turut';

  @override
  String get settingsStreakHint => 'Opsi tenang yang tampil di Beranda.';

  @override
  String get settingsHaptics => 'Getaran sentuh';

  @override
  String get settingsHapticsHint =>
      'Getaran ringan saat berpindah bagian, menandai pelajaran selesai, atau menjawab soal.';

  @override
  String get settingsReminder => 'Pengingat harian';

  @override
  String get settingsReminderHint =>
      'Satu notifikasi setiap hari pada waktu yang Anda pilih. Dijadwalkan di perangkat Anda; tidak ada yang dikirim ke mana pun.';

  @override
  String get settingsReminderTime => 'Waktu pengingat';

  @override
  String get settingsReminderDenied =>
      'Notifikasi tidak diizinkan. Anda dapat mengizinkannya di pengaturan perangkat, lalu menyalakan pengingat.';

  @override
  String get reminderBody =>
      'Waktunya belajar tajwid hari ini. Lanjutkan pelajaran Anda dari tempat terakhir.';

  @override
  String get reminderChannel => 'Pengingat harian';

  @override
  String get bookTitle => 'Buku lengkap';

  @override
  String bookSubtitle(String edition) {
    return 'Jelajahi semua halaman $edition sebagai rujukan';
  }

  @override
  String get settingsOffline =>
      'Keempat buku dan semua fitur berfungsi tanpa internet. Tidak perlu akun.';

  @override
  String get lessonRead => 'Baca pelajaran';

  @override
  String get lessonOriginalPages => 'Halaman asli';

  @override
  String lessonFromPage(String page) {
    return 'Dari halaman $page';
  }

  @override
  String get lessonViewInBook => 'Lihat di buku';

  @override
  String lessonSourceNote(String edition) {
    return 'Teks ini diambil dari halaman $edition. Halaman asli tetap menjadi rujukan.';
  }

  @override
  String get lessonUnderReview =>
      'Salinan ini belum ditinjau; jika ada perbedaan, halaman asli yang menjadi acuan.';

  @override
  String get lessonFigure => 'Ilustrasi dari buku; ketuk untuk memperbesar';

  @override
  String get lessonFullVerse => 'Ayat lengkap';

  @override
  String get lessonQuranTapHint => 'Ketuk untuk melihat ayat lengkap';

  @override
  String get lessonContents => 'Isi pelajaran';

  @override
  String get lessonEnd => 'Akhir pelajaran';

  @override
  String get lessonPrevious => 'Pelajaran sebelumnya';

  @override
  String get lessonNext => 'Pelajaran berikutnya';

  @override
  String get searchInLessons => 'Di teks pelajaran';

  @override
  String get searchCoverageWithLessons =>
      'Mencari teks pelajaran, judul topik, nama kaidah, dan istilah dalam keempat bahasa, serta teks halaman edisi bahasa Inggris dan Indonesia.';

  @override
  String get aboutTitle => 'Tentang';

  @override
  String get aboutBody =>
      'Pendamping belajar tajwid yang dibangun di sekitar buku “Tajwid Ringkas – Level 2”. Buku aslinya ditampilkan apa adanya, dilengkapi alat untuk menjelajah, mengulang, dan berlatih.';

  @override
  String get aboutBooks => 'Buku';

  @override
  String aboutAuthor(String name) {
    return 'Penulis: $name';
  }

  @override
  String aboutTranslator(String name) {
    return 'Penerjemah: $name';
  }

  @override
  String get aboutDistribution =>
      'Buku ini menyatakan bahwa hak sebar terbuka bagi siapa saja selama tidak ada penambahan atau pengurangan.';

  @override
  String get aboutUnchanged =>
      'Halaman ditampilkan tanpa penambahan atau pengurangan. Salinan yang dibundel hanya dipadatkan secara struktural, dan tampilannya telah diverifikasi identik piksel demi piksel dengan aslinya.';

  @override
  String get aboutPrivacyTitle => 'Privasi';

  @override
  String get aboutPrivacy =>
      'Aplikasi ini tidak mengumpulkan data dan tidak terhubung ke internet. Pengaturan, kemajuan, dan catatan Anda hanya tersimpan di perangkat Anda dan terhapus bersama aplikasi.';

  @override
  String get aboutQuranText => 'Teks Al-Qur’an';

  @override
  String get aboutTanzil =>
      'Contoh Al-Qur’an pada pelajaran, kartu kaidah, dan latihan disalin apa adanya dari teks Tanzil Project (rasm Utsmani, versi 1.1, tanzil.net), dan rujukannya diperiksa secara otomatis.';

  @override
  String get aboutSupplementary => 'Materi tambahan';

  @override
  String get aboutSupplementaryBody =>
      'Teks pelajaran, kartu kaidah, soal latihan, dan penjelajah makhraj disusun dari teks buku dan ditinjau sebelum disetujui untuk rilis.';

  @override
  String get aboutFonts => 'Huruf';

  @override
  String get aboutFontsBody =>
      'Noto Naskh Arabic, Noto Sans Arabic, Amiri, Amiri Quran, Literata, dan Inter, semuanya berlisensi SIL Open Font License 1.1. Huruf asli buku tidak didistribusikan bersama aplikasi.';

  @override
  String get aboutLicenses => 'Lisensi';

  @override
  String aboutContentVersion(String version) {
    return 'Versi konten: $version';
  }
}
