import 'package:flutter/material.dart';

class ReportBusSheet extends StatelessWidget {
  const ReportBusSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Takes minimum space needed
        children: [
          const Text(
            "Report Bus",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.directions_bus),
              label: const Text("Arrived Now", style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.schedule),
              label: const Text("Report Time", style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              icon: const Icon(Icons.report_problem),
              label: const Text("Report Delay", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
