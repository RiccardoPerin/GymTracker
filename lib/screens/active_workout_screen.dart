import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../models/app_colors.dart';
import '../widgets/exercise_picker_sheet.dart';

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
          content: StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              // Leggi l'elapsed aggiornato dal provider ad ogni "tick" del secondo
              final currentElapsed = context.read<WorkoutProvider>().elapsed;
              
              return Text(
                'Workout time: ${_formatDuration(currentElapsed)}',
                style: TextStyle(color: c.textSecondary),
              );
            },
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
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
                        child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
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
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context), 
                    child: const Text('Go back', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey))
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }

  void _showAddExerciseSheet() async {
    final name = await showExercisePicker(context);
    if (name == null || !mounted) return;
    context.read<WorkoutProvider>().addExerciseToSession(name, 3, 10);
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

