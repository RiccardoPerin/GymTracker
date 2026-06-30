# GymTracker

A clean, offline-first workout tracking app for iOS built with Flutter. GymTracker lets you build structured routines, log live sessions, and review your training history — all stored locally on-device with no account required.

---

## Features

### Routine Management
- Create workout routines with a custom name and any number of exercises
- Define sets and reps per exercise when building the template
- Edit, duplicate, or delete routines at any time

### Active Workout
- Start a session from any saved routine (pre-populated with exercises and sets) or begin an empty freestyle workout
- Add exercises on the fly during a session via the exercise picker
- Log weight and reps per set; mark sets as completed with a single tap
- Dynamically add or remove sets within each exercise block
- Live elapsed timer displayed in the app bar and on a floating banner visible from every screen
- Finish and save, or discard the session entirely

### Exercise Library
- 59 built-in exercises across 7 muscle groups (Abs, Arms, Back, Chest, Legs, Shoulders, Traps)
- Searchable by name with muscle-group filter chips
- Create and delete custom exercises assigned to any existing muscle group

### Training History
- Calendar view with dot markers on days where workouts were completed
- Tap any day to see that session's exercises, sets, reps, weights, start time, and duration
- Delete individual past workouts

### Design
- Material 3 design with a custom color palette (purple accent + green highlight)
- Full dark / light mode following the system setting
- Liquid-glass navigation bar with Home, History, and Statistics (coming soon) tabs
- Poppins typeface via Google Fonts

---

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter / Dart |
| Local database | [Isar](https://isar.dev/) v3 |
| State management | [Provider](https://pub.dev/packages/provider) |
| Calendar widget | [table_calendar](https://pub.dev/packages/table_calendar) |
| Navigation bar | [liquid_glass_bar](https://pub.dev/packages/liquid_glass_bar) |
| Typography | [google_fonts](https://pub.dev/packages/google_fonts) (Poppins) |

---

## Project Structure

```
lib/
├── main.dart                        # App entry point, Isar init, theme
├── navigation_shell.dart            # Bottom nav + floating workout banner
├── models/
│   ├── app_colors.dart              # Centralized color tokens (dark/light)
│   ├── isar_models.dart             # Persisted collections: Routine, CompletedWorkout, CustomExercise
│   └── models.dart                  # In-memory session models: WorkoutSession, ActiveExercise, ActiveSet
├── providers/
│   └── workout_provider.dart        # Single ChangeNotifier managing routines, history, and active session
├── screens/
│   ├── homepage.dart                # Routine list + quick-action cards
│   ├── active_workout_screen.dart   # Live session UI with set logging
│   ├── history_screen.dart          # Calendar + per-day workout log
│   ├── create_routine_screen.dart   # New routine form
│   ├── edit_routine_screen.dart     # Edit existing routine
│   └── statistics.dart              # Statistics screen (coming soon)
└── widgets/
    └── exercise_picker_sheet.dart   # Bottom sheet for exercise selection and creation
assets/
└── exercises.json                   # Bundled exercise library
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.11
- Xcode (for iOS builds)
- CocoaPods

### Installation

```bash
git clone https://github.com/RiccardoPerin/GymTracker.git
cd GymTracker
flutter pub get
cd ios && pod install && cd ..
```

### Run

```bash
flutter run
```

To regenerate Isar schema bindings after modifying `isar_models.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Data Model

All data is persisted locally using Isar. Three top-level collections are opened at startup:

| Collection | Purpose |
|---|---|
| `Routine` | Saved workout templates with embedded `RoutineExercise` objects |
| `CompletedWorkout` | Finished sessions with date, duration, and embedded `CompletedExercise`/`CompletedSet` |
| `CustomExercise` | User-created exercises with a name and muscle group |

Active workout state is held in memory inside `WorkoutProvider` as a `WorkoutSession` and written to `CompletedWorkout` only when the user confirms finishing.

---

## License

MIT
