import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/curriculum/curriculum_screen.dart';
import '../features/home/home_screen.dart';
import '../features/more/more_screen.dart';
import '../features/practice/practice_screen.dart';
import '../features/rules/rules_screen.dart';
import '../core/haptics.dart';
import '../features/study/study_state.dart';
import '../features/reader/reader_document.dart';
import '../features/reader/reader_screen.dart';
import '../l10n/generated/app_localizations.dart';

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key, this.initialTab = 0});
  final int initialTab;

  static RootShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<RootShellState>();

  @override
  ConsumerState<RootShell> createState() => RootShellState();
}

class RootShellState extends ConsumerState<RootShell> {
  late int _index = widget.initialTab;

  void selectTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Prepare only the selected language's book while the learner browses.
    // Test readers replace native PDF rendering and need no preparation.
    if (ref.watch(pageViewSubstituteProvider) == null) {
      final edition = ref.watch(languageProvider).editionId;
      final asset = ref.watch(contentProvider).editions[edition]!.asset;
      ref.watch(readerDocumentProvider(asset));
    }
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          CurriculumScreen(),
          RulesScreen(),
          PracticeScreen(),
          MoreScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i != _index) {
            ProviderScope.containerOf(
              context,
            ).read(hapticsProvider).selection();
          }
          selectTab(i);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.navLessons,
          ),
          NavigationDestination(
            icon: const Icon(Icons.style_outlined),
            selectedIcon: const Icon(Icons.style),
            label: l10n.navRules,
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_alt_outlined),
            selectedIcon: const Icon(Icons.task_alt),
            label: l10n.navPractice,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }
}

/// Tab indices, used by cross-screen links.
abstract final class Tabs {
  static const home = 0;
  static const lessons = 1;
  static const rules = 2;
  static const practice = 3;
  static const more = 4;
}
