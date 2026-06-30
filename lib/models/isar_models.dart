import 'package:isar/isar.dart';

part 'isar_models.g.dart';

// --- ROUTINES -------
@collection 
class Routine {
  Id id = Isar.autoIncrement;
  late String name;
  List<RoutineExercise> exercises = [];
}

@embedded 
class RoutineExercise {
  String? name;
  int? sets;
  int? reps;
}


// ------- CUSTOM EXERCISES --------
@collection
class CustomExercise {
  Id id = Isar.autoIncrement;
  late String name;
  late String group;
}

// ------HISTORY TRAINING ---------
@collection
class CompletedWorkout {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;
  late String name;
  late int durationSeconds;
  List<CompletedExercise> exercises = [];

  @ignore
  Duration get duration => Duration(seconds: durationSeconds);
}

@embedded 
class CompletedExercise {
  String? name;
  List<CompletedSet> sets = [];
}

@embedded 
class CompletedSet {
  int? reps;
  double? weight;
  bool? completed;
}