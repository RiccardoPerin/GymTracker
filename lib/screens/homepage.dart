import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../models/app_colors.dart';
import 'create_routine_screen.dart';
import 'active_workout_screen.dart';
import 'edit_routine_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 50,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16, top: 20),
              title: Text(
                'GymTracker',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: c.textPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.appBarBg, c.background],
                  ),
                ),
              ),
            ),
          ),

          // ── Quick Actions ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.assignment_add,
                      iconColor: AppColors.accent,
                      iconBg: AppColors.accent.withValues(alpha: 0.15),
                      label: 'New\nRoutine',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateRoutineScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add,
                      iconColor: AppColors.accentGreen,
                      iconBg: AppColors.accentGreen.withValues(alpha: 0.15),
                      label: 'Start\nEmpty Workout',
                      onTap: () {
                        context.read<WorkoutProvider>().startEmptyWorkout();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ActiveWorkoutScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── My Routines header ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  Text(
                    'My Routines',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: c.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${provider.routines.length}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Routines list ─────────────────────────────────────────────
          if (provider.routines.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(40),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 48,
                        color: c.textFaint,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No routines yet,\nCreate a new one!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: c.textDim,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20, 0, 20, provider.activeSession != null ? 96 : 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final routine = provider.routines[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RoutineCard(
                        routine: routine,
                        onStart: () {
                          context.read<WorkoutProvider>().startRoutine(routine);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ActiveWorkoutScreen(),
                            ),
                          );
                        },
                        onDuplicate: () =>
                            context.read<WorkoutProvider>().duplicateRoutine(routine.id),
                        onDelete: () => _confirmDelete(context, routine),
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditRoutineScreen(routine: routine),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: provider.routines.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Delete Routine?',
            style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800),
          ),
          content: Text(
            '"${routine.name}" will be permanently deleted.',
            style: TextStyle(color: c.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: c.iconMid)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                context.read<WorkoutProvider>().deleteRoutine(routine.id);
                Navigator.pop(ctx);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// ─── Quick Action Card ────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: iconColor.withValues(alpha: 0.15), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Routine Card ─────────────────────────────────────────────────────────────

class _RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onStart;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _RoutineCard({
    required this.routine,
    required this.onStart,
    required this.onDuplicate,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
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
                        routine.name,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (routine.exercises.isNotEmpty)
                        Text(
                          '${routine.exercises.length} exercises',
                          style: TextStyle(
                            color: c.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: c.textTertiary,
                  ),
                  color: c.popupBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) {
                    if (value == 'duplicate') onDuplicate();
                    if (value == 'delete') onDelete();
                    if (value == 'edit') onEdit();
                  },
                  itemBuilder: (ctx) {
                    final pc = AppColors.of(ctx);
                    return [
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded, size: 18, color: pc.iconMid),
                            const SizedBox(width: 10),
                            Text('Duplicate', style: TextStyle(color: pc.textPrimary)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_note_outlined, size: 18, color: pc.iconMid),
                            const SizedBox(width: 10),
                            Text('Edit', style: TextStyle(color: pc.textPrimary)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),

          // ── Exercise chips ───────────────────────────────────────────────
          if (routine.exercises.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 28,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: routine.exercises.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final ex = routine.exercises[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: c.chipBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ex.name} ${ex.sets}×${ex.reps}',
                      style: TextStyle(
                        color: c.textTertiary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // ── Start button ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text(
                  'Start Workout',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: const Color(0xFF0F0F1A),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
