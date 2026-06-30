import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_colors.dart';
import '../providers/workout_provider.dart';

Future<String?> showExercisePicker(BuildContext context) {
  final provider = context.read<WorkoutProvider>();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ExercisePickerSheet(provider: provider),
  );
}

class _ExercisePickerSheet extends StatefulWidget {
  final WorkoutProvider provider;
  const _ExercisePickerSheet({required this.provider});

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  List<_ExerciseItem> _all = [];
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
        .map((e) => _ExerciseItem(
              name: e['name'] as String,
              group: e['group'] as String,
              isCustom: false,
            ))
        .toList();

    for (final c in widget.provider.customExercises) {
      exercises.add(_ExerciseItem(
        name: c.name,
        group: c.group,
        isCustom: true,
        customId: c.id,
      ));
    }

    final groups = exercises.map((e) => e.group).toSet().toList()..sort();
    setState(() {
      _all = exercises;
      _groups = groups;
    });
  }

  List<_ExerciseItem> get _filtered {
    return _all.where((e) {
      final matchesGroup = _selectedGroup == null || e.group == _selectedGroup;
      final matchesQuery =
          _query.isEmpty || e.name.toLowerCase().contains(_query.toLowerCase());
      return matchesGroup && matchesQuery;
    }).toList();
  }

  void _showCreateDialog() async {
    final result = await showDialog<({String name, String group})>(
      context: context,
      builder: (ctx) => _CreateExerciseDialog(groups: _groups),
    );
    if (result == null || !mounted) return;
    widget.provider.addCustomExercise(result.name, result.group);
    if (mounted) Navigator.pop(context, result.name);
  }

  void _deleteCustomExercise(_ExerciseItem item) {
    widget.provider.deleteCustomExercise(item.customId!);
    setState(() => _all.removeWhere((e) => e.customId == item.customId));
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

              // ── Title + Create button ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
                child: Row(
                  children: [
                    Text(
                      'Add Exercise',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _showCreateDialog,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Create',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'No exercises found',
                              style: TextStyle(color: c.textDim, fontSize: 15),
                            ),
                            if (_query.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _showCreateDialog,
                                icon: const Icon(Icons.add_circle_outline_rounded),
                                label: Text('Create "$_query"'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.accent,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final ex = filtered[i];
                          return _ExerciseTile(
                            item: ex,
                            onTap: () => Navigator.pop(context, ex.name),
                            onDelete: ex.isCustom
                                ? () => _deleteCustomExercise(ex)
                                : null,
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

// ─── Data model ───────────────────────────────────────────────────────────────

class _ExerciseItem {
  final String name;
  final String group;
  final bool isCustom;
  final int? customId;

  const _ExerciseItem({
    required this.name,
    required this.group,
    required this.isCustom,
    this.customId,
  });
}

// ─── Create exercise dialog ───────────────────────────────────────────────────

class _CreateExerciseDialog extends StatefulWidget {
  final List<String> groups;
  const _CreateExerciseDialog({required this.groups});

  @override
  State<_CreateExerciseDialog> createState() => _CreateExerciseDialogState();
}

class _CreateExerciseDialogState extends State<_CreateExerciseDialog> {
  final _nameCtrl = TextEditingController();
  String? _selectedGroup;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _selectedGroup == null) return;
    Navigator.pop(context, (name: name, group: _selectedGroup!));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'New Exercise',
        style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: TextStyle(color: c.textPrimary),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Exercise name',
              hintStyle: TextStyle(color: c.textHint),
              filled: true,
              fillColor: c.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedGroup,
            dropdownColor: c.surface,
            style: TextStyle(color: c.textPrimary),
            hint: Text('Muscle group', style: TextStyle(color: c.textHint)),
            decoration: InputDecoration(
              filled: true,
              fillColor: c.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: widget.groups
                .map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(g),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedGroup = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: c.textDim)),
        ),
        ElevatedButton(
          onPressed: _nameCtrl.text.trim().isNotEmpty && _selectedGroup != null
              ? _submit
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
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
  final _ExerciseItem item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ExerciseTile({
    required this.item,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tile = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isCustom
                ? AppColors.accent.withValues(alpha: 0.3)
                : c.border,
          ),
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
              child: Icon(
                item.isCustom
                    ? Icons.person_rounded
                    : Icons.fitness_center_rounded,
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
                    item.name,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.group,
                    style: TextStyle(color: c.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 20),
                ),
              )
            else
              Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );

    return tile;
  }
}
