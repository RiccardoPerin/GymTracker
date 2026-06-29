class Routine {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<RoutineExercise> exercises;

  const Routine({
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory Routine.fromJson(Map<String, dynamic> j) => Routine(
    id: j['id'] as String,
    name: j['name'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
    exercises: (j['exercises'] as List)
        .map((e) => RoutineExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class RoutineExercise {
  final String id;
  final String name;
  final int sets;
  final int reps;

  const RoutineExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
  });

  RoutineExercise copyWith({String? name, int? sets, int? reps}) {
    return RoutineExercise(
      id: id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sets': sets,
    'reps': reps,
  };

  factory RoutineExercise.fromJson(Map<String, dynamic> j) => RoutineExercise(
    id: j['id'] as String,
    name: j['name'] as String,
    sets: j['sets'] as int,
    reps: j['reps'] as int,
  );
}

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

// ─── Completed workout (history) ─────────────────────────────────────────────

class CompletedSet {
  final int reps;
  final double? weight;
  final bool completed;

  const CompletedSet({
    required this.reps,
    this.weight,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'weight': weight,
    'completed': completed,
  };

  factory CompletedSet.fromJson(Map<String, dynamic> j) => CompletedSet(
    reps: j['reps'] as int,
    weight: (j['weight'] as num?)?.toDouble(),
    completed: j['completed'] as bool,
  );
}

class CompletedExercise {
  final String name;
  final List<CompletedSet> sets;

  const CompletedExercise({required this.name, required this.sets});

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory CompletedExercise.fromJson(Map<String, dynamic> j) => CompletedExercise(
    name: j['name'] as String,
    sets: (j['sets'] as List)
        .map((s) => CompletedSet.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

class CompletedWorkout {
  final String id;
  final String name;
  final DateTime date;
  final Duration duration;
  final List<CompletedExercise> exercises;

  CompletedWorkout({
    required this.id,
    required this.name,
    required this.date,
    required this.duration,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date.toIso8601String(),
    'durationSeconds': duration.inSeconds,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory CompletedWorkout.fromJson(Map<String, dynamic> j) => CompletedWorkout(
    id: j['id'] as String,
    name: j['name'] as String,
    date: DateTime.parse(j['date'] as String),
    duration: Duration(seconds: j['durationSeconds'] as int),
    exercises: (j['exercises'] as List)
        .map((e) => CompletedExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
