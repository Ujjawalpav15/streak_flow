import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = ref.watch(habitBoxProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF131722),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.settings_rounded, color: Colors.white, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Settings & Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Export JSON Data
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: const Color(0xFF1C2230),
            leading: const Icon(Icons.upload_file_rounded, color: Colors.cyanAccent),
            title: const Text('Export Data to JSON',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Copy full habit history to clipboard',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
            onTap: () {
              final jsonString = BackupService.exportHabitsToJson(box);
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.cyan,
                  content: Text('📋 Habit backup JSON copied to clipboard!'),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Import JSON Data
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: const Color(0xFF1C2230),
            leading:
                const Icon(Icons.download_rounded, color: Colors.deepPurpleAccent),
            title: const Text('Import Data from JSON',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Restore habits from copied JSON string',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
            onTap: () {
              Navigator.pop(context);
              _showImportDialog(context, ref);
            },
          ),
          const SizedBox(height: 10),

          // Test Local Push Notification
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: const Color(0xFF1C2230),
            leading:
                const Icon(Icons.notifications_active_rounded, color: Colors.amberAccent),
            title: const Text('Send Test Push Notification',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Test local notification system on your device',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
            onTap: () async {
              Navigator.pop(context);
              await NotificationService().showStreakWarningNotification(
                title: '🔥 StreakFlow Test Alert!',
                body: 'Your notification system is working perfectly! Don\'t break your streak today.',
              );
            },
          ),
          const SizedBox(height: 20),

          // App Info Footnote
          const Center(
            child: Text(
              'StreakFlow v1.0.0 • ENEX 386 Software Engineering',
              style: TextStyle(color: Colors.white24, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            const Text('Paste Backup JSON', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 6,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: const InputDecoration(
            hintText: 'Paste raw JSON string here...',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                try {
                  final box = ref.read(habitBoxProvider);
                  final count =
                      await BackupService.importHabitsFromJson(box, text);
                  ref.read(habitsProvider.notifier).refreshAllStreaks();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green.shade900,
                      content: Text('✅ Successfully restored $count habits!'),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('❌ Invalid JSON backup format.'),
                    ),
                  );
                }
              }
            },
            child: const Text('Import', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
