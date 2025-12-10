import 'package:flutter/material.dart';
import 'package:nextbus/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nextbus/common.dart';

class ReportBusSheet extends StatefulWidget {
  const ReportBusSheet({super.key});

  @override
  State<ReportBusSheet> createState() => _ReportBusSheetState();
}

class _ReportBusSheetState extends State<ReportBusSheet> {
  // 1. Loading State Variable
  bool _isLoading = false;

  Future<void> _submitReport(BuildContext context, String timeStr) async {
    // 2. Start Loading
    setState(() {
      _isLoading = true;
    });

    try {
      final routeProvider = Provider.of<RouteProvider>(context, listen: false);
      final timeProvider = Provider.of<TimetableProvider>(context, listen: false);

      // TODO: Replace "test" with the actual Stop ID or Bus Status if needed
      await timeProvider.updateTime(routeProvider.route, "test", timeStr);

      AppLogger.info('Reported: Route ${routeProvider.route} at $timeStr');
      if (!context.mounted) return;

      Navigator.pop(context);
      CustomSnackBar.show(context, 'Reported: Route ${routeProvider.route} at $timeStr');

    } catch (e) {
      // Handle errors gracefully (optional)
      if (context.mounted) {
        CustomSnackBar.show(context, 'Failed to report: $e');
        AppLogger.error('Failed to report', e);
        Navigator.pop(context);
      }
    } finally {
      // 3. Stop Loading (if the widget is still mounted and didn't pop)
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper widget for the M3 Spinner
  Widget _buildSpinner(BuildContext context, {bool onPrimary = true}) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        strokeCap: StrokeCap.round,
        color: onPrimary
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          // --- BUTTON 1: Arrived Now ---
          FilledButton.icon(
            onPressed: _isLoading
                ? null // Disable button while loading
                : () {
              String formattedTime = DateFormat('h:mm a').format(DateTime.now());
              _submitReport(context, formattedTime);
            },
            // Swap icon for spinner if loading
            icon: _isLoading
                ? _buildSpinner(context, onPrimary: true)
                : const Icon(Icons.directions_bus),
            label: Text(_isLoading ? "Sending..." : "Arrived Now",
                style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 15),

          // --- BUTTON 2: Report Time (Picker) ---
          FilledButton.tonalIcon(
            onPressed: _isLoading
                ? null
                : () async {
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

          // --- BUTTON 3: Request New Routes ---
          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton.tonalIcon(
              onPressed: _isLoading
                  ? null
                  : () {
                if (!context.mounted) return;
                CustomSnackBar.show(context, 'Will be added soon...');
                Navigator.pop(context);
              },
              icon: const Icon(Icons.report_problem),
              label: const Text("Request New Routes", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}