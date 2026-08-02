import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/milestone_badges_sheet.dart';
import '../widgets/settings_sheet.dart';
import 'stats_screen.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final sortOptionProvider = StateProvider<String>((ref) => 'Default');

final searchedAndSortedHabitsProvider = Provider<List<Habit>>((ref) {
  final filtered = ref.watch(filteredHabitsProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final sortOption = ref.watch(sortOptionProvider);

  var list = filtered.where((h) {
    if (query.isEmpty) return true;
    return h.name.toLowerCase().contains(query);
  }).toList();

  if (sortOption == 'Highest Streak') {
    list.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
  } else if (sortOption == 'Longest Record') {
    list.sort((a, b) => b.longestStreak.compareTo(a.longestStreak));
  } else if (sortOption == 'Uncompleted First') {
    final notifier = ref.watch(habitsProvider.notifier);
    list.sort((a, b) {
      final aDone = notifier.isCompletedToday(a);
      final bDone = notifier.isCompletedToday(b);
      if (aDone == bDone) return 0;
      return aDone ? 1 : -1;
    });
  } else if (sortOption == 'Alphabetical') {
    list.sort((a, b) => a.name.compareTo(b.name));
  }

  return list;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(searchedAndSortedHabitsProvider);
    final allHabits = ref.watch(habitsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final sortOption = ref.watch(sortOptionProvider);

    final todayFormatted = DateFormat('EEEE, MMM d').format(DateTime.now());

    // Calculate Loss Aversion "At Risk" habits
    final uncompletedActiveHabits = allHabits.where((h) {
      final done = ref.read(habitsProvider.notifier).isCompletedToday(h);
      return !done && h.currentStreak > 0;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'StreakFlow ⚡',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              todayFormatted,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Text('🏆', style: TextStyle(fontSize: 22)),
            tooltip: 'Milestone Badges',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => MilestoneBadgesSheet(habits: allHabits),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
            tooltip: 'Statistics & Heatmaps',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white70),
            tooltip: 'Settings & Backup',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => const SettingsSheet(),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Search & Sort Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      onChanged: (val) {
                        ref.read(searchQueryProvider.notifier).state = val;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search habits...',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: Colors.white38, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: DropdownButton<String>(
                    value: sortOption,
                    underline: const SizedBox(),
                    dropdownColor: const Color(0xFF1E2433),
                    icon: const Icon(Icons.sort_rounded,
                        color: Colors.white70, size: 20),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: [
                      'Default',
                      'Uncompleted First',
                      'Highest Streak',
                      'Longest Record',
                      'Alphabetical',
                    ].map((opt) {
                      return DropdownMenuItem(value: opt, child: Text(opt));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(sortOptionProvider.notifier).state = val;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // "Streak at Risk!" Loss-Aversion Warning Banner
          if (uncompletedActiveHabits.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade900.withValues(alpha: 0.8),
                      Colors.red.shade900.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Streak at Risk!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${uncompletedActiveHabits.length} habit(s) not checked today. Complete them before midnight!',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: ['All', 'Fitness', 'Coding', 'Study', 'Health', 'General']
                  .map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category;
                    },
                    backgroundColor: const Color(0xFF161B26),
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.deepPurpleAccent
                            : Colors.white10,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Main List of Habits
          Expanded(
            child: habits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text(
                          selectedCategory == 'All'
                              ? 'No habits tracked yet.\nTap + below to build your streak!'
                              : 'No habits found in "$selectedCategory".',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return HabitCard(
                        habit: habit,
                        onEdit: () => _showAddOrEditHabitDialog(
                            context, ref, habit: habit),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 6,
        onPressed: () => _showAddOrEditHabitDialog(context, ref),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Habit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddOrEditHabitDialog(BuildContext context, WidgetRef ref,
      {Habit? habit}) {
    final isEditing = habit != null;
    final nameController =
        TextEditingController(text: isEditing ? habit.name : '');
    final emojiController =
        TextEditingController(text: isEditing ? habit.icon : '🏃');

    String selectedCategory = isEditing ? habit.category : 'General';
    final presetEmojis = ['🏃', '💻', '📚', '🧘', '🎨', '🏋️', '💧', '⚡', '🎯'];
    final categories = ['Fitness', 'Coding', 'Study', 'Health', 'General'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          String? errorMessage;

          return AlertDialog(
            backgroundColor: const Color(0xFF161B26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              isEditing ? 'Edit Habit' : 'Build New Habit',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Habit Name
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Habit name (e.g. Daily Running)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      errorText: errorMessage,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Emoji Preset Quick Selector & Custom Emoji Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Icon Emoji',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(
                        'Active: ${emojiController.text}',
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...presetEmojis.map((e) {
                        final isSelected = emojiController.text == e;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              emojiController.text = e;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.deepPurpleAccent
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(e, style: const TextStyle(fontSize: 22)),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Custom Emoji Keyboard Input Field
                  TextField(
                    controller: emojiController,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    onChanged: (_) {
                      setDialogState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: 'Or type/paste custom emoji (+)',
                      labelStyle: const TextStyle(color: Colors.deepPurpleAccent, fontSize: 12),
                      hintText: 'e.g. 🚴, 🎸, 🧗, 🥑, 🎮',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      prefixIcon: const Icon(Icons.add_reaction_outlined, color: Colors.deepPurpleAccent, size: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Selector
                  const Text('Category',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: const Color(0xFF1E2433),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.deepPurpleAccent),
                      ),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCategory = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final name = nameController.text.trim();
                  final emoji = emojiController.text.trim();
                  if (name.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Please enter a habit name';
                    });
                    return;
                  }
                  final finalEmoji = emoji.isEmpty ? '⚡' : emoji;

                  if (isEditing) {
                    ref
                        .read(habitsProvider.notifier)
                        .editHabit(habit.id, name, finalEmoji, selectedCategory);
                  } else {
                    ref.read(habitsProvider.notifier).addHabit(
                          name,
                          finalEmoji,
                          category: selectedCategory,
                        );
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Habit',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}