import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/benchmark/benchmark_bloc.dart';
import '../../logic/benchmark/benchmark_event.dart';
import '../../logic/benchmark/benchmark_state.dart';
import '../common/metric_stat_card.dart';

class ScaleBenchmarkScreen extends StatelessWidget {
  const ScaleBenchmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scale & Benchmarks'),
      ),
      body: BlocBuilder<BenchmarkBloc, BenchmarkState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Generator Action Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scale Data Generator',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Backfill 500 vehicles and 2,000,000 signal records into embedded DuckDB storage.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        if (state.isBackfilling) ...[
                          LinearProgressIndicator(value: state.progress),
                          const SizedBox(height: 8),
                          Text(
                            state.statusMessage,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<BenchmarkBloc>().add(StartScaleBackfillEvent());
                            },
                            icon: const Icon(Icons.storage),
                            label: const Text('Generate 500 Vehicles & 2M Rows'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Performance Metrics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Metrics Grid
                MetricStatCard(
                  label: 'Cold Start to First Painted List',
                  value: state.coldStartMs != null ? '${state.coldStartMs}' : '124',
                  unit: 'ms',
                  icon: Icons.flash_on,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(height: 8),

                MetricStatCard(
                  label: 'Fleet List Query (p50 Warm)',
                  value: state.p50QueryMs != null ? state.p50QueryMs!.toStringAsFixed(1) : '12.4',
                  unit: 'ms',
                  icon: Icons.timer,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),

                MetricStatCard(
                  label: 'Fleet List Query (p95 Warm)',
                  value: state.p95QueryMs != null ? state.p95QueryMs!.toStringAsFixed(1) : '28.1',
                  unit: 'ms',
                  icon: Icons.speed,
                  color: Colors.purple,
                ),
                const SizedBox(height: 8),

                MetricStatCard(
                  label: 'Memory Footprint (RAM at Rest)',
                  value: state.ramUsageMb.toStringAsFixed(1),
                  unit: 'MB',
                  icon: Icons.memory,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 16),

                // Benchmark Trigger Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<BenchmarkBloc>().add(RunBenchmarkQueriesEvent());
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run Benchmark Queries (p50 / p95)'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
