import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/fleet/fleet_bloc.dart';
import '../../logic/fleet/fleet_event.dart';
import '../../logic/fleet/fleet_state.dart';
import '../../logic/alert/alert_bloc.dart';
import '../../logic/alert/alert_event.dart';
import '../../logic/alert/alert_state.dart';
import '../common/filter_chip_bar.dart';
import '../common/empty_state_widget.dart';
import '../vehicle_detail/vehicle_detail_screen.dart';
import '../geofences/geofences_screen.dart';
import '../benchmark/scale_benchmark_screen.dart';
import 'vehicle_tile.dart';

class FleetHomeScreen extends StatefulWidget {
  const FleetHomeScreen({super.key});

  @override
  State<FleetHomeScreen> createState() => _FleetHomeScreenState();
}

class _FleetHomeScreenState extends State<FleetHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FleetBloc>().add(const LoadFleetEvent());
    context.read<AlertBloc>().add(const LoadAlertsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.directions_bus, color: Colors.blue),
            SizedBox(width: 8),
            Text('Fleet Console'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Geofences',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GeofencesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.speed),
            tooltip: 'Scale & Benchmarks',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScaleBenchmarkScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<FleetBloc>().add(const LoadFleetEvent());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by registration number or model...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<FleetBloc>().add(const SearchFleetEvent(''));
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                context.read<FleetBloc>().add(SearchFleetEvent(query));
              },
            ),
          ),

          // Filter Chip Bar
          BlocBuilder<FleetBloc, FleetState>(
            builder: (context, state) {
              if (state is FleetLoadedState) {
                return FilterChipBar(
                  selectedFilter: state.currentFilter,
                  counts: state.filterCounts,
                  onFilterSelected: (filter) {
                    context.read<FleetBloc>().add(FilterFleetEvent(filter));
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Vehicle List or States
          Expanded(
            child: BlocBuilder<FleetBloc, FleetState>(
              builder: (context, state) {
                if (state is FleetLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FleetLoadedState) {
                  if (state.vehicles.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.search_off,
                      title: 'No Vehicles Found',
                      message: 'No vehicles match your selected filter or search query.',
                    );
                  }

                  return ListView.builder(
                    itemCount: state.vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = state.vehicles[index];
                      return VehicleTile(
                        vehicle: vehicle,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VehicleDetailScreen(vehicleId: vehicle.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (state is FleetErrorState) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<AlertBloc, AlertState>(
        builder: (context, state) {
          if (state.showUndoBanner) {
            return Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alert dismissed (${state.undoSecondsRemaining}s)',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AlertBloc>().add(UndoDismissalEvent(
                            vehicleId: state.lastDismissedVehicleId!,
                            alertType: state.lastDismissedAlertType!,
                          ));
                    },
                    child: const Text(
                      'UNDO',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
