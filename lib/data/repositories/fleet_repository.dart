import 'package:sqflite/sqflite.dart';
import '../../core/database/database_service.dart';
import '../models/models.dart';

class FleetRepository {
  final DatabaseService _dbService;

  FleetRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  Future<List<VehicleSummary>> getVehicles({
    VehicleFilter filter = VehicleFilter.all,
    String searchQuery = '',
  }) async {
    final db = await _dbService.database;
    final nowIso = DateTime.now().toIso8601String();

    // SQL query aggregating latest telemetry values for each vehicle and evaluating status chip
    final query = '''
      WITH latest_signals AS (
        SELECT 
          vehicle_id,
          signal_name,
          signal_value,
          timestamp,
          ROW_NUMBER() OVER (PARTITION BY vehicle_id, signal_name ORDER BY timestamp DESC) as rn
        FROM telemetry_signals
      ),
      vehicle_states AS (
        SELECT 
          v.id,
          v.reg_number,
          v.model,
          MAX(CASE WHEN ls.signal_name = 'soc' AND ls.rn = 1 THEN ls.signal_value END) as soc,
          MAX(CASE WHEN ls.signal_name = 'range' AND ls.rn = 1 THEN ls.signal_value END) as range_km,
          MAX(CASE WHEN ls.signal_name = 'speed' AND ls.rn = 1 THEN ls.signal_value END) as latest_speed,
          MAX(CASE WHEN ls.signal_name = 'ignition' AND ls.rn = 1 THEN ls.signal_value END) as latest_ignition,
          MAX(ls.timestamp) as last_ping,
          (CAST(strftime('%s', '$nowIso') AS INTEGER) - CAST(strftime('%s', MAX(ls.timestamp)) AS INTEGER)) as age_seconds
        FROM vehicles v
        LEFT JOIN latest_signals ls ON v.id = ls.vehicle_id
        GROUP BY v.id, v.reg_number, v.model
      )
      SELECT 
        id,
        reg_number,
        model,
        soc,
        range_km,
        last_ping,
        CASE 
          WHEN age_seconds IS NULL OR age_seconds > 600 THEN 'OFFLINE'
          WHEN latest_speed > 0 THEN 'MOVING'
          WHEN latest_speed = 0 AND latest_ignition = 1 THEN 'IDLE'
          WHEN latest_ignition = 0 THEN 'STOPPED'
          ELSE 'OFFLINE'
        END AS computed_status
      FROM vehicle_states
      ORDER BY reg_number ASC;
    ''';

    final rows = await db.rawQuery(query);
    final List<VehicleSummary> results = [];

    for (var row in rows) {
      final statusStr = row['computed_status'] as String;
      final status = _parseVehicleStatus(statusStr);

      // Apply filter
      if (!_matchesFilter(status, filter)) {
        continue;
      }

      // Apply search query
      final reg = row['reg_number'] as String;
      final model = row['model'] as String;
      if (searchQuery.isNotEmpty &&
          !reg.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !model.toLowerCase().contains(searchQuery.toLowerCase())) {
        continue;
      }

      final lastPingStr = row['last_ping'] as String?;
      final lastPing = lastPingStr != null ? DateTime.tryParse(lastPingStr) : null;

      results.add(VehicleSummary(
        id: row['id'] as String,
        regNumber: reg,
        model: model,
        status: status,
        soc: (row['soc'] as num?)?.toDouble(),
        rangeKm: (row['range_km'] as num?)?.toDouble(),
        lastPing: lastPing,
      ));
    }

    return results;
  }

  Future<Map<VehicleFilter, int>> getFilterCounts() async {
    final allVehicles = await getVehicles(filter: VehicleFilter.all);

    int moving = 0;
    int idle = 0;
    int stopped = 0;
    int offline = 0;

    for (var v in allVehicles) {
      switch (v.status) {
        case VehicleStatus.moving:
          moving++;
          break;
        case VehicleStatus.idle:
          idle++;
          break;
        case VehicleStatus.stopped:
          stopped++;
          break;
        case VehicleStatus.offline:
          offline++;
          break;
      }
    }

    return {
      VehicleFilter.all: allVehicles.length,
      VehicleFilter.moving: moving,
      VehicleFilter.idle: idle,
      VehicleFilter.stopped: stopped,
      VehicleFilter.offline: offline,
    };
  }

  VehicleStatus _parseVehicleStatus(String statusStr) {
    switch (statusStr) {
      case 'MOVING':
        return VehicleStatus.moving;
      case 'IDLE':
        return VehicleStatus.idle;
      case 'STOPPED':
        return VehicleStatus.stopped;
      case 'OFFLINE':
      default:
        return VehicleStatus.offline;
    }
  }

  bool _matchesFilter(VehicleStatus status, VehicleFilter filter) {
    switch (filter) {
      case VehicleFilter.all:
        return true;
      case VehicleFilter.moving:
        return status == VehicleStatus.moving;
      case VehicleFilter.idle:
        return status == VehicleStatus.idle;
      case VehicleFilter.stopped:
        return status == VehicleStatus.stopped;
      case VehicleFilter.offline:
        return status == VehicleStatus.offline;
    }
  }
}
