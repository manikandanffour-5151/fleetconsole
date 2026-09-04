import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/database/seed_data.dart';
import 'logic/fleet/fleet_bloc.dart';
import 'logic/vehicle_detail/vehicle_detail_bloc.dart';
import 'logic/alert/alert_bloc.dart';
import 'logic/geofence/geofence_bloc.dart';
import 'logic/trip/trip_bloc.dart';
import 'logic/benchmark/benchmark_bloc.dart';
import 'logic/benchmark/benchmark_event.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/fleet_home/fleet_home_screen.dart';

void main() async {
  final stopwatch = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();

  // Seed database if empty
  await SeedDataLoader.seedIfEmpty();

  stopwatch.stop();
  final coldStartMs = stopwatch.elapsedMilliseconds;

  runApp(FleetConsoleApp(coldStartMs: coldStartMs));
}

class FleetConsoleApp extends StatelessWidget {
  final int coldStartMs;

  const FleetConsoleApp({super.key, required this.coldStartMs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FleetBloc>(create: (_) => FleetBloc()),
        BlocProvider<VehicleDetailBloc>(create: (_) => VehicleDetailBloc()),
        BlocProvider<AlertBloc>(create: (_) => AlertBloc()),
        BlocProvider<GeofenceBloc>(create: (_) => GeofenceBloc()),
        BlocProvider<TripBloc>(create: (_) => TripBloc()),
        BlocProvider<BenchmarkBloc>(
          create: (_) => BenchmarkBloc()..add(RecordColdStartEvent(coldStartMs)),
        ),
      ],
      child: MaterialApp(
        title: 'Fleet Console',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const FleetHomeScreen(),
      ),
    );
  }
}
