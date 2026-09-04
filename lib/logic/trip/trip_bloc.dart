import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trip_repository.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository _tripRepository;

  TripBloc({TripRepository? tripRepository})
      : _tripRepository = tripRepository ?? TripRepository(),
        super(const TripState()) {
    on<EvaluateTransitionEvent>(_onEvaluateTransition);
  }

  Future<void> _onEvaluateTransition(
    EvaluateTransitionEvent event,
    Emitter<TripState> emit,
  ) async {
    final prevGeo = state.lastKnownGeofence[event.vehicleId];
    final currGeo = event.currentGeofenceId;

    if (prevGeo != currGeo) {
      // 1. Exit Event: Vehicle was inside a geofence and now is outside
      if (prevGeo != null && currGeo == null) {
        await _tripRepository.startTrip(
          vehicleId: event.vehicleId,
          originGeofenceId: prevGeo,
          startTime: event.timestamp,
        );
      }
      // 2. Entry Event: Vehicle entered a new geofence
      else if (currGeo != null) {
        await _tripRepository.completeActiveTrip(
          vehicleId: event.vehicleId,
          destinationGeofenceId: currGeo,
          endTime: event.timestamp,
        );
      }

      final updatedMap = Map<String, String?>.from(state.lastKnownGeofence);
      updatedMap[event.vehicleId] = currGeo;
      emit(state.copyWith(lastKnownGeofence: updatedMap));
    }
  }
}
