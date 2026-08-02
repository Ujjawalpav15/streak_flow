import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';

class InteractiveMonthlyCalendar extends StatefulWidget {
  final List<Habit> habits;

  const InteractiveMonthlyCalendar({super.key, required this.habits});

  @override
  State<InteractiveMonthlyCalendar> createState() =>
      _InteractiveMonthlyCalendarState();
}

class _InteractiveMonthlyCalendarState
    extends State<InteractiveMonthlyCalendar> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday; // 1 = Mon

    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          // Month Switcher Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    color: Colors.white70),
                onPressed: _previousMonth,
              ),
              Text(
                monthName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                    color: Colors.white70),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 36,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Day Grid Matrix
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (firstWeekday - 1) + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox.shrink();
              }

              final dayNumber = index - (firstWeekday - 1) + 1;
              final targetDate = DateTime(
                  _selectedMonth.year, _selectedMonth.month, dayNumber);

              // Calculate habits completed or frozen on targetDate
              final completedHabits = widget.habits.where((h) {
                return h.completedDates.any((d) =>
                    d.year == targetDate.year &&
                    d.month == targetDate.month &&
                    d.day == targetDate.day);
              }).toList();

              final frozenHabits = widget.habits.where((h) {
                return h.frozenDates.any((d) =>
                    d.year == targetDate.year &&
                    d.month == targetDate.month &&
                    d.day == targetDate.day);
              }).toList();

              final isToday = DateTime.now().year == targetDate.year &&
                  DateTime.now().month == targetDate.month &&
                  DateTime.now().day == targetDate.day;

              final totalHabits = widget.habits.length;
              final completedRatio = totalHabits == 0
                  ? 0.0
                  : (completedHabits.length / totalHabits);

              Color cellColor = Colors.white.withValues(alpha: 0.04);
              if (completedHabits.isNotEmpty) {
                cellColor = Color.lerp(
                  Colors.deepPurple.shade900,
                  Colors.deepPurpleAccent,
                  completedRatio,
                )!;
              } else if (frozenHabits.isNotEmpty) {
                cellColor = Colors.cyan.shade900;
              }

              return GestureDetector(
                onTap: () => _showDayDetailSheet(
                  context,
                  targetDate,
                  completedHabits,
                  frozenHabits,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isToday
                          ? Colors.amber.shade400
                          : (completedHabits.isNotEmpty
                              ? Colors.deepPurpleAccent.withValues(alpha: 0.6)
                              : Colors.transparent),
                      width: isToday ? 1.8 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            color: isToday
                                ? Colors.amber.shade400
                                : (completedHabits.isNotEmpty
                                    ? Colors.white
                                    : Colors.white38),
                            fontWeight: isToday || completedHabits.isNotEmpty
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        if (frozenHabits.isNotEmpty)
                          const Text('🧊', style: TextStyle(fontSize: 8))
                        else if (completedHabits.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDayDetailSheet(
    BuildContext context,
    DateTime date,
    List<Habit> completedHabits,
    List<Habit> frozenHabits,
  ) {
    final dateFormatted = DateFormat('EEEE, MMMM d, yyyy').format(date);
    final totalHabits = widget.habits.length;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📅 Day History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              dateFormatted,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Completion Summary Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: completedHabits.isNotEmpty
                    ? Colors.deepPurple.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: completedHabits.isNotEmpty
                      ? Colors.deepPurpleAccent
                      : Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    completedHabits.length == totalHabits && totalHabits > 0
                        ? '🌟'
                        : (completedHabits.isNotEmpty ? '⚡' : '💤'),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${completedHabits.length} of $totalHabits habits completed on this day.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List of completed habits
            if (completedHabits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No habits were marked complete on this date.',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              )
            else
              ...completedHabits.map((habit) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Text(habit.icon,
                        style: const TextStyle(fontSize: 22)),
                    title: Text(
                      habit.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${habit.streakFlameIcon} ${habit.currentStreak} day streak',
                      style: TextStyle(color: habit.streakColor, fontSize: 11),
                    ),
                    trailing: const Icon(Icons.check_circle_rounded,
                        color: Colors.greenAccent),
                  )),
          ],
        ),
      ),
    );
  }
}
