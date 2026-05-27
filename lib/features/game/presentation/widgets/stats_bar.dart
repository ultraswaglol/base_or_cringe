import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/situation.dart';

class StatsBar extends StatelessWidget {
  final CommunityStats stats;

  const StatsBar({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final basePct = stats.basePercentage;
    final cringePct = stats.cringePercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Голоса сообщества:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 32,
            child: Row(
              children: [

                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  width: MediaQuery.of(context).size.width * (basePct / 100) * 0.8,
                  color: AppTheme.neonGreen.withValues(alpha: 0.9),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '🗿 ${basePct.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),

                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    color: AppTheme.neonRed.withValues(alpha: 0.9),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${cringePct.toStringAsFixed(0)}% 😬',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
