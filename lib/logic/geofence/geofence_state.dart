import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

abstract class GeofenceState extends Equatable {
  const GeofenceState();

  @override
  List<Object?> get props => [];
}

class GeofenceInitialState extends GeofenceState {}

class GeofenceLoadingState extends GeofenceState {}

class GeofenceLoadedState extends GeofenceState {
  final List<Geofence> geofences;
  final Map<String, int> vehicleCounts;

  const GeofenceLoadedState({
    required this.geofences,
    required this.vehicleCounts,
  });

  @override
  List<Object?> get props => [geofences, vehicleCounts];
}

class GeofenceErrorState extends GeofenceState {
  final String message;

  const GeofenceErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
