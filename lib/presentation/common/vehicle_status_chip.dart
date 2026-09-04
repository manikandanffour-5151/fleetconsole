import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../theme/app_theme.dart';

class VehicleStatusChip extends StatelessWidget {
  final VehicleStatus status;

  const VehicleStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case VehicleStatus.moving:
        bg = AppTheme.statusMovingBg;
        text = AppTheme.statusMovingText;
        label = 'MOVING';
        break;
      case VehicleStatus.idle:
        bg = AppTheme.statusIdleBg;
        text = AppTheme.statusIdleText;
        label = 'IDLE';
        break;
      case VehicleStatus.stopped:
        bg = AppTheme.statusStoppedBg;
        text = AppTheme.statusStoppedText;
        label = 'STOPPED';
        break;
      case VehicleStatus.offline:
      default:
        bg = AppTheme.statusOfflineBg;
        text = AppTheme.statusOfflineText;
        label = 'OFFLINE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
