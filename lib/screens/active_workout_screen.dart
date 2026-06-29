import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../app_colors.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late final Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    final startedAt =
        context.read<WorkoutProvider>().activeSession?.startedAt ?? DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed = DateTime.now().difference(startedAt));
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _confirmFinish() {
    showDialog(
      context: context,
      builder: (context) {
        final c = AppColors.of(context);
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Finish Workout?',
            style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Workout time: ${_formatDuration(_elapsed)}',
            style: TextStyle(color: c.textSecondary),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                context.read<WorkoutProvider>().discardWorkout();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: AppColors.of(context).background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                context.read<WorkoutProvider>().finishWorkout();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showAddExerciseSheet() {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '10');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.dragHandle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add Exercise',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _DarkTextField(controller: nameCtrl, hint: 'Exercise name', autofocus: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StepperField(label: 'Sets', controller: setsCtrl, min: 1, max: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StepperField(label: 'Reps', controller: repsCtrl, min: 1, max: 100),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      final sets = (int.tryParse(setsCtrl.text) ?? 3).clamp(1, 20);
                      final reps = (int.tryParse(repsCtrl.text) ?? 10).clamp(1, 100);
                      context.read<WorkoutProvider>().addExerciseToSession(name, sets, reps);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final session = context.watch<WorkoutProvider>().activeSession;
    if (session == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.appBarBg,
        foregroundColor: c.textPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            Text(
              _formatDuration(_elapsed),
              style: const TextStyle(
                color: AppColors.accentGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: c.background,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _confirmFinish,
              child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: session.exercises.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center_rounded,
                    size: 52,
                    color: c.iconFaint,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No exercises yet\nTap + to add one',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.textDim,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: session.exercises.length,
              itemBuilder: (context, exerciseIndex) {
                final exercise = session.exercises[exerciseIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ExerciseBlock(
                    exerciseIndex: exerciseIndex,
                    exercise: exercise,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExerciseSheet,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ─── Exercise block ───────────────────────────────────────────────────────────

class _ExerciseBlock extends StatelessWidget {
  final int exerciseIndex;
  final ActiveExercise exercise;

  const _ExerciseBlock({
    required this.exerciseIndex,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Exercise header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center_rounded, color: AppColors.accent, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exercise.name,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Column headers ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    'Set',
                    style: TextStyle(
                      color: c.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Weight (kg)',
                    style: TextStyle(
                      color: c.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reps',
                    style: TextStyle(
                      color: c.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(width: 36),
              ],
            ),
          ),

          // ── Set rows ─────────────────────────────────────────────────────
          ...exercise.sets.asMap().entries.map((entry) {
            return _SetRow(
              exerciseIndex: exerciseIndex,
              setIndex: entry.key,
              set: entry.value,
            );
          }),

          // ── Add / Remove set buttons ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: _SetActionButton(
                    icon: Icons.add,
                    label: 'Add Set',
                    color: AppColors.accentGreen,
                    onTap: () =>
                        context.read<WorkoutProvider>().addSet(exerciseIndex),
                  ),
                ),
                if (exercise.sets.length > 1) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SetActionButton(
                      icon: Icons.remove,
                      label: 'Remove Set',
                      color: Colors.redAccent,
                      onTap: () =>
                          context.read<WorkoutProvider>().removeSet(exerciseIndex),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Set row ──────────────────────────────────────────────────────────────────

class _SetRow extends StatelessWidget {
  final int exerciseIndex;
  final int setIndex;
  final ActiveSet set;

  const _SetRow({
    required this.exerciseIndex,
    required this.setIndex,
    required this.set,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedOpacity(
      opacity: set.completed ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: [
            // Set number
            SizedBox(
              width: 32,
              child: Text(
                '${setIndex + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textTertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Weight field
            Expanded(
              child: _NumericInput(
                initialValue: set.weight != null
                    ? set.weight!.toStringAsFixed(
                        set.weight! % 1 == 0 ? 0 : 1)
                    : '',
                hint: '—',
                decimal: true,
                onChanged: (val) => context
                    .read<WorkoutProvider>()
                    .updateSetWeight(exerciseIndex, setIndex, double.tryParse(val)),
              ),
            ),
            const SizedBox(width: 8),

            // Reps field
            Expanded(
              child: _NumericInput(
                initialValue: '${set.reps}',
                hint: '0',
                decimal: false,
                onChanged: (val) {
                  final reps = int.tryParse(val);
                  if (reps != null) {
                    context
                        .read<WorkoutProvider>()
                        .updateSetReps(exerciseIndex, setIndex, reps);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),

            // Done toggle
            GestureDetector(
              onTap: () => context
                  .read<WorkoutProvider>()
                  .toggleSetCompleted(exerciseIndex, setIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: set.completed
                      ? AppColors.accentGreen
                      : c.chipBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: set.completed
                      ? c.background
                      : c.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Numeric input ────────────────────────────────────────────────────────────

class _NumericInput extends StatefulWidget {
  final String initialValue;
  final String hint;
  final bool decimal;
  final ValueChanged<String> onChanged;

  const _NumericInput({
    required this.initialValue,
    required this.hint,
    required this.decimal,
    required this.onChanged,
  });

  @override
  State<_NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<_NumericInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.numberWithOptions(decimal: widget.decimal),
      inputFormatters: [
        widget.decimal
            ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            : FilteringTextInputFormatter.digitsOnly,
      ],
      textAlign: TextAlign.center,
      style: TextStyle(
        color: c.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: c.textHint),
        filled: true,
        fillColor: c.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}

// ─── Set action button ────────────────────────────────────────────────────────

class _SetActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SetActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
