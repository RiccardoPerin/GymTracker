class ActiveSet {
  double? weight;
  int reps;
  bool completed;

  ActiveSet({this.weight, required this.reps, this.completed = false});
}

class ActiveExercise {
  final String name;
  final List<ActiveSet> sets;

  ActiveExercise({required this.name, required this.sets});
}

class WorkoutSession {
  final String? routineId;
  final String name;
  final DateTime startedAt;
  final List<ActiveExercise> exercises;

  WorkoutSession({
    this.routineId,
    required this.name,
    required this.startedAt,
    required this.exercises,
  });
}
