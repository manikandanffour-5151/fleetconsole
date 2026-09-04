import 'package:flutter/material.dart';
import '../../core/utils/time_utils.dart';
import '../../data/models/models.dart';
import '../common/verdict_pill.dart';

class ReadingsRegisterTable extends StatelessWidget {
  final List<SignalReading> readings;

  const ReadingsRegisterTable({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Readings Register',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: readings.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final reading = readings[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        reading.label,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        reading.value != null
                            ? '${reading.value!.toStringAsFixed(1)} ${reading.unit}'
                            : '—',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        reading.timestamp != null
                            ? TimeUtils.formatAge(reading.timestamp!)
                            : 'Never',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: VerdictPill(verdict: reading.verdict),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
