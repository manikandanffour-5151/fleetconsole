class AppSchema {
  static const String createVehiclesTable = '''
    CREATE TABLE IF NOT EXISTS vehicles (
      id TEXT PRIMARY KEY,
      reg_number TEXT NOT NULL,
      model TEXT NOT NULL,
      created_at TEXT NOT NULL
    );
  ''';

  static const String createTelemetrySignalsTable = '''
    CREATE TABLE IF NOT EXISTS telemetry_signals (
      id TEXT PRIMARY KEY,
      vehicle_id TEXT NOT NULL,
      packet_id TEXT NOT NULL,
      signal_name TEXT NOT NULL,
      signal_value REAL NOT NULL,
      timestamp TEXT NOT NULL,
      received_at TEXT NOT NULL,
      FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
    );
  ''';

  static const String createSignalVehicleTimeIndex = '''
    CREATE INDEX IF NOT EXISTS idx_signals_vehicle_time 
    ON telemetry_signals (vehicle_id, timestamp DESC);
  ''';

  static const String createSignalNameTimeIndex = '''
    CREATE INDEX IF NOT EXISTS idx_signals_name_time 
    ON telemetry_signals (signal_name, timestamp DESC);
  ''';

  static const String createGeofencesTable = '''
    CREATE TABLE IF NOT EXISTS geofences (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      center_lat REAL NOT NULL,
      center_lng REAL NOT NULL,
      radius_meters REAL NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const String createTripsTable = '''
    CREATE TABLE IF NOT EXISTS trips (
      id TEXT PRIMARY KEY,
      vehicle_id TEXT NOT NULL,
      origin_geofence_id TEXT NOT NULL,
      destination_geofence_id TEXT,
      start_time TEXT NOT NULL,
      end_time TEXT,
      status TEXT NOT NULL,
      distance_km REAL DEFAULT 0.0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
    );
  ''';

  static const String createTripVehicleStatusIndex = '''
    CREATE INDEX IF NOT EXISTS idx_trips_vehicle_status 
    ON trips (vehicle_id, status);
  ''';

  static const String createAlertDismissalsTable = '''
    CREATE TABLE IF NOT EXISTS alert_dismissals (
      id TEXT PRIMARY KEY,
      vehicle_id TEXT NOT NULL,
      alert_type TEXT NOT NULL,
      reason TEXT NOT NULL,
      dismissed_at TEXT NOT NULL,
      expires_at TEXT
    );
  ''';
}
