import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_bar/liquid_glass_bar.dart';
import 'app_colors.dart';
import 'providers/workout_provider.dart';
import 'screens/homepage.dart';
import 'screens/history_screen.dart';
import 'screens/active_workout_screen.dart';
import 'screens/statistics.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatElapsed() {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _openWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<WorkoutProvider>().activeSession;
    final c = AppColors.of(context);

    if (session != null && _timer == null) {
      _elapsed = DateTime.now().difference(session.startedAt);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _elapsed = DateTime.now().difference(session.startedAt));
        }
      });
    } else if (session == null && _timer != null) {
      _timer!.cancel();
      _timer = null;
      _elapsed = Duration.zero;
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom + 78;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: const [
              HomePage(),
              HistoryScreen(),
              StatisticScreen(),
            ],
          ),

          // ── Floating workout banner ────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset),
              child: AnimatedSlide(
                offset: session != null ? Offset.zero : const Offset(0, 1.5),
                duration: const Duration(milliseconds: 340),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: session != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  child: IgnorePointer(
                    ignoring: session == null,
                    child: _WorkoutBanner(
                      name: session?.name ?? '',
                      elapsed: _formatElapsed(),
                      onTap: _openWorkout,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: LiquidGlassBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          LiquidGlassBarItem(iconData: Icons.home_rounded, label: 'Home'),
          LiquidGlassBarItem(iconData: Icons.history_rounded, label: 'History'),
          LiquidGlassBarItem(iconData: Icons.query_stats, label: 'Stats'),
        ],
        style: LiquidGlassBarStyle(
          activeColor: AppColors.accent,
          borderRadius: 32,
          liquidGlassSettings: LiquidGlassSettings(
            thickness: 20.0,
            blur: 10.0,
            glassColor: c.glassColor,
            lightIntensity: 0.8,
            refractiveIndex: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Floating workout banner ──────────────────────────────────────────────────

class _WorkoutBanner extends StatelessWidget {
  final String name;
  final String elapsed;
  final VoidCallback onTap;

  const _WorkoutBanner({
    required this.name,
    required this.elapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.accentGreen.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: c.shadowColor,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            const _PulsingDot(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Workout in progress',
                    style: TextStyle(color: c.textDim, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              elapsed,
              style: const TextStyle(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: c.iconDim, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Pulsing green dot ────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.72, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fade = Tween<double>(begin: 0.45, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColors.accentGreen,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
