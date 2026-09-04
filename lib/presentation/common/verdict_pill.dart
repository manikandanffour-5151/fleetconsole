import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../theme/app_theme.dart';

class VerdictPill extends StatelessWidget {
  final SignalVerdict verdict;

  const VerdictPill({super.key, required this.verdict});

  @override
  Widget build(BuildContext context) {
    if (verdict == SignalVerdict.unreported) {
      return const Text('—', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold));
    }

    Color bg;
    Color text;
    String label;

    switch (verdict) {
      case SignalVerdict.normal:
        bg = AppTheme.verdictNormalBg;
        text = AppTheme.verdictNormalText;
        label = 'NORMAL';
        break;
      case SignalVerdict.alert:
        bg = AppTheme.verdictAlertBg;
        text = AppTheme.verdictAlertText;
        label = 'ALERT';
        break;
      case SignalVerdict.stale:
      default:
        bg = AppTheme.verdictStaleBg;
        text = AppTheme.verdictStaleText;
        label = 'STALE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
