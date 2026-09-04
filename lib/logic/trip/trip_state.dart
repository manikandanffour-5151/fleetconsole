import 'package:equatable/equatable.dart';

class TripState extends Equatable {
  final Map<String, String?> lastKnownGeofence;

  const TripState({this.lastKnownGeofence = const {}});

  TripState copyWith({Map<String, String?>? lastKnownGeofence}) {
    return TripState(
      lastKnownGeofence: lastKnownGeofence ?? this.lastKnownGeofence,
    );
  }

  @override
  List<Object?> get props => [lastKnownGeofence];
}
