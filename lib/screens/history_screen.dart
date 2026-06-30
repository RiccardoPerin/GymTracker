import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../models/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  bool get _isNotCurrentMonth {
    final now = DateTime.now();
    return _focusedDay.month != now.month || _focusedDay.year != now.year;
  }

  void _goToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _dateHeader(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return 'Today';
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  // ── Detail bottom sheet ───────────────────────────────────────────────────────

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WorkoutProvider provider,
    CompletedWorkout workout,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final c = AppColors.of(context);
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Are you sure?",
            style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800)
          ),
          content: Text(
            "This will permanently delete this workout.",
            style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w500),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context, false), 
                    child: Text(
                      "Go back",
                      style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w700),
                    )
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      "Delete", 
                      style: TextStyle(fontWeight: FontWeight.w700)
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      }
    );
    if (confirm == true) {
      provider.deleteWorkout(workout.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _showDetail(BuildContext context, CompletedWorkout workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (ctx, scrollCtrl) {
          final c = AppColors.of(ctx);
          return Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.dragHandle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                    children: [
                      Text(
                        workout.name,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Chip(
                            icon: Icons.calendar_today_outlined,
                            label: _dateHeader(workout.date),
                            color: AppColors.accent,
                          ),
                          _Chip(
                            icon: Icons.access_time_rounded,
                            label: _formatTime(workout.date),
                            color: AppColors.accent,
                          ),
                          _Chip(
                            icon: Icons.timer_outlined,
                            label: _formatDuration(workout.duration),
                            color: AppColors.accentGreen,
                          ),
                          _Chip(
                            icon: Icons.fitness_center_rounded,
                            label: '${workout.exercises.length} exercises',
                            color: c.iconMid,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ...workout.exercises.map((exercise) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ExerciseDetail(
                              exercise: exercise,
                            ),
                          )),
                      ElevatedButton.icon(
                        onPressed: () {
                          final provider = context.read<WorkoutProvider>();
                          _showDeleteConfirmation(context, provider, workout);
                        },
                        icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.white,),
                        label: const Text(
                          'Delete Workout',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final provider = context.watch<WorkoutProvider>();
    final workoutsForDay = provider.workoutsOnDay(_selectedDay);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.appBarBg,
        title: Text(
          'History',
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_isNotCurrentMonth)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _goToToday,
                child: Text(
                  'Today', 
                  style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w700, fontSize: 15)
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Calendar ──────────────────────────────────────────────────────
          Container(
            color: c.calendarBg,
            padding: const EdgeInsets.only(bottom: 8),
            child: TableCalendar<CompletedWorkout>(
              firstDay: DateTime.utc(2026, 1, 1),
              lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
              startingDayOfWeek: StartingDayOfWeek.monday,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              eventLoader: provider.workoutsOnDay,
              onDaySelected: (selected, focused) => setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              }),
              onPageChanged: (focused) => setState(() => _focusedDay = focused),
              calendarFormat: CalendarFormat.month,
              rowHeight: 46,
              daysOfWeekHeight: 28,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: TextStyle(
                  color: c.calendarDayText,
                ),
                weekendTextStyle: TextStyle(
                  color: c.calendarDayText,
                ),
                disabledTextStyle: TextStyle(
                  color: c.calendarDisabledText,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w700,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerSize: 5,
                markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
                cellMargin: const EdgeInsets.all(5),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: c.calendarTitleText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left_rounded,
                  color: c.calendarChevron,
                  size: 28,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right_rounded,
                  color: c.calendarChevron,
                  size: 28,
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: c.calendarWeekdayText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: TextStyle(
                  color: c.calendarWeekdayText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          Divider(color: c.divider, height: 1),

          // ── Day header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Row(
              children: [
                Text(
                  _dateHeader(_selectedDay),
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (workoutsForDay.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${workoutsForDay.length}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Workout list ──────────────────────────────────────────────────
          Expanded(
            child: workoutsForDay.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          size: 48,
                          color: c.iconFaint,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No workouts this day',
                          style: TextStyle(
                            color: c.textDim,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      16, 6, 16, provider.activeSession != null ? 96 : 32),
                    itemCount: workoutsForDay.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final workout = workoutsForDay[i];
                      return _WorkoutCard(
                        workout: workout,
                        formatTime: _formatTime,
                        formatDuration: _formatDuration,
                        onTap: () => _showDetail(context, workout),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Workout history card ─────────────────────────────────────────────────────

class _WorkoutCard extends StatelessWidget {
  final CompletedWorkout workout;
  final String Function(DateTime) formatTime;
  final String Function(Duration) formatDuration;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.workout,
    required this.formatTime,
    required this.formatDuration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            // Time + duration
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTime(workout.date),
                  style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDuration(workout.duration),
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Container(width: 1, height: 36, color: c.divider),
            const SizedBox(width: 14),
            // Name + exercise count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${workout.exercises.length} exercise${workout.exercises.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: c.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: c.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Exercise detail (inside bottom sheet) ────────────────────────────────────

class _ExerciseDetail extends StatelessWidget {
  final CompletedExercise exercise;

  const _ExerciseDetail({
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.inputBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          // Column headers
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  'Set',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.textDim,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Weight',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.textDim,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reps',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.textDim,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const SizedBox(width: 26),
            ],
          ),
          const SizedBox(height: 6),
          // Set rows
          ...exercise.sets.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final weightStr = s.weight != null
                ? '${s.weight!.toStringAsFixed(s.weight! % 1 == 0 ? 0 : 1)} kg'
                : '—';
            return Opacity(
              opacity: s.completed ? 1.0 : 0.4,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${i + 1}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: c.textHint,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        weightStr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${s.reps}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: s.completed
                            ? AppColors.accentGreen.withValues(alpha: 0.18)
                            : c.chipBg,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        s.completed ? Icons.check_rounded : Icons.close_rounded,
                        size: 14,
                        color: s.completed ? AppColors.accentGreen : c.dragHandle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Info chip ────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
