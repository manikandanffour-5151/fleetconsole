import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/models.dart';

class GeofenceFormSheet extends StatefulWidget {
  final Function(Geofence) onSave;

  const GeofenceFormSheet({super.key, required this.onSave});

  @override
  State<GeofenceFormSheet> createState() => _GeofenceFormSheetState();
}

class _GeofenceFormSheetState extends State<GeofenceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController(text: '12.9716');
  final _lngController = TextEditingController(text: '77.5946');
  double _radiusMeters = 500;

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Circular Geofence',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Geofence Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(labelText: 'Center Latitude'),
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(labelText: 'Center Longitude'),
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Radius: ${_radiusMeters.toInt()} meters'),
            Slider(
              value: _radiusMeters,
              min: 100,
              max: 5000,
              divisions: 49,
              label: '${_radiusMeters.toInt()}m',
              onChanged: (v) => setState(() => _radiusMeters = v),
            ),
            const SizedBox(height: 16),
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
                    if (_formKey.currentState!.validate()) {
                      final newGeo = Geofence(
                        id: 'geo_${const Uuid().v4()}',
                        name: _nameController.text.trim(),
                        centerLat: double.parse(_latController.text),
                        centerLng: double.parse(_lngController.text),
                        radiusMeters: _radiusMeters,
                        isActive: true,
                        createdAt: DateTime.now(),
                      );
                      widget.onSave(newGeo);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Geofence'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
