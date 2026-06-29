import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'providers/workout_provider.dart';
import 'navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = WorkoutProvider();
  await provider.init();
  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const GymTracker(),
    ),
  );
}

class GymTracker extends StatelessWidget {
  const GymTracker({super.key});

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      textTheme: GoogleFonts.poppinsTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: brightness,
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF2F2F7),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF11111A),
        elevation: 0,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymTracker',
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const NavigationShell(),
    );
  }
}
