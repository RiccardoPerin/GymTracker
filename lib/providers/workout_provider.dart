import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class WorkoutProvider extends ChangeNotifier {
  final List<Routine> _routines = [];
  final List<CompletedWorkout> _history = [];
  WorkoutSession? _activeSession;

  // ── Persistence ───────────────────────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final routinesStr = prefs.getString('routines');
    if (routinesStr != null) {
      final decoded = jsonDecode(routinesStr) as List;
      _routines.addAll(
        decoded.map((e) => Routine.fromJson(e as Map<String, dynamic>)),
      );
    }

    final historyStr = prefs.getString('history');
    if (historyStr != null) {
      final decoded = jsonDecode(historyStr) as List;
      _history.addAll(
        decoded.map((e) => CompletedWorkout.fromJson(e as Map<String, dynamic>)),
      );
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'routines',
      jsonEncode(_routines.map((r) => r.toJson()).toList()),
    );
    await prefs.setString(
      'history',
      jsonEncode(_history.map((h) => h.toJson()).toList()),
    );
  }

  // ── Getters ───────────────────────────────────────────────────────────────────

  List<Routine> get routines => List.unmodifiable(_routines);
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

  void deleteWorkout(String id) {
    _history.removeWhere((w) => w.id == id);
    _save();
    notifyListeners();
  }

  List<CompletedWorkout> workoutsOnDay(DateTime day) => _history
      .where((w) =>
          w.date.year == day.year &&
          w.date.month == day.month &&
          w.date.day == day.day)
      .toList();

  // ── Routines ──────────────────────────────────────────────────────────────────

  void addRoutine(Routine routine) {
    _routines.add(routine);
    _save();
    notifyListeners();
  }

  void deleteRoutine(String id) {
    _routines.removeWhere((r) => r.id == id);
    _save();
    notifyListeners();
  }

  void duplicateRoutine(String id) {
    final original = _routines.firstWhere((r) => r.id == id);
    _routines.add(original.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${original.name} (copy)',
    ));
    _save();
    notifyListeners();
  }

  void updateRoutine(String id, {required String name, required List<RoutineExercise> exercises}) {
    final index = _routines.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _routines[index] = _routines[index].copyWith(name: name, exercises: exercises);
    _save();
    notifyListeners();
  }

  // ── Active session ────────────────────────────────────────────────────────────

  void startRoutine(Routine routine) {
    _activeSession = WorkoutSession(
      routineId: routine.id,
      name: routine.name,
      startedAt: DateTime.now(),
      exercises: routine.exercises
          .map((e) => ActiveExercise(
                name: e.name,
                sets: List.generate(e.sets, (_) => ActiveSet(reps: e.reps)),
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
      _history.add(CompletedWorkout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: session.name,
        date: session.startedAt,
        duration: DateTime.now().difference(session.startedAt),
        exercises: session.exercises
            .map((e) => CompletedExercise(
                  name: e.name,
                  sets: e.sets
                      .map((s) => CompletedSet(
                            reps: s.reps,
                            weight: s.weight,
                            completed: s.completed,
                          ))
                      .toList(),
                ))
            .toList(),
      ));
      _save();
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
