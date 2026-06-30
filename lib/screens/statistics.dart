import 'package:flutter/material.dart';
import '../models/app_colors.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Statistics',
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(
          'Coming soon...',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
