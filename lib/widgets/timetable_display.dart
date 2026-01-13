import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextbus/common.dart';
import 'package:provider/provider.dart' show Consumer, Provider;
import 'package:nextbus/providers/providers.dart' show TimetableProvider;

class TimetableDisplay extends StatefulWidget {
  final String route;
  const TimetableDisplay({super.key, required this.route});

  @override
  State<TimetableDisplay> createState() => _TimetableDisplayState();
}

class _TimetableDisplayState extends State<TimetableDisplay> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Executes after the build method to ensure the list is rendered before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScrollToNow();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _autoScrollToNow() {
    final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
    final timetable = timetableProvider.timetables[widget.route] ?? [];

    int nowIndex = timetable.indexWhere((entry) => !_isPast(entry['time']));

    if (nowIndex != -1 && _scrollController.hasClients) {
      // 116.0 is the approximate height of one card including padding
      double offset = nowIndex * 100;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  (String, Color) _getDelayInfo(num seconds, bool departed, ColorScheme colors) {
    if (departed) return ("Departed", colors.outline);
    double minutes = seconds / 60.0;
    if (seconds <= 0) return ("On Time", Colors.green.shade700);
    if (seconds < 180) return ("${minutes.toStringAsFixed(1)}m late", Colors.orange.shade700);
    return ("${minutes.toStringAsFixed(1)}m late", Colors.red.shade700);
  }

  bool _isPast(String timeStr) {
    try {
      final now = DateTime.now();
      final arrivalTime = DateFormat("h:mm a").parse(timeStr);
      final fullArrival = DateTime(now.year, now.month, now.day, arrivalTime.hour, arrivalTime.minute);
      return fullArrival.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final String currentTimeStr = DateFormat('h:mm a').format(DateTime.now());

    return Consumer<TimetableProvider>(
      builder: (context, timetableProvider, child) {
        if (timetableProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final timetable = timetableProvider.timetables[widget.route] ?? [];
        if (timetable.isEmpty) return const Center(child: Text('No timetable available.'));

        int nowDividerIndex = timetable.indexWhere((entry) => !_isPast(entry['time']));

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: timetable.length + (nowDividerIndex != -1 ? 1 : 0),
          itemBuilder: (context, index) {
            if (nowDividerIndex != -1 && index == nowDividerIndex) {
              return _buildNowDivider(currentTimeStr, colors);
            }

            final actualIndex = (nowDividerIndex != -1 && index > nowDividerIndex) ? index - 1 : index;
            final entry = timetable[actualIndex];
            final bool departed = _isPast(entry['time']);
            final (delayText, delayColor) = _getDelayInfo(entry['delay'] as num, departed, colors);
            final bool isLast = actualIndex == timetable.length - 1;

            return IntrinsicHeight(
              child: Row(
                children: [
                  _buildTimelineIndicator(departed, isLast, colors),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildContentCard(entry, departed, delayText, delayColor, colors),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineIndicator(bool departed, bool isLast, ColorScheme colors) {
    return Column(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: departed ? colors.outlineVariant : colors.primary,
            shape: BoxShape.circle,
          ),
        ),
        if (!isLast) Expanded(child: Container(width: 2, color: colors.surfaceVariant)),
      ],
    );
  }

  Widget _buildContentCard(dynamic entry, bool departed, String delayText, Color delayColor, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: departed ? colors.surfaceVariant.withOpacity(0.3) : colors.primaryContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry['time'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: departed ? colors.outline : colors.onPrimaryContainer)),
                  const SizedBox(height: 4),
                  Text(entry['stop'], style: TextStyle(color: departed ? colors.outline : colors.onSurfaceVariant, fontSize: 14)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: departed ? Colors.transparent : delayColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: delayColor.withOpacity(0.2)),
              ),
              child: Text(delayText, style: TextStyle(color: delayColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNowDivider(String time, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: colors.outlineVariant, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text("NOW • $time", style: TextStyle(color: colors.outline, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8)),
          ),
          Expanded(child: Divider(color: colors.outlineVariant, thickness: 1)),
        ],
      ),
    );
  }
}