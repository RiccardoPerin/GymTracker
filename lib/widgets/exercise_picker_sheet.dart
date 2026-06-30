import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_colors.dart';

Future<String?> showExercisePicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ExercisePickerSheet(),
  );
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet();

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  List<Map<String, String>> _all = [];
  List<String> _groups = [];
  String? _selectedGroup;
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final raw = await rootBundle.loadString('assets/exercises.json');
    final list = jsonDecode(raw) as List;
    final exercises = list
        .map((e) => {'name': e['name'] as String, 'group': e['group'] as String})
        .toList();
    final groups = exercises.map((e) => e['group']!).toSet().toList()..sort();
    setState(() {
      _all = exercises;
      _groups = groups;
    });
  }

  List<Map<String, String>> get _filtered {
    return _all.where((e) {
      final matchesGroup = _selectedGroup == null || e['group'] == _selectedGroup;
      final matchesQuery =
          _query.isEmpty || e['name']!.toLowerCase().contains(_query.toLowerCase());
      return matchesGroup && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final filtered = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.dragHandle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Title ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add Exercise',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              // ── Search bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: false,
                  style: TextStyle(color: c.textPrimary),
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: TextStyle(color: c.textHint),
                    prefixIcon: Icon(Icons.search_rounded, color: c.iconDim, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                            child: Icon(Icons.close_rounded, color: c.iconDim, size: 18),
                          )
                        : null,
                    filled: true,
                    fillColor: c.inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Group filter chips ────────────────────────────────────────
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _GroupChip(
                      label: 'All',
                      selected: _selectedGroup == null,
                      onTap: () => setState(() => _selectedGroup = null),
                    ),
                    ..._groups.map((g) => _GroupChip(
                          label: g,
                          selected: _selectedGroup == g,
                          onTap: () => setState(
                            () => _selectedGroup = _selectedGroup == g ? null : g,
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Exercise list ─────────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No exercises found',
                          style: TextStyle(color: c.textDim, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final ex = filtered[i];
                          return _ExerciseTile(
                            name: ex['name']!,
                            group: ex['group']!,
                            onTap: () => Navigator.pop(context, ex['name']!),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Group chip ───────────────────────────────────────────────────────────────

class _GroupChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GroupChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : c.chipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : c.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Exercise tile ────────────────────────────────────────────────────────────

class _ExerciseTile extends StatelessWidget {
  final String name;
  final String group;
  final VoidCallback onTap;

  const _ExerciseTile({
    required this.name,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    group,
                    style: TextStyle(color: c.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.add_circle_outline_rounded, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
