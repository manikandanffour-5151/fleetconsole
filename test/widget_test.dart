import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fleet_console/logic/fleet/fleet_bloc.dart';
import 'package:fleet_console/logic/alert/alert_bloc.dart';
import 'package:fleet_console/presentation/fleet_home/fleet_home_screen.dart';
import 'fleet_bloc_test.dart';
import 'alert_bloc_test.dart';

void main() {
  testWidgets('FleetHomeScreen renders App Title', (WidgetTester tester) async {
    final mockFleetRepo = MockFleetRepository();
    final mockAlertRepo = MockAlertRepository();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<FleetBloc>(create: (_) => FleetBloc(fleetRepository: mockFleetRepo)),
          BlocProvider<AlertBloc>(create: (_) => AlertBloc(alertRepository: mockAlertRepo)),
        ],
        child: const MaterialApp(
          home: FleetHomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Fleet Console'), findsOneWidget);
  });
}
