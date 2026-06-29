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