import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late int currentStreak;

  @HiveField(4)
  late int longestStreak;

  @HiveField(5)
  late List<DateTime> completedDates;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    this.currentStreak = 0,
    this.longestStreak = 0,
    List<DateTime>? completedDates,
  }) : completedDates = completedDates ?? [];
}