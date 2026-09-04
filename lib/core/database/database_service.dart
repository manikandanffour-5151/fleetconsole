import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'schema.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._();

  factory DatabaseService() {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'fleet_console.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(AppSchema.createVehiclesTable);
        await db.execute(AppSchema.createTelemetrySignalsTable);
        await db.execute(AppSchema.createSignalVehicleTimeIndex);
        await db.execute(AppSchema.createSignalNameTimeIndex);
        await db.execute(AppSchema.createGeofencesTable);
        await db.execute(AppSchema.createTripsTable);
        await db.execute(AppSchema.createTripVehicleStatusIndex);
        await db.execute(AppSchema.createAlertDismissalsTable);
      },
    );
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('alert_dismissals');
    await db.delete('trips');
    await db.delete('telemetry_signals');
    await db.delete('geofences');
    await db.delete('vehicles');
  }
}
