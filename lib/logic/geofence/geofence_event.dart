import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

abstract class GeofenceEvent extends Equatable {
  const GeofenceEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeofencesEvent extends GeofenceEvent {}

class SaveGeofenceEvent extends GeofenceEvent {
  final Geofence geofence;

  const SaveGeofenceEvent(this.geofence);

  @override
  List<Object?> get props => [geofence];
}

class ToggleGeofenceActiveEvent extends GeofenceEvent {
  final String id;
  final bool isActive;

  const ToggleGeofenceActiveEvent(this.id, this.isActive);

  @override
  List<Object?> get props => [id, isActive];
}
