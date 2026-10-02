import 'package:flutter/material.dart';

import '../models/daily_note.dart';
import '../services/local_demo_auth_service.dart';
import '../services/local_storage_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    required this.authService,
    required this.localStorage,
  });

  final LocalDemoAuthService authService;
  final LocalStorageService localStorage;

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  // The shell owns the selected tab. IndexedStack keeps inactive screens alive,
  // so local Today entries and the History search do not reset on every tap.
  int _selectedIndex = 0;
  DateTime _selectedJournalDate = dateOnly(DateTime.now());
  int _journalRevision = 0;
  final ValueNotifier<int> _dailyGoal = ValueNotifier(2000);

  @override
  void dispose() {
    _dailyGoal.dispose();
    super.dispose();
  }

  void _openSavedDate(DateTime date) {
    setState(() {
      _selectedJournalDate = dateOnly(date);
      _selectedIndex = 0;
    });
  }

  void _selectTab(int index) {
    setState(() {
      if (index == 0) _selectedJournalDate = dateOnly(DateTime.now());
      _selectedIndex = index;
    });
  }

  void _markJournalSaved() {
    setState(() => _journalRevision++);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        key: ValueKey(formatDateKey(_selectedJournalDate)),
        localStorageService: widget.localStorage,
        dailyGoalNotifier: _dailyGoal,
        journalDate: _selectedJournalDate,
        onSaved: _markJournalSaved,
      ),
      HistoryScreen(
        key: ValueKey(_journalRevision),
        localStorageService: widget.localStorage,
        onOpenDate: _openSavedDate,
      ),
      SettingsScreen(
        authService: widget.authService,
        localStorageService: widget.localStorage,
        dailyGoalNotifier: _dailyGoal,
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.note_alt_outlined),
              selectedIcon: Icon(Icons.note_alt_rounded),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
