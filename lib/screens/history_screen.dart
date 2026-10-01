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
    final prefix = dateOnly(DateTime.now()) == dateOnly(date) ? 'Today · ' : '';
    return '$prefix${weekdays[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}, ${date.year}';
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
            const LargeTitleHeader(title: 'Food History'),
            const SizedBox(height: sm),
            TextField(
              key: const Key('history-search'),
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search food or date',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: md),
            Text(
              'SAVED DAYS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: xs),
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
                    TextButton(
                      onPressed: _loadSavedNotes,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              )
            else if (notes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: xl),
                child: Text(
                  _query.trim().isEmpty
                      ? 'No saved journal days yet.'
                      : 'No saved days match your search.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final note in notes)
                InkWell(
                  key: ValueKey('history-note-${note.dateKey}'),
                  onTap: () => widget.onOpenDate(note.date),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatDate(note.date),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${_formatNumber(note.totalCalories)} kcal',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _foodSummary(note),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Divider(height: 1, color: theme.colorScheme.outline),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: xl),
            Text(
              'Tap a day to reopen and edit its note.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
