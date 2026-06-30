import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/isar_models.dart';
import '../models/models.dart';

class WorkoutProvider extends ChangeNotifier {
  final Isar _isar;
  final List<Routine> _routines = [];
  final List<CompletedWorkout> _history = [];
  final List<CustomExercise> _customExercises = [];
  WorkoutSession? _activeSession;

  WorkoutProvider(this._isar);

  // ── Persistence ───────────────────────────────────────────────────────────────

  Future<void> init() async {
    _routines.addAll(await _isar.routines.where().findAll());
    _history.addAll(await _isar.completedWorkouts.where().findAll());
    _customExercises.addAll(await _isar.customExercises.where().findAll());
  }

  // ── Getters ───────────────────────────────────────────────────────────────────

  List<Routine> get routines => List.unmodifiable(_routines);
  List<CustomExercise> get customExercises => List.unmodifiable(_customExercises);
  WorkoutSession? get activeSession => _activeSession;
  Duration get elapsed {
    if (_activeSession == null) return Duration.zero;
    return DateTime.now().difference(_activeSession!.startedAt);
  }

  List<CompletedWorkout> get history {
    final sorted = List.of(_history);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  void deleteWorkout(int id) {
    _history.removeWhere((w) => w.id == id);
    _isar.writeTxn(() => _isar.completedWorkouts.delete(id));
    notifyListeners();
  }

  List<CompletedWorkout> workoutsOnDay(DateTime day) => _history
      .where((w) =>
          w.date.year == day.year &&
          w.date.month == day.month &&
          w.date.day == day.day)
      .toList();

  // ── Custom exercises ──────────────────────────────────────────────────────────

  void addCustomExercise(String name, String group) {
    final ex = CustomExercise()
      ..name = name
      ..group = group;
    _isar.writeTxn(() => _isar.customExercises.put(ex));
    _customExercises.add(ex);
    notifyListeners();
  }

  void deleteCustomExercise(int id) {
    _customExercises.removeWhere((e) => e.id == id);
    _isar.writeTxn(() => _isar.customExercises.delete(id));
    notifyListeners();
  }

  // ── Routines ──────────────────────────────────────────────────────────────────

  void addRoutine(Routine routine) {
    _isar.writeTxn(() => _isar.routines.put(routine));
    _routines.add(routine);
    notifyListeners();
  }

  void deleteRoutine(int id) {
    _routines.removeWhere((r) => r.id == id);
    _isar.writeTxn(() => _isar.routines.delete(id));
    notifyListeners();
  }

  void duplicateRoutine(int id) {
    final original = _routines.firstWhere((r) => r.id == id);
    final copy = Routine()
      ..name = '${original.name} (copy)'
      ..exercises = original.exercises
          .map((e) => RoutineExercise()
            ..name = e.name
            ..sets = e.sets
            ..reps = e.reps)
          .toList();
    _isar.writeTxn(() => _isar.routines.put(copy));
    _routines.add(copy);
    notifyListeners();
  }

  void updateRoutine(int id, {required String name, required List<RoutineExercise> exercises}) {
    final index = _routines.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _routines[index]
      ..name = name
      ..exercises = exercises;
    _isar.writeTxn(() => _isar.routines.put(_routines[index]));
    notifyListeners();
  }

  // ── Active session ────────────────────────────────────────────────────────────

  void startRoutine(Routine routine) {
    _activeSession = WorkoutSession(
      routineId: routine.id.toString(),
      name: routine.name,
      startedAt: DateTime.now(),
      exercises: routine.exercises
          .map((e) => ActiveExercise(
                name: e.name ?? '',
                sets: List.generate(e.sets ?? 0, (_) => ActiveSet(reps: e.reps ?? 10)),
              ))
          .toList(),
    );
    notifyListeners();
  }

  void startEmptyWorkout() {
    _activeSession = WorkoutSession(
      name: 'Quick Workout',
      startedAt: DateTime.now(),
      exercises: [],
    );
    notifyListeners();
  }

  void addExerciseToSession(String name, int sets, int reps) {
    if (_activeSession == null) return;
    _activeSession!.exercises.add(ActiveExercise(
      name: name,
      sets: List.generate(sets, (_) => ActiveSet(reps: reps)),
    ));
    notifyListeners();
  }

  void addSet(int exerciseIndex) {
    if (_activeSession == null) return;
    final sets = _activeSession!.exercises[exerciseIndex].sets;
    final last = sets.isNotEmpty ? sets.last : null;
    sets.add(ActiveSet(reps: last?.reps ?? 10, weight: last?.weight));
    notifyListeners();
  }

  void removeSet(int exerciseIndex) {
    if (_activeSession == null) return;
    final sets = _activeSession!.exercises[exerciseIndex].sets;
    if (sets.length > 1) sets.removeLast();
    notifyListeners();
  }

  void updateSetWeight(int exerciseIndex, int setIndex, double? weight) {
    if (_activeSession == null) return;
    _activeSession!.exercises[exerciseIndex].sets[setIndex].weight = weight;
    notifyListeners();
  }

  void updateSetReps(int exerciseIndex, int setIndex, int reps) {
    if (_activeSession == null) return;
    _activeSession!.exercises[exerciseIndex].sets[setIndex].reps = reps;
    notifyListeners();
  }

  void toggleSetCompleted(int exerciseIndex, int setIndex) {
    if (_activeSession == null) return;
    final set = _activeSession!.exercises[exerciseIndex].sets[setIndex];
    set.completed = !set.completed;
    notifyListeners();
  }

  void finishWorkout() {
    if (_activeSession != null) {
      final session = _activeSession!;
      final workout = CompletedWorkout()
        ..name = session.name
        ..date = session.startedAt
        ..durationSeconds = DateTime.now().difference(session.startedAt).inSeconds
        ..exercises = session.exercises
            .map((e) => CompletedExercise()
              ..name = e.name
              ..sets = e.sets
                  .map((s) => CompletedSet()
                    ..reps = s.reps
                    ..weight = s.weight
                    ..completed = s.completed)
                  .toList())
            .toList();
      _isar.writeTxn(() => _isar.completedWorkouts.put(workout));
      _history.add(workout);
    }
    _activeSession = null;
    notifyListeners();
  }

  void discardWorkout() {
    if (_activeSession != null) {
      _activeSession = null;
      notifyListeners();
    }
  }
}
