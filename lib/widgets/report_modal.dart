import 'package:flutter/material.dart';
import 'package:nextbus/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nextbus/common.dart';

class ReportBusSheet extends StatelessWidget {
  const ReportBusSheet({super.key});

  Future<void> _submitReport(BuildContext context, String timeStr) async {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    final timeProvider = Provider.of<TimetableProvider>(context, listen: false);

    // TODO: Replace "test" with the actual Stop ID or Bus Status if needed
    await timeProvider.updateTime(routeProvider.route, "test", timeStr);

    AppLogger.info('Reported: Route ${routeProvider.route} at $timeStr');
    if (!context.mounted) return;
    CustomSnackBar.show(context, 'Reported: Route ${routeProvider.route} at $timeStr');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Takes minimum space needed
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Report Bus",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 25),

          FilledButton.icon(
            onPressed: () {
              String formattedTime = DateFormat('h:mm a').format(DateTime.now());
              _submitReport(context, formattedTime);
            },
            icon: const Icon(Icons.directions_bus),
            label: const Text("Arrived Now", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 15),

          FilledButton.tonalIcon(
            onPressed: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                final DateTime now = DateTime.now();
                final DateTime dateTime = DateTime(now.year, now.month, now.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                final String formattedTime = DateFormat('h:mm a').format(dateTime);
                if (!context.mounted) return;
                _submitReport(context, formattedTime);
              }
            },
            icon: const Icon(Icons.schedule),
            label: const Text("Report Time", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 15),

          // SizedBox(
          //   width: double.infinity,
          //   height: 55,
          //   child: FilledButton.tonalIcon(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     style: FilledButton.styleFrom(
          //       backgroundColor: Theme.of(context).colorScheme.error,
          //       foregroundColor: Theme.of(context).colorScheme.onError,
          //     ),
          //     icon: const Icon(Icons.report_problem),
          //     label: const Text("Report Delay", style: TextStyle(fontSize: 16)),
          //   ),
          // ),
        ],
      ),
    );
  }
}
