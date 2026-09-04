import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../../core/database/database_service.dart';

class ScaleGenerator {
  final DatabaseService _dbService;

  ScaleGenerator({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  /// High-speed generator creating 500 vehicles and at least 2,000,000 signal rows.
  Future<void> generateScaleData({
    required Function(double progress, String status) onProgress,
    int vehicleCount = 500,
    int totalSignalRows = 2000000,
  }) async {
    final db = await _dbService.database;
    final random = Random(42); // deterministic seed
    final now = DateTime.now();

    onProgress(0.01, 'Clearing existing records...');
    await _dbService.clearDatabase();

    // 1. Re-seed 3 Geofences
    await db.insert('geofences', {
      'id': 'geo_central_hub',
      'name': 'Central Hub',
      'center_lat': 12.9716,
      'center_lng': 77.5946,
      'radius_meters': 500.0,
      'is_active': 1,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    await db.insert('geofences', {
      'id': 'geo_north_depot',
      'name': 'North Depot',
      'center_lat': 13.0827,
      'center_lng': 80.2707,
      'radius_meters': 1000.0,
      'is_active': 1,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    await db.insert('geofences', {
      'id': 'geo_south_station',
      'name': 'South Service Station',
      'center_lat': 12.2958,
      'center_lng': 76.6394,
      'radius_meters': 750.0,
      'is_active': 1,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    // 2. Insert 500 Vehicles
    onProgress(0.05, 'Inserting $vehicleCount vehicles...');
    var vehicleBatch = db.batch();
    final models = ['Tata Ace EV', 'Mahindra Zor Grand', 'Ashok Leyland BADA DOST', 'Eicher Pro 2055 EV'];

    for (int i = 1; i <= vehicleCount; i++) {
      final vId = 'v_$i';
      final regNum = 'KA-01-EV-${1000 + i}';
      final model = models[i % models.length];

      vehicleBatch.insert('vehicles', {
        'id': vId,
        'reg_number': regNum,
        'model': model,
        'created_at': now.toIso8601String(),
      });

      if (i % 100 == 0) {
        await vehicleBatch.commit(noResult: true);
        vehicleBatch = db.batch();
      }
    }
    await vehicleBatch.commit(noResult: true);

    // 3. Batch Insert 2,000,000 Signals
    onProgress(0.10, 'Generating $totalSignalRows signal rows...');
    const batchSize = 25000;
    int insertedRows = 0;
    final signalNames = ['soc', 'speed', 'battery_temp', 'ignition', 'lat', 'lng', 'range', 'odometer'];

    await db.transaction((txn) async {
      var batch = txn.batch();

      while (insertedRows < totalSignalRows) {
        final vIndex = (insertedRows % vehicleCount) + 1;
        final vId = 'v_$vIndex';
        final timeOffsetSeconds = random.nextInt(86400 * 7); // over last 7 days
        final timestamp = now.subtract(Duration(seconds: timeOffsetSeconds)).toIso8601String();
        final sigName = signalNames[random.nextInt(signalNames.length)];

        double sigValue;
        switch (sigName) {
          case 'soc':
            sigValue = 10.0 + random.nextDouble() * 85.0;
            break;
          case 'speed':
            sigValue = random.nextBool() ? 0.0 : (20.0 + random.nextDouble() * 60.0);
            break;
          case 'battery_temp':
            sigValue = 25.0 + random.nextDouble() * 25.0;
            break;
          case 'ignition':
            sigValue = random.nextDouble() > 0.3 ? 1.0 : 0.0;
            break;
          case 'lat':
            sigValue = 12.90 + random.nextDouble() * 0.20;
            break;
          case 'lng':
            sigValue = 77.50 + random.nextDouble() * 0.20;
            break;
          case 'range':
            sigValue = 20.0 + random.nextDouble() * 180.0;
            break;
          case 'odometer':
          default:
            sigValue = 5000.0 + random.nextDouble() * 20000.0;
            break;
        }

        batch.insert('telemetry_signals', {
          'id': 's_$insertedRows',
          'vehicle_id': vId,
          'packet_id': 'p_${insertedRows ~/ 8}',
          'signal_name': sigName,
          'signal_value': sigValue,
          'timestamp': timestamp,
          'received_at': timestamp,
        });

        insertedRows++;

        if (insertedRows % batchSize == 0) {
          await batch.commit(noResult: true);
          batch = txn.batch();

          final progress = 0.10 + (insertedRows / totalSignalRows) * 0.88;
          onProgress(progress, 'Inserted $insertedRows / $totalSignalRows rows (${(progress * 100).toInt()}%)');
        }
      }

      await batch.commit(noResult: true);
    });

    onProgress(1.0, 'Completed populating 500 vehicles and $totalSignalRows signal rows!');
  }
}
