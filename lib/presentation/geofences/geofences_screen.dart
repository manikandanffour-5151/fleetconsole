import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/geofence/geofence_bloc.dart';
import '../../logic/geofence/geofence_event.dart';
import '../../logic/geofence/geofence_state.dart';
import 'geofence_card.dart';
import 'geofence_form_sheet.dart';

class GeofencesScreen extends StatefulWidget {
  const GeofencesScreen({super.key});

  @override
  State<GeofencesScreen> createState() => _GeofencesScreenState();
}

class _GeofencesScreenState extends State<GeofencesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GeofenceBloc>().add(LoadGeofencesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence Management'),
      ),
      body: BlocBuilder<GeofenceBloc, GeofenceState>(
        builder: (context, state) {
          if (state is GeofenceLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GeofenceLoadedState) {
            if (state.geofences.isEmpty) {
              return const Center(child: Text('No geofences created yet.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.geofences.length,
              itemBuilder: (context, index) {
                final geofence = state.geofences[index];
                final count = state.vehicleCounts[geofence.id] ?? 0;

                return GeofenceCard(
                  geofence: geofence,
                  vehicleCount: count,
                  onToggleActive: (val) {
                    context.read<GeofenceBloc>().add(
                          ToggleGeofenceActiveEvent(geofence.id, val),
                        );
                  },
                );
              },
            );
          } else if (state is GeofenceErrorState) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => GeofenceFormSheet(
              onSave: (newGeo) {
                context.read<GeofenceBloc>().add(SaveGeofenceEvent(newGeo));
              },
            ),
          );
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Geofence'),
      ),
    );
  }
}
