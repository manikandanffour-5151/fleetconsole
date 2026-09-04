import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

abstract class FleetState extends Equatable {
  const FleetState();

  @override
  List<Object?> get props => [];
}

class FleetInitialState extends FleetState {}

class FleetLoadingState extends FleetState {}

class FleetLoadedState extends FleetState {
  final List<VehicleSummary> vehicles;
  final VehicleFilter currentFilter;
  final Map<VehicleFilter, int> filterCounts;
  final String searchQuery;

  const FleetLoadedState({
    required this.vehicles,
    required this.currentFilter,
    required this.filterCounts,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [vehicles, currentFilter, filterCounts, searchQuery];
}

class FleetErrorState extends FleetState {
  final String message;

  const FleetErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
