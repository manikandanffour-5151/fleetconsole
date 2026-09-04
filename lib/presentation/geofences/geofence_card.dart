import 'package:flutter/material.dart';
import '../../data/models/models.dart';

class GeofenceCard extends StatelessWidget {
  final Geofence geofence;
  final int vehicleCount;
  final ValueChanged<bool> onToggleActive;

  const GeofenceCard({
    super.key,
    required this.geofence,
    required this.vehicleCount,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: geofence.isActive ? Colors.blue.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.location_on,
                color: geofence.isActive ? Colors.blue : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    geofence.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: geofence.isActive ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Center: ${geofence.centerLat.toStringAsFixed(4)}, ${geofence.centerLng.toStringAsFixed(4)} (${geofence.radiusMeters.toInt()}m)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$vehicleCount vehicles inside',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: geofence.isActive,
              onChanged: onToggleActive,
            ),
          ],
        ),
      ),
    );
  }
}
