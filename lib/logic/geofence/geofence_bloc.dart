import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/geofence_repository.dart';
import 'geofence_event.dart';
import 'geofence_state.dart';

class GeofenceBloc extends Bloc<GeofenceEvent, GeofenceState> {
  final GeofenceRepository _geofenceRepository;

  GeofenceBloc({GeofenceRepository? geofenceRepository})
      : _geofenceRepository = geofenceRepository ?? GeofenceRepository(),
        super(GeofenceInitialState()) {
    on<LoadGeofencesEvent>(_onLoadGeofences);
    on<SaveGeofenceEvent>(_onSaveGeofence);
    on<ToggleGeofenceActiveEvent>(_onToggleActive);
  }

  Future<void> _onLoadGeofences(LoadGeofencesEvent event, Emitter<GeofenceState> emit) async {
    emit(GeofenceLoadingState());
    try {
      final geofences = await _geofenceRepository.getGeofences();
      final counts = await _geofenceRepository.getVehicleCountsPerGeofence();
      emit(GeofenceLoadedState(geofences: geofences, vehicleCounts: counts));
    } catch (e) {
      emit(GeofenceErrorState('Failed to load geofences: $e'));
    }
  }

  Future<void> _onSaveGeofence(SaveGeofenceEvent event, Emitter<GeofenceState> emit) async {
    try {
      await _geofenceRepository.saveGeofence(event.geofence);
      add(LoadGeofencesEvent());
    } catch (e) {
      emit(GeofenceErrorState('Failed to save geofence: $e'));
    }
  }

  Future<void> _onToggleActive(ToggleGeofenceActiveEvent event, Emitter<GeofenceState> emit) async {
    try {
      await _geofenceRepository.toggleGeofenceActive(event.id, event.isActive);
      add(LoadGeofencesEvent());
    } catch (e) {
      emit(GeofenceErrorState('Failed to toggle geofence: $e'));
    }
  }
}
