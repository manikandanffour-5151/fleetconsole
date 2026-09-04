import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/repositories/trip_repository.dart';
import 'vehicle_detail_event.dart';
import 'vehicle_detail_state.dart';

class VehicleDetailBloc extends Bloc<VehicleDetailEvent, VehicleDetailState> {
  final VehicleRepository _vehicleRepository;
  final TripRepository _tripRepository;

  VehicleDetailBloc({
    VehicleRepository? vehicleRepository,
    TripRepository? tripRepository,
  })  : _vehicleRepository = vehicleRepository ?? VehicleRepository(),
        _tripRepository = tripRepository ?? TripRepository(),
        super(VehicleDetailInitialState()) {
    on<LoadVehicleDetailEvent>(_onLoadVehicleDetail);
  }

  Future<void> _onLoadVehicleDetail(
    LoadVehicleDetailEvent event,
    Emitter<VehicleDetailState> emit,
  ) async {
    emit(VehicleDetailLoadingState());
    try {
      final readings = await _vehicleRepository.getVehicleReadings(event.vehicleId);
      final socHistory = await _vehicleRepository.getSocHistory(event.vehicleId);
      final trips = await _tripRepository.getVehicleTrips(event.vehicleId);

      emit(VehicleDetailLoadedState(
        vehicleId: event.vehicleId,
        readings: readings,
        socHistory: socHistory,
        trips: trips,
      ));
    } catch (e) {
      emit(VehicleDetailErrorState('Failed to load vehicle details: $e'));
    }
  }
}
