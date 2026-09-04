import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../../logic/alert/alert_bloc.dart';
import '../../logic/alert/alert_event.dart';

class AlertDismissalSheet extends StatefulWidget {
  final String vehicleId;
  final String alertType;
  final String alertTitle;

  const AlertDismissalSheet({
    super.key,
    required this.vehicleId,
    required this.alertType,
    required this.alertTitle,
  });

  @override
  State<AlertDismissalSheet> createState() => _AlertDismissalSheetState();
}

class _AlertDismissalSheetState extends State<AlertDismissalSheet> {
  DismissalReason _selectedReason = DismissalReason.iAmOnIt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dismiss Alert: ${widget.alertTitle}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select a reason for dismissing this alert:',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Exact required order: "I am on it", "Wrong alert", "Something else..."
          RadioListTile<DismissalReason>(
            title: Text(DismissalReason.iAmOnIt.label),
            value: DismissalReason.iAmOnIt,
            groupValue: _selectedReason,
            onChanged: (val) {
              if (val != null) setState(() => _selectedReason = val);
            },
          ),
          RadioListTile<DismissalReason>(
            title: Text(DismissalReason.wrongAlert.label),
            value: DismissalReason.wrongAlert,
            groupValue: _selectedReason,
            onChanged: (val) {
              if (val != null) setState(() => _selectedReason = val);
            },
          ),
          RadioListTile<DismissalReason>(
            title: Text(DismissalReason.somethingElse.label),
            value: DismissalReason.somethingElse,
            groupValue: _selectedReason,
            onChanged: (val) {
              if (val != null) setState(() => _selectedReason = val);
            },
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<AlertBloc>().add(
                        DismissAlertEvent(
                          vehicleId: widget.vehicleId,
                          alertType: widget.alertType,
                          reason: _selectedReason,
                        ),
                      );
                  Navigator.pop(context);
                },
                child: const Text('Confirm Dismissal'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
