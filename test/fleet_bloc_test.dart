import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fleet_console/logic/fleet/fleet_bloc.dart';
import 'package:fleet_console/logic/fleet/fleet_event.dart';
import 'package:fleet_console/logic/fleet/fleet_state.dart';
import 'package:fleet_console/data/models/models.dart';
import 'package:fleet_console/data/repositories/fleet_repository.dart';

class MockFleetRepository extends Fake implements FleetRepository {
  @override
  Future<List<VehicleSummary>> getVehicles({
    VehicleFilter filter = VehicleFilter.all,
    String searchQuery = '',
  }) async {
    final list = [
      const VehicleSummary(
        id: 'v_1',
        regNumber: 'KA-01-EV-1001',
        model: 'Tata Ace EV',
        status: VehicleStatus.moving,
        soc: 80.0,
      ),
      const VehicleSummary(
        id: 'v_2',
        regNumber: 'KA-01-EV-1002',
        model: 'Mahindra Zor',
        status: VehicleStatus.stopped,
        soc: 50.0,
      ),
    ];

    if (filter == VehicleFilter.moving) {
      return list.where((v) => v.status == VehicleStatus.moving).toList();
    }
    return list;
  }

  @override
  Future<Map<VehicleFilter, int>> getFilterCounts() async {
    return {
      VehicleFilter.all: 2,
      VehicleFilter.moving: 1,
      VehicleFilter.idle: 0,
      VehicleFilter.stopped: 1,
      VehicleFilter.offline: 0,
    };
  }
}

void main() {
  group('FleetBloc Tests', () {
    late FleetBloc fleetBloc;
    late MockFleetRepository mockRepo;

    setUp(() {
      mockRepo = MockFleetRepository();
      fleetBloc = FleetBloc(fleetRepository: mockRepo);
    });

    tearDown(() {
      fleetBloc.close();
    });

    test('Initial state is FleetInitialState', () {
      expect(fleetBloc.state, equals(FleetInitialState()));
    });

    blocTest<FleetBloc, FleetState>(
      'Emits [FleetLoadingState, FleetLoadedState] when LoadFleetEvent is added',
      build: () => fleetBloc,
      act: (bloc) => bloc.add(const LoadFleetEvent()),
      expect: () => [
        FleetLoadingState(),
        const FleetLoadedState(
          vehicles: [
            VehicleSummary(
              id: 'v_1',
              regNumber: 'KA-01-EV-1001',
              model: 'Tata Ace EV',
              status: VehicleStatus.moving,
              soc: 80.0,
            ),
            VehicleSummary(
              id: 'v_2',
              regNumber: 'KA-01-EV-1002',
              model: 'Mahindra Zor',
              status: VehicleStatus.stopped,
              soc: 50.0,
            ),
          ],
          currentFilter: VehicleFilter.all,
          filterCounts: {
            VehicleFilter.all: 2,
            VehicleFilter.moving: 1,
            VehicleFilter.idle: 0,
            VehicleFilter.stopped: 1,
            VehicleFilter.offline: 0,
          },
        ),
      ],
    );

    blocTest<FleetBloc, FleetState>(
      'Filters fleet when FilterFleetEvent is added',
      build: () => fleetBloc,
      act: (bloc) => bloc.add(const FilterFleetEvent(VehicleFilter.moving)),
      expect: () => [
        FleetLoadingState(),
        const FleetLoadedState(
          vehicles: [
            VehicleSummary(
              id: 'v_1',
              regNumber: 'KA-01-EV-1001',
              model: 'Tata Ace EV',
              status: VehicleStatus.moving,
              soc: 80.0,
            ),
          ],
          currentFilter: VehicleFilter.moving,
          filterCounts: {
            VehicleFilter.all: 2,
            VehicleFilter.moving: 1,
            VehicleFilter.idle: 0,
            VehicleFilter.stopped: 1,
            VehicleFilter.offline: 0,
          },
        ),
      ],
    );
  });
}
