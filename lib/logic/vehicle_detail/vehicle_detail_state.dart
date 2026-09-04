import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

abstract class VehicleDetailState extends Equatable {
  const VehicleDetailState();

  @override
  List<Object?> get props => [];
}

class VehicleDetailInitialState extends VehicleDetailState {}

class VehicleDetailLoadingState extends VehicleDetailState {}

class VehicleDetailLoadedState extends VehicleDetailState {
  final String vehicleId;
  final List<SignalReading> readings;
  final List<SocDataPoint> socHistory;
  final List<Trip> trips;

  const VehicleDetailLoadedState({
    required this.vehicleId,
    required this.readings,
    required this.socHistory,
    required this.trips,
  });

  @override
  List<Object?> get props => [vehicleId, readings, socHistory, trips];
}

class VehicleDetailErrorState extends VehicleDetailState {
  final String message;

  const VehicleDetailErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
