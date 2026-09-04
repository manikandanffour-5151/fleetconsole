import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

abstract class FleetEvent extends Equatable {
  const FleetEvent();

  @override
  List<Object?> get props => [];
}

class LoadFleetEvent extends FleetEvent {
  final VehicleFilter filter;
  final String searchQuery;

  const LoadFleetEvent({
    this.filter = VehicleFilter.all,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [filter, searchQuery];
}

class FilterFleetEvent extends FleetEvent {
  final VehicleFilter filter;

  const FilterFleetEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchFleetEvent extends FleetEvent {
  final String query;

  const SearchFleetEvent(this.query);

  @override
  List<Object?> get props => [query];
}
