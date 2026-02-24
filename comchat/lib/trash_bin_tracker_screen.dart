import 'package:flutter/material.dart';

class TrashBinTrackerScreen extends StatefulWidget {
  const TrashBinTrackerScreen({super.key});

  @override
  State<TrashBinTrackerScreen> createState() => _TrashBinTrackerScreenState();
}

class _TrashBinTrackerScreenState extends State<TrashBinTrackerScreen> {
  final int _year = DateTime.now().year;
  late final List<DateTime> _pickupDates;
  
  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _pickupDates = _getPickupDatesForYear(_year);
  }

  List<DateTime> _getPickupDatesForYear(int year) {
    final pickups = <DateTime>[];
    final changeDate = DateTime.now().add(const Duration(days: 14));

    final firstDayOfYear = DateTime(year, 1, 1);
    // Handle leap years correctly for the last day.
    final lastDayOfYear = DateTime(year + 1, 1, 0);

    for (var day = firstDayOfYear; day.isBefore(lastDayOfYear.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
      bool isPickupDay;
      if (day.isBefore(changeDate)) {
        isPickupDay = day.weekday == DateTime.tuesday;
      } else {
        isPickupDay = day.weekday == DateTime.thursday;
      }
      if (isPickupDay) {
        pickups.add(day);
      }
    }
    return pickups;
  }

  @override
  Widget build(BuildContext context) {
    final totalPickups = _pickupDates.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trash Pickups for $_year'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text('Total: $totalPickups pickups', style: Theme.of(context).textTheme.bodyMedium),
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          return _buildMonth(context, _year, month, _pickupDates);
        },
      ),
    );
  }

  Widget _buildMonth(BuildContext context, int year, int month, List<DateTime> pickupDates) {
    final pickupsInMonth = pickupDates.where((d) => d.year == year && d.month == month).toList();
    
    final firstOfMonth = DateTime(year, month, 1);
    final weekdayOffset = firstOfMonth.weekday % 7; // Sunday (7) -> 0
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    final cells = <Widget>[];
    const weekdayLabels = ['S','M','T','W','T','F','S'];
    for (final w in weekdayLabels) {
      cells.add(Center(child: Text(w, style: const TextStyle(fontWeight: FontWeight.bold))));
    }

    for (int i = 0; i < weekdayOffset; i++) {
      cells.add(Container());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final dt = DateTime(year, month, day);
      final isPickup = pickupsInMonth.any((d) => d.day == dt.day);
      
      cells.add(
        Container(
          alignment: Alignment.center,
          decoration: isPickup
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                )
              : null,
          child: Text(
            '$day',
            style: TextStyle(
              fontWeight: isPickup ? FontWeight.bold : FontWeight.normal,
              color: isPickup ? Theme.of(context).colorScheme.onPrimary : null,
            ),
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_monthNames[month - 1]} - ${pickupsInMonth.length} pickups',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: cells,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
