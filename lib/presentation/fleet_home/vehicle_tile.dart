import 'package:flutter/material.dart';
import '../../core/utils/time_utils.dart';
import '../../data/models/models.dart';
import '../common/vehicle_status_chip.dart';

class VehicleTile extends StatelessWidget {
  final VehicleSummary vehicle;
  final VoidCallback onTap;

  const VehicleTile({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Registration + Status Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vehicle.regNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  VehicleStatusChip(status: vehicle.status),
                ],
              ),
              const SizedBox(height: 4),
              // Model name
              Text(
                vehicle.model,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const Divider(height: 20),
              // Metrics Row: SOC %, Range, Last Ping
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Battery SOC
                  Row(
                    children: [
                      Icon(
                        vehicle.soc != null && vehicle.soc! < 20
                            ? Icons.battery_alert
                            : Icons.battery_charging_full,
                        size: 18,
                        color: vehicle.soc != null && vehicle.soc! < 20
                            ? Colors.red
                            : Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.soc != null
                            ? '${vehicle.soc!.toStringAsFixed(0)}%'
                            : '—',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Estimated Range
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 18, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.rangeKm != null
                            ? '${vehicle.rangeKm!.toStringAsFixed(0)} km'
                            : '—',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                  // Last Ping Age
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.lastPing != null
                            ? TimeUtils.formatAge(vehicle.lastPing!)
                            : 'Never',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
