import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/Providers/providers.dart' show TimetableProvider;

class TimetableDisplay extends StatelessWidget {
  final String route;
  const TimetableDisplay({super.key, required this.route});

  String secTomin(int sec) {
    final duration = Duration(seconds: sec);
    // Get total minutes as a double
    double minutes = duration.inMinutes.toDouble() + (duration.inSeconds % 60) / 60.0;
    return minutes.toStringAsFixed(2);
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, timetableProvider, child) {
        if (timetableProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final timetable = timetableProvider.timetables[route];
        AppLogger.info("Timetable for route $route");
        if (timetable == null || timetable.isEmpty) {
          return const Center(child: Text('No timetable data available.'));
        }
        return ListView.builder(
          itemCount: timetable.length,
          itemBuilder: (context, index) {
            final entry = timetable[index];
            final stopName = entry['stop'];
            final timing = entry['time'];
            final delay = "${secTomin(entry['delay'] as int)} mins";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                subtitle: Text(stopName),
                title: Text('Arrival: $timing', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('Delay: $delay'),
              ),
            );
          },
        );
      },
    );
  }
}
