import 'package:flutter/material.dart';

import '../models/daily_note.dart';
import '../services/local_storage_service.dart';
import '../theme/caly_spacing.dart';
import '../widgets/large_title_header.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.localStorageService,
    required this.onOpenDate,
  });

  final LocalStorageService localStorageService;
  final ValueChanged<DateTime> onOpenDate;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  List<DailyNote> _savedNotes = const [];
  String _query = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedNotes() async {
    try {
      final notes = await widget.localStorageService.loadAllDailyNotes();
      notes.sort((a, b) => b.date.compareTo(a.date));
      if (!mounted) return;
      setState(() {
        _savedNotes = notes;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load saved journal days.';
      });
    }
  }

  List<DailyNote> get _filteredNotes {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return _savedNotes;

    return _savedNotes
        .where((note) {
          final foodText = note.entries
              .expand((entry) => [entry.originalText, entry.foodName])
              .join(' ');
          final haystack =
              '${_formatDate(note.date)} ${note.dateKey} $foodText '
                      '${note.totalCalories}'
                  .toLowerCase();
          return haystack.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int _daysAgo(DateTime date) {
    return dateOnly(DateTime.now()).difference(dateOnly(date)).inDays;
  }

  String _dateTitle(DateTime date) {
    return switch (_daysAgo(date)) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => _formatDate(date),
    };
  }

  String _groupLabel(DateTime date) {
    final days = _daysAgo(date);
    if (days <= 1) return 'RECENT';
    if (days <= 7) return 'PREVIOUS 7 DAYS';
    return 'OLDER';
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  String _foodSummary(DailyNote note) {
    if (note.entries.isEmpty) return 'No food entries';
    return note.entries.map((entry) => entry.originalText).join(', ');
  }

  List<Widget> _buildNoteList(BuildContext context, List<DailyNote> notes) {
    final theme = Theme.of(context);
    final widgets = <Widget>[];
    String? previousGroup;

    for (final note in notes) {
      final group = _groupLabel(note.date);
      if (group != previousGroup) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: sm));
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: xs),
            child: Text(
              group,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
        previousGroup = group;
      }

      widgets.add(
        Material(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('history-note-${note.dateKey}'),
            onTap: () => widget.onOpenDate(note.date),
            child: Padding(
              padding: const EdgeInsets.all(sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dateTitle(note.date),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _foodSummary(note),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: sm),
                  Text(
                    '${_formatNumber(note.totalCalories)} kcal',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: xs));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = _filteredNotes;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadSavedNotes,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(md, md, md, lg),
          children: [
            const LargeTitleHeader(title: 'History'),
            const SizedBox(height: sm),
            TextField(
              key: const Key('history-search'),
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search food notes',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: md),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: xl),
                child: Center(
                  child: CircularProgressIndicator(key: Key('history-loading')),
                ),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: lg),
                child: Column(
                  children: [
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    IconButton(
                      onPressed: _loadSavedNotes,
                      tooltip: 'Retry',
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              )
            else if (notes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: xl),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/caly_mascot.png',
                      width: 112,
                      height: 112,
                    ),
                    const SizedBox(height: sm),
                    Text(
                      _query.trim().isEmpty
                          ? 'No saved food notes yet.'
                          : 'No notes match your search.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._buildNoteList(context, notes),
          ],
        ),
      ),
    );
  }
}
