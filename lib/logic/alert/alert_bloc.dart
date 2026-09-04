import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/alert_repository.dart';
import 'alert_event.dart';
import 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertRepository _alertRepository;
  Timer? _undoTimer;

  AlertBloc({AlertRepository? alertRepository})
      : _alertRepository = alertRepository ?? AlertRepository(),
        super(const AlertState()) {
    on<LoadAlertsEvent>(_onLoadAlerts);
    on<DismissAlertEvent>(_onDismissAlert);
    on<UndoDismissalEvent>(_onUndoDismissal);
    on<TickUndoTimerEvent>(_onTickUndoTimer);
  }

  Future<void> _onLoadAlerts(LoadAlertsEvent event, Emitter<AlertState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final alerts = await _alertRepository.getActiveAlerts(vehicleId: event.vehicleId);
      emit(state.copyWith(activeAlerts: alerts, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load alerts: $e'));
    }
  }

  Future<void> _onDismissAlert(DismissAlertEvent event, Emitter<AlertState> emit) async {
    try {
      await _alertRepository.dismissAlert(
        vehicleId: event.vehicleId,
        alertType: event.alertType,
        reason: event.reason,
      );

      _startUndoTimer();

      emit(state.copyWith(
        lastDismissedVehicleId: event.vehicleId,
        lastDismissedAlertType: event.alertType,
        undoSecondsRemaining: 5,
      ));

      add(LoadAlertsEvent(vehicleId: event.vehicleId));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to dismiss alert: $e'));
    }
  }

  Future<void> _onUndoDismissal(UndoDismissalEvent event, Emitter<AlertState> emit) async {
    _undoTimer?.cancel();
    try {
      await _alertRepository.undoDismissal(
        vehicleId: event.vehicleId,
        alertType: event.alertType,
      );

      emit(state.copyWith(
        lastDismissedVehicleId: null,
        lastDismissedAlertType: null,
        undoSecondsRemaining: 0,
      ));

      add(LoadAlertsEvent(vehicleId: event.vehicleId));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to undo dismissal: $e'));
    }
  }

  void _onTickUndoTimer(TickUndoTimerEvent event, Emitter<AlertState> emit) {
    if (event.remainingSeconds <= 0) {
      _undoTimer?.cancel();
      emit(state.copyWith(
        lastDismissedVehicleId: null,
        lastDismissedAlertType: null,
        undoSecondsRemaining: 0,
      ));
    } else {
      emit(state.copyWith(undoSecondsRemaining: event.remainingSeconds));
    }
  }

  void _startUndoTimer() {
    _undoTimer?.cancel();
    int seconds = 5;
    _undoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      add(TickUndoTimerEvent(seconds));
    });
  }

  @override
  Future<void> close() {
    _undoTimer?.cancel();
    return super.close();
  }
}
