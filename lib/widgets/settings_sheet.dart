import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_accent.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = ref.watch(habitBoxProvider);
    final currentAccent = ref.watch(accentThemeProvider);
    final accent = Theme.of(context).extension<AppAccent>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.settings_rounded, color: AppColors.onSurface, size: 26),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Settings & Data',
                    style: AppTypography.headlineMedium(),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.onSurfaceMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Accent Theme Section
          Text(
            'Accent Theme',
            style: AppTypography.labelSmall(color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AppAccent.all.map((appAccent) {
              final isSelected = appAccent.name == currentAccent.name;
              return GestureDetector(
                onTap: () {
                  ref.read(accentThemeProvider.notifier).setTheme(appAccent.name);
                },
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appAccent.primary,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: appAccent.glow,
                                blurRadius: 12,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: AppColors.onSurface, size: 24)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Theme Mode Section
          Text(
            'Theme Mode',
            style: AppTypography.labelSmall(color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('System'),
                ),
              ],
              selected: {ref.watch(themeModeProvider)},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: AppColors.surface,
                selectedBackgroundColor: accent.primaryContainer,
                foregroundColor: AppColors.onSurface,
                selectedForegroundColor: accent.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Data & Backup Section
          Text(
            'Data & Backup',
            style: AppTypography.labelSmall(color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Export JSON Data
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
            tileColor: AppColors.surface,
            leading: Icon(Icons.upload_file_rounded, color: accent.primary),
            title: Text(
              'Export Data to JSON',
              style: AppTypography.bodyMedium(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Copy full habit history to clipboard',
              style: AppTypography.labelSmall(color: AppColors.onSurfaceMuted),
            ),
            onTap: () {
              final jsonString = BackupService.exportHabitsToJson(box);
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: accent.primary,
                  content: Text('📋 Habit backup JSON copied to clipboard!', style: AppTypography.bodyMedium(color: AppColors.onSurface)),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Import JSON Data
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
            tileColor: AppColors.surface,
            leading: Icon(Icons.download_rounded, color: accent.primary),
            title: Text(
              'Import Data from JSON',
              style: AppTypography.bodyMedium(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Restore habits from copied JSON string',
              style: AppTypography.labelSmall(color: AppColors.onSurfaceMuted),
            ),
            onTap: () {
              Navigator.pop(context);
              _showImportDialog(context, ref, accent);
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Notifications Section
          Text(
            'Notifications',
            style: AppTypography.labelSmall(color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Test Local Push Notification
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
            tileColor: AppColors.surface,
            leading: const Icon(Icons.notifications_active_rounded, color: Colors.amberAccent),
            title: Text(
              'Send Test Push Notification',
              style: AppTypography.bodyMedium(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Test local notification system on your device',
              style: AppTypography.labelSmall(color: AppColors.onSurfaceMuted),
            ),
            onTap: () async {
              Navigator.pop(context);
              await NotificationService().showStreakWarningNotification(
                title: '🔥 StreakFlow Test Alert!',
                body: 'Your notification system is working perfectly! Don\'t break your streak today.',
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          // App Info Footnote
          Center(
            child: Text(
              'StreakFlow v1.0.0 • ENEX 386 Software Engineering',
              style: AppTypography.labelSmall(color: AppColors.onSurfaceDim),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref, AppAccent accent) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
        title: Text('Paste Backup JSON', style: AppTypography.titleMedium(color: AppColors.onSurface)),
        content: TextField(
          controller: controller,
          maxLines: 6,
          style: AppTypography.bodyMedium(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Paste raw JSON string here...',
            hintStyle: AppTypography.bodyMedium(color: AppColors.onSurfaceMuted),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.bodyMedium(color: AppColors.onSurfaceMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent.primary,
            ),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                try {
                  final box = ref.read(habitBoxProvider);
                  final count = await BackupService.importHabitsFromJson(box, text);
                  ref.read(habitsProvider.notifier).refreshAllStreaks();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green.shade900,
                      content: Text('✅ Successfully restored $count habits!', style: AppTypography.bodyMedium(color: AppColors.onSurface)),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('❌ Invalid JSON backup format.', style: AppTypography.bodyMedium(color: AppColors.onSurface)),
                    ),
                  );
                }
              }
            },
            child: Text('Import', style: AppTypography.bodyMedium(color: AppColors.onSurface)),
          ),
        ],
      ),
    );
  }
}
