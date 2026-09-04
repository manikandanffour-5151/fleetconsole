import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/fleet_repository.dart';
import '../../data/scale/scale_generator.dart';
import 'benchmark_event.dart';
import 'benchmark_state.dart';

class BenchmarkBloc extends Bloc<BenchmarkEvent, BenchmarkState> {
  final ScaleGenerator _scaleGenerator;
  final FleetRepository _fleetRepository;

  BenchmarkBloc({
    ScaleGenerator? scaleGenerator,
    FleetRepository? fleetRepository,
  })  : _scaleGenerator = scaleGenerator ?? ScaleGenerator(),
        _fleetRepository = fleetRepository ?? FleetRepository(),
        super(const BenchmarkState()) {
    on<StartScaleBackfillEvent>(_onStartBackfill);
    on<RunBenchmarkQueriesEvent>(_onRunBenchmarkQueries);
    on<RecordColdStartEvent>(_onRecordColdStart);
  }

  Future<void> _onStartBackfill(
    StartScaleBackfillEvent event,
    Emitter<BenchmarkState> emit,
  ) async {
    emit(state.copyWith(
      isBackfilling: true,
      progress: 0.0,
      statusMessage: 'Starting scale backfill...',
    ));

    try {
      await _scaleGenerator.generateScaleData(
        onProgress: (p, msg) {
          add(RunBenchmarkQueriesEvent()); // update state counts
        },
      );

      emit(state.copyWith(
        isBackfilling: false,
        progress: 1.0,
        statusMessage: 'Completed populating 500 vehicles & 2M rows!',
        vehicleCount: 500,
        totalSignalCount: 2000000,
      ));

      add(RunBenchmarkQueriesEvent());
    } catch (e) {
      emit(state.copyWith(
        isBackfilling: false,
        statusMessage: 'Error during backfill: $e',
      ));
    }
  }

  Future<void> _onRunBenchmarkQueries(
    RunBenchmarkQueriesEvent event,
    Emitter<BenchmarkState> emit,
  ) async {
    final List<double> latencies = [];

    // Run fleet query 10 times to measure p50 and p95
    for (int i = 0; i < 10; i++) {
      final stopwatch = Stopwatch()..start();
      await _fleetRepository.getVehicles();
      stopwatch.stop();
      latencies.add(stopwatch.elapsedMicroseconds / 1000.0); // ms
    }

    latencies.sort();
    final p50 = latencies[(latencies.length * 0.50).floor()];
    final p95 = latencies[(latencies.length * 0.95).floor().clamp(0, latencies.length - 1)];

    emit(state.copyWith(
      p50QueryMs: p50,
      p95QueryMs: p95,
    ));
  }

  void _onRecordColdStart(
    RecordColdStartEvent event,
    Emitter<BenchmarkState> emit,
  ) {
    emit(state.copyWith(coldStartMs: event.durationMs));
  }
}
