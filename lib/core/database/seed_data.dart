import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class SeedDataLoader {
  static Future<void> seedIfEmpty() async {
    final db = await DatabaseService().database;

    final vehicleCountResult = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM vehicles'),
    );

    if (vehicleCountResult != null && vehicleCountResult > 0) {
      return; // Already seeded
    }

    final batch = db.batch();
    final now = DateTime.now();

    // 1. Seed 3 Circular Geofences
    batch.insert('geofences', {
      'id': 'geo_central_hub',
      'name': 'Central Hub',
      'center_lat': 12.9716,
      'center_lng': 77.5946,
      'radius_meters': 500.0,
      'is_active': 1,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    batch.insert('geofences', {
      'id': 'geo_north_depot',
      'name': 'North Depot',
      'center_lat': 13.0827,
      'center_lng': 80.2707,
      'radius_meters': 1000.0,
      'is_active': 1,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    batch.insert('geofences', {
      'id': 'geo_south_station',
      'name': 'South Service Station',
      'center_lat': 12.2958,
      'center_lng': 76.6394,
      'radius_meters': 750.0,
      'is_active': 1,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    // 2. Seed 10 Vehicles
    final sampleVehicles = [
      {'id': 'v_1', 'reg': 'KA-01-EV-1001', 'model': 'Tata Ace EV'},
      {'id': 'v_2', 'reg': 'KA-01-EV-1002', 'model': 'Mahindra Zor Grand'},
      {'id': 'v_3', 'reg': 'KA-01-EV-1003', 'model': 'Tata Ace EV'},
      {'id': 'v_4', 'reg': 'KA-01-EV-1004', 'model': 'Ashok Leyland BADA DOST'},
      {'id': 'v_5', 'reg': 'KA-01-EV-1005', 'model': 'Tata Ace EV'},
      {'id': 'v_6', 'reg': 'KA-01-EV-1006', 'model': 'Eicher Pro 2055 EV'},
      {'id': 'v_7', 'reg': 'KA-01-EV-1007', 'model': 'Mahindra Zor Grand'},
      {'id': 'v_8', 'reg': 'KA-01-EV-1008', 'model': 'Tata Ace EV'},
      {'id': 'v_9', 'reg': 'KA-01-EV-1009', 'model': 'Ashok Leyland BADA DOST'},
      {'id': 'v_10', 'reg': 'KA-01-EV-1010', 'model': 'Tata Ace EV'},
    ];

    for (var v in sampleVehicles) {
      batch.insert('vehicles', {
        'id': v['id'],
        'reg_number': v['reg'],
        'model': v['model'],
        'created_at': now.toIso8601String(),
      });
    }

    // 3. Seed Initial Telemetry Signals for the 10 vehicles
    // Scenario variations: Moving, Idle, Stopped, Offline, Low Battery, Overheating
    final initialTelemetry = [
      // v_1: MOVING (speed 45, ignition 1, SOC 75%, temp 32C, inside Central Hub)
      {'v': 'v_1', 'soc': 75.0, 'speed': 45.0, 'temp': 32.0, 'ign': 1.0, 'lat': 12.9716, 'lng': 77.5946, 'age_m': 1},
      // v_2: IDLE (speed 0, ignition 1, SOC 60%, temp 35C)
      {'v': 'v_2', 'soc': 60.0, 'speed': 0.0, 'temp': 35.0, 'ign': 1.0, 'lat': 12.9716, 'lng': 77.5946, 'age_m': 2},
      // v_3: STOPPED (speed 0, ignition 0, SOC 85%, temp 28C)
      {'v': 'v_3', 'soc': 85.0, 'speed': 0.0, 'temp': 28.0, 'ign': 0.0, 'lat': 13.0827, 'lng': 80.2707, 'age_m': 3},
      // v_4: OFFLINE (last ping 15m ago)
      {'v': 'v_4', 'soc': 40.0, 'speed': 0.0, 'temp': 30.0, 'ign': 0.0, 'lat': 12.9716, 'lng': 77.5946, 'age_m': 15},
      // v_5: LOW BATTERY ALERT (SOC 15% < 20%, speed 30, ignition 1)
      {'v': 'v_5', 'soc': 15.0, 'speed': 30.0, 'temp': 38.0, 'ign': 1.0, 'lat': 12.2958, 'lng': 76.6394, 'age_m': 1},
      // v_6: CRITICAL BATTERY ALERT (SOC 8% < 10%, speed 0, ignition 1)
      {'v': 'v_6', 'soc': 8.0, 'speed': 0.0, 'temp': 36.0, 'ign': 1.0, 'lat': 12.9716, 'lng': 77.5946, 'age_m': 1},
      // v_7: BATTERY OVERHEATING ALERT (temp 48C > 45C, SOC 50%, speed 50)
      {'v': 'v_7', 'soc': 50.0, 'speed': 50.0, 'temp': 48.0, 'ign': 1.0, 'lat': 13.0827, 'lng': 80.2707, 'age_m': 1},
      // v_8: MOVING (SOC 90%, speed 62, temp 31C)
      {'v': 'v_8', 'soc': 90.0, 'speed': 62.0, 'temp': 31.0, 'ign': 1.0, 'lat': 12.9716, 'lng': 77.5946, 'age_m': 2},
      // v_9: STOPPED (SOC 30%, speed 0, ignition 0)
      {'v': 'v_9', 'soc': 30.0, 'speed': 0.0, 'temp': 29.0, 'ign': 0.0, 'lat': 12.2958, 'lng': 76.6394, 'age_m': 4},
      // v_10: IDLE (SOC 55%, speed 0, ignition 1)
      {'v': 'v_10', 'soc': 55.0, 'speed': 0.0, 'temp': 33.0, 'ign': 1.0, 'lat': 12.9716, 'lng': 77.5946, 'age_m': 2},
    ];

    int packetCounter = 1;
    for (var t in initialTelemetry) {
      final vId = t['v'] as String;
      final ageMinutes = t['age_m'] as int;
      final time = now.subtract(Duration(minutes: ageMinutes));
      final packetId = 'pkt_$packetCounter';
      packetCounter++;

      final signals = {
        'soc': t['soc'],
        'speed': t['speed'],
        'battery_temp': t['temp'],
        'ignition': t['ign'],
        'lat': t['lat'],
        'lng': t['lng'],
        'range': (t['soc'] as double) * 2.2, // estimated range
        'odometer': 12450.0 + (ageMinutes * 2),
      };

      signals.forEach((sigName, sigValue) {
        batch.insert('telemetry_signals', {
          'id': 'sig_${vId}_${sigName}_${time.millisecondsSinceEpoch}',
          'vehicle_id': vId,
          'packet_id': packetId,
          'signal_name': sigName,
          'signal_value': (sigValue as num).toDouble(),
          'timestamp': time.toIso8601String(),
          'received_at': time.toIso8601String(),
        });
      });

      // Also generate 5 historical SOC entries for sparkline chart
      for (int h = 1; h <= 5; h++) {
        final hTime = time.subtract(Duration(hours: h));
        final hSoc = ((t['soc'] as double) + (h * 3.0)).clamp(0.0, 100.0);
        batch.insert('telemetry_signals', {
          'id': 'sig_${vId}_soc_hist_${hTime.millisecondsSinceEpoch}',
          'vehicle_id': vId,
          'packet_id': 'pkt_hist_$h',
          'signal_name': 'soc',
          'signal_value': hSoc,
          'timestamp': hTime.toIso8601String(),
          'received_at': hTime.toIso8601String(),
        });
      }
    }

    await batch.commit(noResult: true);
  }
}
