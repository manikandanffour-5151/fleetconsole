import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/database_service.dart';
import '../../core/utils/distance_utils.dart';
import '../models/models.dart';

class GeofenceRepository {
  final DatabaseService _dbService;
  final Uuid _uuid = const Uuid();

  GeofenceRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  Future<List<Geofence>> getGeofences() async {
    final db = await _dbService.database;
    final rows = await db.query('geofences', orderBy: 'created_at DESC');
    return rows.map((r) => Geofence.fromMap(r)).toList();
  }

  Future<void> saveGeofence(Geofence geofence) async {
    final db = await _dbService.database;
    await db.insert(
      'geofences',
      geofence.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> toggleGeofenceActive(String id, bool isActive) async {
    final db = await _dbService.database;
    await db.update(
      'geofences',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getVehicleCountsPerGeofence() async {
    final db = await _dbService.database;
    final geofences = await getGeofences();

    // Query latest lat/lng location for each vehicle
    final query = '''
      WITH latest_coords AS (
        SELECT 
          vehicle_id,
          MAX(CASE WHEN signal_name = 'lat' THEN signal_value END) as lat,
          MAX(CASE WHEN signal_name = 'lng' THEN signal_value END) as lng
        FROM telemetry_signals
        GROUP BY vehicle_id
      )
      SELECT vehicle_id, lat, lng FROM latest_coords WHERE lat IS NOT NULL AND lng IS NOT NULL;
    ''';

    final rows = await db.rawQuery(query);
    final Map<String, int> counts = {for (var g in geofences) g.id: 0};

    for (var r in rows) {
      final lat = (r['lat'] as num).toDouble();
      final lng = (r['lng'] as num).toDouble();

      for (var g in geofences) {
        if (g.isActive && DistanceUtils.isInsideGeofence(lat, lng, g.centerLat, g.centerLng, g.radiusMeters)) {
          counts[g.id] = (counts[g.id] ?? 0) + 1;
        }
      }
    }

    return counts;
  }
}
