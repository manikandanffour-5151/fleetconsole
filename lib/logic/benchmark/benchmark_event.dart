import 'package:equatable/equatable.dart';

abstract class BenchmarkEvent extends Equatable {
  const BenchmarkEvent();

  @override
  List<Object?> get props => [];
}

class StartScaleBackfillEvent extends BenchmarkEvent {}

class RunBenchmarkQueriesEvent extends BenchmarkEvent {}

class RecordColdStartEvent extends BenchmarkEvent {
  final int durationMs;

  const RecordColdStartEvent(this.durationMs);

  @override
  List<Object?> get props => [durationMs];
}
