import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fleet_console/logic/alert/alert_bloc.dart';
import 'package:fleet_console/logic/alert/alert_event.dart';
import 'package:fleet_console/logic/alert/alert_state.dart';
import 'package:fleet_console/data/models/models.dart';
import 'package:fleet_console/data/repositories/alert_repository.dart';

class MockAlertRepository extends Fake implements AlertRepository {
  bool isDismissed = false;

  @override
  Future<List<Alert>> getActiveAlerts({String? vehicleId}) async {
    if (isDismissed) return [];
    return [
      Alert(
        id: 'alert_v_1_LOW_BATTERY',
        vehicleId: 'v_1',
        vehicleReg: 'KA-01-EV-1001',
        alertType: 'LOW_BATTERY',
        title: 'Low Battery',
        message: 'Battery SOC at 15%',
        severity: AlertSeverity.warning,
        triggeredValue: 15.0,
        timestamp: DateTime.now(),
      ),
    ];
  }

  @override
  Future<void> dismissAlert({
    required String vehicleId,
    required String alertType,
    required DismissalReason reason,
  }) async {
    isDismissed = true;
  }

  @override
  Future<void> undoDismissal({
    required String vehicleId,
    required String alertType,
  }) async {
    isDismissed = false;
  }
}

void main() {
  group('AlertBloc Tests', () {
    late AlertBloc alertBloc;
    late MockAlertRepository mockAlertRepo;

    setUp(() {
      mockAlertRepo = MockAlertRepository();
      alertBloc = AlertBloc(alertRepository: mockAlertRepo);
    });

    tearDown(() {
      alertBloc.close();
    });

    test('Initial state has no active alerts', () {
      expect(alertBloc.state.activeAlerts, isEmpty);
      expect(alertBloc.state.showUndoBanner, isFalse);
    });

    blocTest<AlertBloc, AlertState>(
      'Loads active alerts on LoadAlertsEvent',
      build: () => alertBloc,
      act: (bloc) => bloc.add(const LoadAlertsEvent()),
      verify: (bloc) {
        expect(bloc.state.activeAlerts.length, equals(1));
        expect(bloc.state.activeAlerts.first.alertType, equals('LOW_BATTERY'));
      },
    );

    blocTest<AlertBloc, AlertState>(
      'Handles alert dismissal and triggers 5s undo timer',
      build: () => alertBloc,
      act: (bloc) => bloc.add(const DismissAlertEvent(
        vehicleId: 'v_1',
        alertType: 'LOW_BATTERY',
        reason: DismissalReason.iAmOnIt,
      )),
      verify: (bloc) {
        expect(mockAlertRepo.isDismissed, isTrue);
        expect(bloc.state.undoSecondsRemaining, equals(5));
      },
    );
  });
}
