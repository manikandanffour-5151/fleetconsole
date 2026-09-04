import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fleet_console/logic/trip/trip_bloc.dart';
import 'package:fleet_console/logic/trip/trip_event.dart';
import 'package:fleet_console/logic/trip/trip_state.dart';
import 'package:fleet_console/data/models/models.dart';
import 'package:fleet_console/data/repositories/trip_repository.dart';

class MockTripRepository extends Fake implements TripRepository {
  bool tripStarted = false;
  bool tripCompleted = false;

  @override
  Future<void> startTrip({
    required String vehicleId,
    required String originGeofenceId,
    required DateTime startTime,
  }) async {
    tripStarted = true;
  }

  @override
  Future<void> completeActiveTrip({
    required String vehicleId,
    required String destinationGeofenceId,
    required DateTime endTime,
    double distanceKm = 12.5,
  }) async {
    tripCompleted = true;
  }
}

void main() {
  group('TripBloc Tests', () {
    late TripBloc tripBloc;
    late MockTripRepository mockTripRepo;

    setUp(() {
      mockTripRepo = MockTripRepository();
      tripBloc = TripBloc(tripRepository: mockTripRepo);
    });

    tearDown(() {
      tripBloc.close();
    });

    test('Initial lastKnownGeofence state is empty', () {
      expect(tripBloc.state.lastKnownGeofence, isEmpty);
    });

    blocTest<TripBloc, TripState>(
      'Starts trip on geofence exit (prev = geo1, curr = null)',
      build: () => tripBloc,
      seed: () => const TripState(lastKnownGeofence: {'v_1': 'geo_central_hub'}),
      act: (bloc) => bloc.add(EvaluateTransitionEvent(
        vehicleId: 'v_1',
        currentGeofenceId: null,
        timestamp: DateTime.now(),
      )),
      verify: (bloc) {
        expect(mockTripRepo.tripStarted, isTrue);
        expect(bloc.state.lastKnownGeofence['v_1'], isNull);
      },
    );

    blocTest<TripBloc, TripState>(
      'Completes active trip on geofence entry (prev = null, curr = geo2)',
      build: () => tripBloc,
      seed: () => const TripState(lastKnownGeofence: {'v_1': null}),
      act: (bloc) => bloc.add(EvaluateTransitionEvent(
        vehicleId: 'v_1',
        currentGeofenceId: 'geo_north_depot',
        timestamp: DateTime.now(),
      )),
      verify: (bloc) {
        expect(mockTripRepo.tripCompleted, isTrue);
        expect(bloc.state.lastKnownGeofence['v_1'], equals('geo_north_depot'));
      },
    );
  });
}
