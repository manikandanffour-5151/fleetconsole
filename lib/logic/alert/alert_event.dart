import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlertsEvent extends AlertEvent {
  final String? vehicleId;

  const LoadAlertsEvent({this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}

class DismissAlertEvent extends AlertEvent {
  final String vehicleId;
  final String alertType;
  final DismissalReason reason;

  const DismissAlertEvent({
    required this.vehicleId,
    required this.alertType,
    required this.reason,
  });

  @override
  List<Object?> get props => [vehicleId, alertType, reason];
}

class UndoDismissalEvent extends AlertEvent {
  final String vehicleId;
  final String alertType;

  const UndoDismissalEvent({
    required this.vehicleId,
    required this.alertType,
  });

  @override
  List<Object?> get props => [vehicleId, alertType];
}

class TickUndoTimerEvent extends AlertEvent {
  final int remainingSeconds;

  const TickUndoTimerEvent(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}
