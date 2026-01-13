import 'package:flutter/material.dart';
import 'package:nextbus/common.dart' show AppLogger;
import 'package:provider/provider.dart' show Consumer;
import 'package:nextbus/providers/providers.dart' show TimetableProvider;

class TimetableDisplay extends StatelessWidget {
  final String route;
  const TimetableDisplay({super.key, required this.route});

  // Helper to format delay and return a status color
  (String, Color) _getDelayInfo(num seconds) {
    double minutes = seconds / 60.0;
    if (seconds <= 0) return ("On Time", Colors.green.shade700);
    if (seconds < 180) return ("${minutes.toStringAsFixed(1)}m late", Colors.orange.shade700);
    return ("${minutes.toStringAsFixed(1)}m late", Colors.red.shade700);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, timetableProvider, child) {
        if (timetableProvider.isLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 3));
        }

        final timetable = timetableProvider.timetables[route];

        if (timetable == null || timetable.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bus_alert, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('No timetable data available',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: timetable.length,
          itemBuilder: (context, index) {
            final entry = timetable[index];
            final (delayText, delayColor) = _getDelayInfo(entry['delay'] as num);
            final bool isLast = index == timetable.length - 1;

            return IntrinsicHeight(
              child: Row(
                children: [
                  // --- Timeline Indicator Column ---
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // --- Content Card ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            // border: Border(left: BorderSide(color: delayColor, width: 4)),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry['stop'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Arrival: ${entry['time']}",
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: delayColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    delayText,
                                    style: TextStyle(
                                      color: delayColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}