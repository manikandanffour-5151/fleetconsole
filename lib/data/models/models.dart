import 'package:equatable/equatable.dart';

enum VehicleStatus { offline, moving, idle, stopped }

enum VehicleFilter { all, moving, idle, stopped, offline }

enum SignalVerdict { normal, alert, stale, unreported }

enum AlertSeverity { warning, critical }

enum DismissalReason {
  iAmOnIt('I am on it'),
  wrongAlert('Wrong alert'),
  somethingElse('Something else...');

  final String label;
  const DismissalReason(this.label);
}

class VehicleSummary extends Equatable {
  final String id;
  final String regNumber;
  final String model;
  final VehicleStatus status;
  final double? soc;
  final double? rangeKm;
  final DateTime? lastPing;
  final String? currentGeofenceName;
  final int activeAlertCount;

  const VehicleSummary({
    required this.id,
    required this.regNumber,
    required this.model,
    required this.status,
    this.soc,
    this.rangeKm,
    this.lastPing,
    this.currentGeofenceName,
    this.activeAlertCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        regNumber,
        model,
        status,
        soc,
        rangeKm,
        lastPing,
        currentGeofenceName,
        activeAlertCount,
      ];
}

class SignalReading extends Equatable {
  final String name;
  final String label;
  final double? value;
  final String unit;
  final DateTime? timestamp;
  final SignalVerdict verdict;

  const SignalReading({
    required this.name,
    required this.label,
    this.value,
    required this.unit,
    this.timestamp,
    required this.verdict,
  });

  @override
  List<Object?> get props => [name, label, value, unit, timestamp, verdict];
}

class SocDataPoint extends Equatable {
  final DateTime timestamp;
  final double soc;

  const SocDataPoint({required this.timestamp, required this.soc});

  @override
  List<Object?> get props => [timestamp, soc];
}

class Geofence extends Equatable {
  final String id;
  final String name;
  final double centerLat;
  final double centerLng;
  final double radiusMeters;
  final bool isActive;
  final DateTime createdAt;

  const Geofence({
    required this.id,
    required this.name,
    required this.centerLat,
    required this.centerLng,
    required this.radiusMeters,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'center_lat': centerLat,
      'center_lng': centerLng,
      'radius_meters': radiusMeters,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory Geofence.fromMap(Map<String, dynamic> map) {
    return Geofence(
      id: map['id'] as String,
      name: map['name'] as String,
      centerLat: (map['center_lat'] as num).toDouble(),
      centerLng: (map['center_lng'] as num).toDouble(),
      radiusMeters: (map['radius_meters'] as num).toDouble(),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, name, centerLat, centerLng, radiusMeters, isActive, createdAt];
}

class Alert extends Equatable {
  final String id;
  final String vehicleId;
  final String vehicleReg;
  final String alertType; // 'LOW_BATTERY' or 'BATTERY_OVERHEATING'
  final String title;
  final String message;
  final AlertSeverity severity;
  final double triggeredValue;
  final DateTime timestamp;

  const Alert({
    required this.id,
    required this.vehicleId,
    required this.vehicleReg,
    required this.alertType,
    required this.title,
    required this.message,
    required this.severity,
    required this.triggeredValue,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        vehicleReg,
        alertType,
        title,
        message,
        severity,
        triggeredValue,
        timestamp,
      ];
}

class Trip extends Equatable {
  final String id;
  final String vehicleId;
  final String originGeofenceId;
  final String originGeofenceName;
  final String? destinationGeofenceId;
  final String? destinationGeofenceName;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'IN_PROGRESS' or 'COMPLETED'
  final double distanceKm;

  const Trip({
    required this.id,
    required this.vehicleId,
    required this.originGeofenceId,
    required this.originGeofenceName,
    this.destinationGeofenceId,
    this.destinationGeofenceName,
    required this.startTime,
    this.endTime,
    required this.status,
    this.distanceKm = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        originGeofenceId,
        originGeofenceName,
        destinationGeofenceId,
        destinationGeofenceName,
        startTime,
        endTime,
        status,
        distanceKm,
      ];
}
