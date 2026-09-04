import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class EvaluateTransitionEvent extends TripEvent {
  final String vehicleId;
  final String? currentGeofenceId;
  final DateTime timestamp;

  const EvaluateTransitionEvent({
    required this.vehicleId,
    required this.currentGeofenceId,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [vehicleId, currentGeofenceId, timestamp];
}
