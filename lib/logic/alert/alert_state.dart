import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

class AlertState extends Equatable {
  final List<Alert> activeAlerts;
  final bool isLoading;
  final String? errorMessage;
  final String? lastDismissedVehicleId;
  final String? lastDismissedAlertType;
  final int undoSecondsRemaining;

  const AlertState({
    this.activeAlerts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastDismissedVehicleId,
    this.lastDismissedAlertType,
    this.undoSecondsRemaining = 0,
  });

  bool get showUndoBanner => undoSecondsRemaining > 0 && lastDismissedVehicleId != null;

  AlertState copyWith({
    List<Alert>? activeAlerts,
    bool? isLoading,
    String? errorMessage,
    String? lastDismissedVehicleId,
    String? lastDismissedAlertType,
    int? undoSecondsRemaining,
  }) {
    return AlertState(
      activeAlerts: activeAlerts ?? this.activeAlerts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastDismissedVehicleId: lastDismissedVehicleId ?? this.lastDismissedVehicleId,
      lastDismissedAlertType: lastDismissedAlertType ?? this.lastDismissedAlertType,
      undoSecondsRemaining: undoSecondsRemaining ?? this.undoSecondsRemaining,
    );
  }

  @override
  List<Object?> get props => [
        activeAlerts,
        isLoading,
        errorMessage,
        lastDismissedVehicleId,
        lastDismissedAlertType,
        undoSecondsRemaining,
      ];
}
