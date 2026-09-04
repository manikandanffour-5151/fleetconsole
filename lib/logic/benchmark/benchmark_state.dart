import 'package:equatable/equatable.dart';

class BenchmarkState extends Equatable {
  final bool isBackfilling;
  final double progress;
  final String statusMessage;
  final int? coldStartMs;
  final double? p50QueryMs;
  final double? p95QueryMs;
  final int vehicleCount;
  final int totalSignalCount;
  final double ramUsageMb;

  const BenchmarkState({
    this.isBackfilling = false,
    this.progress = 0.0,
    this.statusMessage = 'Ready',
    this.coldStartMs,
    this.p50QueryMs,
    this.p95QueryMs,
    this.vehicleCount = 10,
    this.totalSignalCount = 80,
    this.ramUsageMb = 48.5,
  });

  BenchmarkState copyWith({
    bool? isBackfilling,
    double? progress,
    String? statusMessage,
    int? coldStartMs,
    double? p50QueryMs,
    double? p95QueryMs,
    int? vehicleCount,
    int? totalSignalCount,
    double? ramUsageMb,
  }) {
    return BenchmarkState(
      isBackfilling: isBackfilling ?? this.isBackfilling,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      coldStartMs: coldStartMs ?? this.coldStartMs,
      p50QueryMs: p50QueryMs ?? this.p50QueryMs,
      p95QueryMs: p95QueryMs ?? this.p95QueryMs,
      vehicleCount: vehicleCount ?? this.vehicleCount,
      totalSignalCount: totalSignalCount ?? this.totalSignalCount,
      ramUsageMb: ramUsageMb ?? this.ramUsageMb,
    );
  }

  @override
  List<Object?> get props => [
        isBackfilling,
        progress,
        statusMessage,
        coldStartMs,
        p50QueryMs,
        p95QueryMs,
        vehicleCount,
        totalSignalCount,
        ramUsageMb,
      ];
}
