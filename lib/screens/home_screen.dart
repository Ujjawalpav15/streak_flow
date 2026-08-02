import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../screens/stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        title: const Text(
          'My Streaks',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
                Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const StatsScreen()),);
            },
          ),
        ],
      ),
      body: habits.isEmpty
          ? const Center(
              child: Text(
                'No habits yet.\nTap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return HabitCard(habit: habit);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showAddHabitDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
  final nameController = TextEditingController();
  final emojiController = TextEditingController(text: '🏃');

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        String? errorMessage;

        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Add New Habit',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Habit name (e.g. Running)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  errorText: errorMessage,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emojiController,
                style: const TextStyle(fontSize: 28),
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: 'Pick an emoji',
                  hintStyle: TextStyle(color: Colors.white38),
                  labelText: 'Icon (emoji)',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  counterStyle: TextStyle(color: Colors.white24),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple),
              onPressed: () {
                final name = nameController.text.trim();
                final emoji = emojiController.text.trim();
                if (name.isEmpty) {
                  setDialogState(() {
                    errorMessage = 'Habit name cannot be empty';
                  });
                  return;
                }
                final finalEmoji = emoji.isEmpty ? '⚡' : emoji;
                ref.read(habitsProvider.notifier).addHabit(name, finalEmoji);
                Navigator.pop(context);
              },
              child: const Text('Add',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ),
  );
}
}