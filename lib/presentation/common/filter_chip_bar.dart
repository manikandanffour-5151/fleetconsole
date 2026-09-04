import 'package:flutter/material.dart';
import '../../data/models/models.dart';

class FilterChipBar extends StatelessWidget {
  final VehicleFilter selectedFilter;
  final Map<VehicleFilter, int> counts;
  final ValueChanged<VehicleFilter> onFilterSelected;

  const FilterChipBar({
    super.key,
    required this.selectedFilter,
    required this.counts,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'filter': VehicleFilter.all, 'label': 'All'},
      {'filter': VehicleFilter.moving, 'label': 'Moving'},
      {'filter': VehicleFilter.idle, 'label': 'Idle'},
      {'filter': VehicleFilter.stopped, 'label': 'Stopped'},
      {'filter': VehicleFilter.offline, 'label': 'Offline'},
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filters[index];
          final filter = item['filter'] as VehicleFilter;
          final label = item['label'] as String;
          final count = counts[filter] ?? 0;
          final isSelected = selectedFilter == filter;

          return ChoiceChip(
            selected: isSelected,
            label: Text('$label ($count)'),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.grey.shade200,
            onSelected: (_) => onFilterSelected(filter),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
