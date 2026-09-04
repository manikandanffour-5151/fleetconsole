import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../../data/repositories/fleet_repository.dart';
import 'fleet_event.dart';
import 'fleet_state.dart';

class FleetBloc extends Bloc<FleetEvent, FleetState> {
  final FleetRepository _fleetRepository;

  FleetBloc({FleetRepository? fleetRepository})
      : _fleetRepository = fleetRepository ?? FleetRepository(),
        super(FleetInitialState()) {
    on<LoadFleetEvent>(_onLoadFleet);
    on<FilterFleetEvent>(_onFilterFleet);
    on<SearchFleetEvent>(_onSearchFleet);
  }

  Future<void> _onLoadFleet(LoadFleetEvent event, Emitter<FleetState> emit) async {
    emit(FleetLoadingState());
    try {
      final vehicles = await _fleetRepository.getVehicles(
        filter: event.filter,
        searchQuery: event.searchQuery,
      );
      final counts = await _fleetRepository.getFilterCounts();

      emit(FleetLoadedState(
        vehicles: vehicles,
        currentFilter: event.filter,
        filterCounts: counts,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      emit(FleetErrorState('Failed to load fleet data: $e'));
    }
  }

  Future<void> _onFilterFleet(FilterFleetEvent event, Emitter<FleetState> emit) async {
    final currentState = state;
    String search = '';
    if (currentState is FleetLoadedState) {
      search = currentState.searchQuery;
    }
    add(LoadFleetEvent(filter: event.filter, searchQuery: search));
  }

  Future<void> _onSearchFleet(SearchFleetEvent event, Emitter<FleetState> emit) async {
    final currentState = state;
    VehicleFilter filter = VehicleFilter.all;
    if (currentState is FleetLoadedState) {
      filter = currentState.currentFilter;
    }
    add(LoadFleetEvent(filter: filter, searchQuery: event.query));
  }
}
