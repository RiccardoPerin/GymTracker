import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../models/app_colors.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _routineNameController = TextEditingController();
  final List<_ExerciseEntry> _exercises = [];

  @override
  void dispose() {
    _routineNameController.dispose();
    for (final e in _exercises) {
      e.dispose();
    }
    super.dispose();
  }

  void _addExercise() {
    setState(() => _exercises.add(_ExerciseEntry()));
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises[index].dispose();
      _exercises.removeAt(index);
    });
  }

  void _saveRoutine() {
    final name = _routineNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a routine name'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final exercises = <RoutineExercise>[];
    for (final entry in _exercises) {
      final eName = entry.nameController.text.trim();
      if (eName.isEmpty) continue;
      final sets = (int.tryParse(entry.setsController.text) ?? 3).clamp(1, 20);
      final reps = (int.tryParse(entry.repsController.text) ?? 10).clamp(1, 100);
      exercises.add(RoutineExercise(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: eName,
        sets: sets,
        reps: reps,
      ));
    }

    context.read<WorkoutProvider>().addRoutine(Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      exercises: exercises,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.appBarBg,
        foregroundColor: c.textPrimary,
        title: Text(
          'New Routine',
          style: TextStyle(fontWeight: FontWeight.w800, color: c.textPrimary),
        ),
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Routine name ─────────────────────────────────────────────
          _DarkTextField(
            controller: _routineNameController,
            hint: 'Routine name (e.g. Push Day)',
            autofocus: true,
          ),
          const SizedBox(height: 28),

          // ── Exercises header ──────────────────────────────────────────
          Row(
            children: [
              Text(
                'Exercises',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${_exercises.length}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Exercise cards ────────────────────────────────────────────
          ..._exercises.asMap().entries.map((entry) {
            final i = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseCard(
                index: i,
                entry: entry.value,
                onRemove: () => _removeExercise(i),
              ),
            );
          }),

          const SizedBox(height: 4),
          _AddButton(
            label: 'Add Exercise',
            color: AppColors.accent,
            onTap: _addExercise,
          ),
          const SizedBox(height: 32),

          // ── Save button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: const Color(0xFF0F0F1A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _saveRoutine,
              child: const Text(
                'Save Routine',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Data holder for one exercise entry ──────────────────────────────────────

class _ExerciseEntry {
  final nameController = TextEditingController();
  final setsController = TextEditingController(text: '3');
  final repsController = TextEditingController(text: '10');

  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
  }
}

// ─── Exercise card ────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final int index;
  final _ExerciseEntry entry;
  final VoidCallback onRemove;

  const _ExerciseCard({
    required this.index,
    required this.entry,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Exercise ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: c.textDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DarkTextField(
            controller: entry.nameController,
            hint: 'Exercise name (e.g. Bench Press)',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StepperField(
                  label: 'Sets',
                  controller: entry.setsController,
                  min: 1,
                  max: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StepperField(
                  label: 'Reps',
                  controller: entry.repsController,
                  min: 1,
                  max: 100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stepper field ────────────────────────────────────────────────────────────

class _StepperField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int min;
  final int max;

  const _StepperField({
    required this.label,
    required this.controller,
    required this.min,
    required this.max,
  });

  void _increment() {
    final v = int.tryParse(controller.text) ?? min;
    if (v < max) controller.text = '${v + 1}';
  }

  void _decrement() {
    final v = int.tryParse(controller.text) ?? min;
    if (v > min) controller.text = '${v - 1}';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: c.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: c.inputBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _StepButton(icon: Icons.remove, onTap: _decrement),
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              _StepButton(icon: Icons.add, onTap: _increment),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Icon(icon, size: 18, color: c.iconMid),
      ),
    );
  }
}

// ─── Dark text field ──────────────────────────────────────────────────────────

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool autofocus;

  const _DarkTextField({
    required this.controller,
    required this.hint,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: TextStyle(color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textHint),
        filled: true,
        fillColor: c.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ─── Add button ───────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
