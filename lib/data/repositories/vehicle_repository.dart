import 'package:sqflite/sqflite.dart';
import '../../core/database/database_service.dart';
import '../models/models.dart';

class VehicleRepository {
  final DatabaseService _dbService;

  VehicleRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  Future<List<SignalReading>> getVehicleReadings(String vehicleId) async {
    final db = await _dbService.database;

    final query = '''
      WITH latest_signals AS (
        SELECT 
          signal_name,
          signal_value,
          timestamp,
          ROW_NUMBER() OVER (PARTITION BY signal_name ORDER BY timestamp DESC) as rn
        FROM telemetry_signals
        WHERE vehicle_id = ?
      )
      SELECT signal_name, signal_value, timestamp
      FROM latest_signals
      WHERE rn = 1;
    ''';

    final rows = await db.rawQuery(query, [vehicleId]);
    final Map<String, Map<String, dynamic>> latestMap = {};

    for (var r in rows) {
      latestMap[r['signal_name'] as String] = {
        'value': (r['signal_value'] as num).toDouble(),
        'timestamp': DateTime.parse(r['timestamp'] as String),
      };
    }

    // Standard signals list
    final signalDefinitions = [
      {'name': 'soc', 'label': 'State of Charge (SOC)', 'unit': '%'},
      {'name': 'range', 'label': 'Estimated Range', 'unit': 'km'},
      {'name': 'speed', 'label': 'Vehicle Speed', 'unit': 'km/h'},
      {'name': 'battery_temp', 'label': 'Battery Temperature', 'unit': '°C'},
      {'name': 'odometer', 'label': 'Lifetime Odometer', 'unit': 'km'},
      {'name': 'last_ping', 'label': 'Last Telemetry Ping', 'unit': ''},
    ];

    final List<SignalReading> readings = [];
    final now = DateTime.now();

    for (var def in signalDefinitions) {
      final sName = def['name'] as String;
      final sLabel = def['label'] as String;
      final sUnit = def['unit'] as String;

      final data = latestMap[sName];

      if (data == null) {
        readings.add(SignalReading(
          name: sName,
          label: sLabel,
          unit: sUnit,
          verdict: SignalVerdict.unreported,
        ));
        continue;
      }

      final timestamp = data['timestamp'] as DateTime;
      final value = data['value'] as double;
      final ageMinutes = now.difference(timestamp).inMinutes;

      SignalVerdict verdict;
      if (ageMinutes > 10) {
        verdict = SignalVerdict.stale;
      } else if (sName == 'soc' && value < 20.0) {
        verdict = SignalVerdict.alert;
      } else if (sName == 'battery_temp' && value > 45.0) {
        verdict = SignalVerdict.alert;
      } else {
        verdict = SignalVerdict.normal;
      }

      readings.add(SignalReading(
        name: sName,
        label: sLabel,
        value: value,
        unit: sUnit,
        timestamp: timestamp,
        verdict: verdict,
      ));
    }

    return readings;
  }

  Future<List<SocDataPoint>> getSocHistory(String vehicleId, {int limit = 30}) async {
    final db = await _dbService.database;

    final query = '''
      SELECT signal_value, timestamp
      FROM telemetry_signals
      WHERE vehicle_id = ? AND signal_name = 'soc'
      ORDER BY timestamp DESC
      LIMIT ?;
    ''';

    final rows = await db.rawQuery(query, [vehicleId, limit]);
    final List<SocDataPoint> history = [];

    for (var r in rows.reversed) { // chronological order
      history.add(SocDataPoint(
        timestamp: DateTime.parse(r['timestamp'] as String),
        soc: (r['signal_value'] as num).toDouble(),
      ));
    }

    return history;
  }
}
