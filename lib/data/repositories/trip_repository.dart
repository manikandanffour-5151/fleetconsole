import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/database_service.dart';
import '../models/models.dart';

class TripRepository {
  final DatabaseService _dbService;
  final Uuid _uuid = const Uuid();

  TripRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  Future<List<Trip>> getVehicleTrips(String vehicleId) async {
    final db = await _dbService.database;

    final query = '''
      SELECT 
        t.id,
        t.vehicle_id,
        t.origin_geofence_id,
        g_orig.name as origin_name,
        t.destination_geofence_id,
        g_dest.name as destination_name,
        t.start_time,
        t.end_time,
        t.status,
        t.distance_km
      FROM trips t
      LEFT JOIN geofences g_orig ON t.origin_geofence_id = g_orig.id
      LEFT JOIN geofences g_dest ON t.destination_geofence_id = g_dest.id
      WHERE t.vehicle_id = ?
      ORDER BY t.start_time DESC;
    ''';

    final rows = await db.rawQuery(query, [vehicleId]);
    final List<Trip> trips = [];

    for (var r in rows) {
      trips.add(Trip(
        id: r['id'] as String,
        vehicleId: r['vehicle_id'] as String,
        originGeofenceId: r['origin_geofence_id'] as String,
        originGeofenceName: (r['origin_name'] as String?) ?? 'Unknown Origin',
        destinationGeofenceId: r['destination_geofence_id'] as String?,
        destinationGeofenceName: r['destination_name'] as String?,
        startTime: DateTime.parse(r['start_time'] as String),
        endTime: r['end_time'] != null ? DateTime.parse(r['end_time'] as String) : null,
        status: r['status'] as String,
        distanceKm: (r['distance_km'] as num?)?.toDouble() ?? 0.0,
      ));
    }

    return trips;
  }

  Future<void> startTrip({
    required String vehicleId,
    required String originGeofenceId,
    required DateTime startTime,
  }) async {
    final db = await _dbService.database;

    // Ensure no active trip exists for this vehicle
    final activeTripCount = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM trips WHERE vehicle_id = ? AND status = 'IN_PROGRESS'",
      [vehicleId],
    ));

    if (activeTripCount != null && activeTripCount > 0) {
      return; // Vehicle already has an active trip
    }

    await db.insert('trips', {
      'id': _uuid.v4(),
      'vehicle_id': vehicleId,
      'origin_geofence_id': originGeofenceId,
      'start_time': startTime.toIso8601String(),
      'status': 'IN_PROGRESS',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> completeActiveTrip({
    required String vehicleId,
    required String destinationGeofenceId,
    required DateTime endTime,
    double distanceKm = 12.5,
  }) async {
    final db = await _dbService.database;

    final activeTripRows = await db.query(
      'trips',
      where: "vehicle_id = ? AND status = 'IN_PROGRESS'",
      whereArgs: [vehicleId],
      limit: 1,
    );

    if (activeTripRows.isEmpty) return;

    final tripId = activeTripRows.first['id'] as String;

    await db.update(
      'trips',
      {
        'destination_geofence_id': destinationGeofenceId,
        'end_time': endTime.toIso8601String(),
        'status': 'COMPLETED',
        'distance_km': distanceKm,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }
}
