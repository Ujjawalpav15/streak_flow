import 'package:flutter/material.dart';

class DotMatrixHeatmap extends StatelessWidget {
  final List<DateTime> completedDates;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int columns;
  final double dotSize;
  final double dotSpacing;
  final Color activeColor;
  final Color inactiveColor;

  const DotMatrixHeatmap({
    super.key,
    required this.completedDates,
    required this.rangeStart,
    required this.rangeEnd,
    required this.columns,
    required this.activeColor,
    required this.inactiveColor,
    this.dotSize = 6.0,
    this.dotSpacing = 3.0,
  });

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    // Determine the total number of days in the range using UTC to avoid DST issues
    final startUtc = DateTime.utc(rangeStart.year, rangeStart.month, rangeStart.day);
    final endUtc = DateTime.utc(rangeEnd.year, rangeEnd.month, rangeEnd.day);
    final totalDays = endUtc.difference(startUtc).inDays + 1;
    
    // We want to fill columns * rows.
    // Given the number of columns, we can calculate the number of rows.
    final rows = (totalDays / columns).ceil();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? dotSpacing : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(columns, (colIndex) {
              final dayIndex = (rowIndex * columns) + colIndex;
              final currentDate = rangeStart.add(Duration(days: dayIndex));
              
              if (dayIndex >= totalDays) {
                // Empty spacer for incomplete rows
                return Container(
                  width: dotSize,
                  height: dotSize,
                  margin: EdgeInsets.only(right: colIndex < columns - 1 ? dotSpacing : 0),
                );
              }

              final isCompleted = completedDates.any((d) => _isSameDay(d, currentDate));
              
              // Optional refinement: check if the date is in the future
              final now = DateTime.now();
              final isFuture = currentDate.isAfter(DateTime(now.year, now.month, now.day, 23, 59, 59));
              
              Color dotColor;
              if (isCompleted) {
                dotColor = activeColor;
              } else if (isFuture) {
                dotColor = inactiveColor.withAlpha((inactiveColor.a * 255.0 / 2).round().clamp(0, 255));
              } else {
                dotColor = inactiveColor;
              }

              return Container(
                width: dotSize,
                height: dotSize,
                margin: EdgeInsets.only(right: colIndex < columns - 1 ? dotSpacing : 0),
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
