import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/vehicle_detail/vehicle_detail_bloc.dart';
import '../../logic/vehicle_detail/vehicle_detail_event.dart';
import '../../logic/vehicle_detail/vehicle_detail_state.dart';
import '../../logic/alert/alert_bloc.dart';
import '../../logic/alert/alert_event.dart';
import '../../logic/alert/alert_state.dart';
import '../alerts/alert_dismissal_sheet.dart';
import 'active_alert_card.dart';
import 'readings_register_table.dart';
import 'soc_history_chart.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VehicleDetailBloc>().add(LoadVehicleDetailEvent(widget.vehicleId));
    context.read<AlertBloc>().add(LoadAlertsEvent(vehicleId: widget.vehicleId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Detail (${widget.vehicleId})'),
      ),
      body: BlocBuilder<VehicleDetailBloc, VehicleDetailState>(
        builder: (context, state) {
          if (state is VehicleDetailLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VehicleDetailLoadedState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Alerts Section
                  BlocBuilder<AlertBloc, AlertState>(
                    builder: (context, alertState) {
                      final vehicleAlerts = alertState.activeAlerts
                          .where((a) => a.vehicleId == widget.vehicleId)
                          .toList();

                      if (vehicleAlerts.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Alerts',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...vehicleAlerts.map(
                            (alert) => ActiveAlertCard(
                              alert: alert,
                              onDismiss: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => AlertDismissalSheet(
                                    vehicleId: alert.vehicleId,
                                    alertType: alert.alertType,
                                    alertTitle: alert.title,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),

                  // Readings Register Table
                  ReadingsRegisterTable(readings: state.readings),
                  const SizedBox(height: 16),

                  // SOC History Trend
                  SocHistoryChart(history: state.socHistory),
                  const SizedBox(height: 16),

                  // Vehicle Trips Section
                  if (state.trips.isNotEmpty) ...[
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Trip History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.trips.length,
                              separatorBuilder: (_, __) => const Divider(height: 16),
                              itemBuilder: (context, index) {
                                final trip = state.trips[index];
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${trip.originGeofenceName} → ${trip.destinationGeofenceName ?? "In Transit"}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Distance: ${trip.distanceKm.toStringAsFixed(1)} km',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: trip.status == 'COMPLETED'
                                            ? Colors.green.shade100
                                            : Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        trip.status,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: trip.status == 'COMPLETED'
                                              ? Colors.green.shade800
                                              : Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          } else if (state is VehicleDetailErrorState) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
