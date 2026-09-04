import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/database_service.dart';
import '../models/models.dart';

class AlertRepository {
  final DatabaseService _dbService;
  final Uuid _uuid = const Uuid();

  AlertRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  Future<List<Alert>> getActiveAlerts({String? vehicleId}) async {
    final db = await _dbService.database;

    // 1. Get dismissed alerts list
    final dismissedRows = await db.query('alert_dismissals');
    final Set<String> dismissedKeys = {};
    for (var r in dismissedRows) {
      final vId = r['vehicle_id'] as String;
      final type = r['alert_type'] as String;
      dismissedKeys.add('${vId}_$type');
    }

    // 2. Query latest SOC and battery_temp signals for vehicles
    String whereClause = "WHERE signal_name IN ('soc', 'battery_temp')";
    List<dynamic> whereArgs = [];
    if (vehicleId != null) {
      whereClause += " AND vehicle_id = ?";
      whereArgs.add(vehicleId);
    }

    final query = '''
      WITH latest_signals AS (
        SELECT 
          ts.vehicle_id,
          v.reg_number,
          ts.signal_name,
          ts.signal_value,
          ts.timestamp,
          ROW_NUMBER() OVER (PARTITION BY ts.vehicle_id, ts.signal_name ORDER BY ts.timestamp DESC) as rn
        FROM telemetry_signals ts
        JOIN vehicles v ON ts.vehicle_id = v.id
        $whereClause
      )
      SELECT vehicle_id, reg_number, signal_name, signal_value, timestamp
      FROM latest_signals
      WHERE rn = 1;
    ''';

    final rows = await db.rawQuery(query, whereArgs);
    final List<Alert> activeAlerts = [];
    final now = DateTime.now();

    for (var r in rows) {
      final vId = r['vehicle_id'] as String;
      final reg = r['reg_number'] as String;
      final sName = r['signal_name'] as String;
      final val = (r['signal_value'] as num).toDouble();
      final timestamp = DateTime.parse(r['timestamp'] as String);

      // Ignore signals older than 10 minutes (stale signals cannot claim active alert)
      if (now.difference(timestamp).inMinutes > 10) {
        continue;
      }

      // Check Battery Alert (single escalating alert for SOC < 20% and < 10%)
      if (sName == 'soc' && val < 20.0) {
        const alertType = 'LOW_BATTERY';
        final isDismissed = dismissedKeys.contains('${vId}_$alertType');

        if (!isDismissed) {
          final isCritical = val < 10.0;
          activeAlerts.add(Alert(
            id: 'alert_${vId}_$alertType',
            vehicleId: vId,
            vehicleReg: reg,
            alertType: alertType,
            title: isCritical ? 'Battery Critically Low' : 'Low Battery',
            message: 'Vehicle battery SOC is at ${val.toStringAsFixed(1)}%',
            severity: isCritical ? AlertSeverity.critical : AlertSeverity.warning,
            triggeredValue: val,
            timestamp: timestamp,
          ));
        }
      }

      // Check Battery Overheating Alert
      if (sName == 'battery_temp' && val > 45.0) {
        const alertType = 'BATTERY_OVERHEATING';
        final isDismissed = dismissedKeys.contains('${vId}_$alertType');

        if (!isDismissed) {
          activeAlerts.add(Alert(
            id: 'alert_${vId}_$alertType',
            vehicleId: vId,
            vehicleReg: reg,
            alertType: alertType,
            title: 'Battery Overheating',
            message: 'Battery temperature reached ${val.toStringAsFixed(1)}°C',
            severity: AlertSeverity.critical,
            triggeredValue: val,
            timestamp: timestamp,
          ));
        }
      }
    }

    return activeAlerts;
  }

  Future<void> dismissAlert({
    required String vehicleId,
    required String alertType,
    required DismissalReason reason,
  }) async {
    final db = await _dbService.database;
    await db.insert(
      'alert_dismissals',
      {
        'id': _uuid.v4(),
        'vehicle_id': vehicleId,
        'alert_type': alertType,
        'reason': reason.name,
        'dismissed_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> undoDismissal({
    required String vehicleId,
    required String alertType,
  }) async {
    final db = await _dbService.database;
    await db.delete(
      'alert_dismissals',
      where: 'vehicle_id = ? AND alert_type = ?',
      whereArgs: [vehicleId, alertType],
    );
  }
}
