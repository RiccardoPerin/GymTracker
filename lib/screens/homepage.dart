import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Routine {
  final String id;
  String name;
  final DateTime createdAt;
  final List<RoutineExercise> exercises;

  Routine({
    required this.id,
    required this.name,
    required this.createdAt,
    this.exercises = const [],
  });

  Routine copyWith({String? id, String? name, List<RoutineExercise>? exercises}) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt,
      exercises: exercises ?? this.exercises,
    );
  }
}

class RoutineExercise {
  final String name;
  final int sets;
  final int reps;

  const RoutineExercise({
    required this.name,
    required this.sets,
    required this.reps,
  });
}

// ─── State ────────────────────────────────────────────────────────────────────

class WorkoutState extends ChangeNotifier {
  final List<Routine> _routines = [
    Routine(
      id: '1',
      name: 'Push Day',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      exercises: [
        const RoutineExercise(name: 'Bench Press', sets: 4, reps: 8),
        const RoutineExercise(name: 'Overhead Press', sets: 3, reps: 10),
        const RoutineExercise(name: 'Tricep Dips', sets: 3, reps: 12),
      ],
    ),
    Routine(
      id: '2',
      name: 'Pull Day',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      exercises: [
        const RoutineExercise(name: 'Deadlift', sets: 4, reps: 5),
        const RoutineExercise(name: 'Pull-ups', sets: 4, reps: 8),
        const RoutineExercise(name: 'Barbell Row', sets: 3, reps: 10),
      ],
    ),
  ];

  List<Routine> get routines => List.unmodifiable(_routines);

  void addRoutine(Routine routine) {
    _routines.add(routine);
    notifyListeners();
  }

  void deleteRoutine(String id) {
    _routines.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void renameRoutine(String id) {

  }

  void duplicateRoutine(String id) {
    final original = _routines.firstWhere((r) => r.id == id);
    final copy = original.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${original.name} (copy)',
    );
    _routines.add(copy);
    notifyListeners();
  }
}

// ─── Home Page ────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<HomePage> {
  final WorkoutState _state = WorkoutState();

  static const _accent = Color(0xFF6C63FF);
  static const _accentGreen = Color(0xFF00D9A3);
  static const _cardBg = Color(0xFF1C1C2E);
  static const _surfaceBg = Color(0xFF16162A);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          body: CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 50,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: const Text(
                    'GymTracker',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
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
                          iconColor: _accent,
                          iconBg: _accent.withOpacity(0.15),
                          label: 'New\nRoutine',
                          onTap: () => _showNewRoutineDialog(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.add,
                          iconColor: _accentGreen,
                          iconBg: _accentGreen.withOpacity(0.15),
                          label: 'Start\nEmpty Workout',
                          onTap: () => _startEmptyWorkout(context),
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
                          color: Colors.white.withOpacity(0.85),
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
                          color: _accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_state.routines.length}',
                          style: const TextStyle(
                            color: _accent,
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
              if (_state.routines.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(40),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 48,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No routines yet, \n Create a new one!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final routine = _state.routines[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RoutineCard(
                            routine: routine,
                            cardBg: _cardBg,
                            surfaceBg: _surfaceBg,
                            accent: _accent,
                            accentGreen: _accentGreen,
                            onStart: () => _startRoutine(context, routine),
                            onDuplicate: () =>
                                _state.duplicateRoutine(routine.id),
                            onRename: () =>
                              _state.renameRoutine(routine.id),
                            onDelete: () =>
                                _confirmDelete(context, routine),
                          ),
                        );
                      },
                      childCount: _state.routines.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Dialogs & actions ─────────────────────────────────────────────────────

  void _showNewRoutineDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'New Routine',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Routine's Name (eg. Push Day)",
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF0F0F1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    _state.addRoutine(Routine(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      createdAt: DateTime.now(),
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Create Routine',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startEmptyWorkout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.fitness_center, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Workout started!'),
          ],
        ),
        backgroundColor: const Color(0xFF00D9A3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _startRoutine(BuildContext context, Routine routine) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.play_circle_filled, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text('Start "${routine.name}"'),
          ],
        ),
        backgroundColor: const Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Routine?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          '"${routine.name}" will be permanently deleted.',
          style: TextStyle(color: Colors.white.withOpacity(0.65)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Discard', style: TextStyle(color: Colors.white54)),
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
              _state.deleteRoutine(routine.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: iconColor.withOpacity(0.15),
            width: 1,
          ),
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
              style: const TextStyle(
                color: Colors.white,
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
  final Color cardBg;
  final Color surfaceBg;
  final Color accent;
  final Color accentGreen;
  final VoidCallback onStart;
  final VoidCallback onDuplicate;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _RoutineCard({
    required this.routine,
    required this.cardBg,
    required this.surfaceBg,
    required this.accent,
    required this.accentGreen,
    required this.onStart,
    required this.onDuplicate,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
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
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: accent,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (routine.exercises.isNotEmpty)
                        Text(
                          '${routine.exercises.length} exercises',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  color: const Color(0xFF252540),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) {
                    if (value == 'duplicate') onDuplicate();
                    if (value == 'delete') onDelete();
                    if (value == 'rename') onRename();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy_rounded, size: 18, color: Colors.white70),
                          SizedBox(width: 10),
                          Text('Duplicate', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.drive_file_rename_outline_outlined,
                              size: 18, color: Colors.white70),
                          SizedBox(width: 10),
                          Text('Rename', style: TextStyle(color: Colors.white))
                        ],
                      )
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text('Delete',
                              style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ex.name} ${ex.sets}×${ex.reps}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
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
                  backgroundColor: accentGreen,
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