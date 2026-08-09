import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_accent.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsDataScreen extends ConsumerWidget {
  const SettingsDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).extension<AppAccent>()!;
    final cs = AppColorScheme.of(context);
    final box = ref.watch(habitBoxProvider);
    final currentAccent = ref.watch(accentThemeProvider);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings & Data',
          style: AppTypography.titleMedium(color: cs.onSurface).copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Accent Theme ───────────────────────────────────────
            _SettingGroupHeader(label: 'Appearance'),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accent Theme',
                      style: AppTypography.bodyMedium(color: cs.onSurface)
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Choose your preferred color accent',
                      style: AppTypography.labelSmall(
                          color: cs.onSurfaceMuted)),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: AppAccent.all.map((appAccent) {
                      final isSelected = appAccent.name == currentAccent.name;
                      return GestureDetector(
                        onTap: () => ref
                            .read(accentThemeProvider.notifier)
                            .setTheme(appAccent.name),
                        child: AnimatedScale(
                          scale: isSelected ? 1.0 : 0.85,
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
                                          blurRadius: 14,
                                          spreadRadius: 3)
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 22)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            _SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme Mode',
                      style: AppTypography.bodyMedium(color: cs.onSurface)
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Light, Dark or follow System',
                      style: AppTypography.labelSmall(
                          color: cs.onSurfaceMuted)),
                  const SizedBox(height: AppSpacing.lg),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_rounded),
                          label: Text('Light')),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_rounded),
                          label: Text('Dark')),
                      ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_rounded),
                          label: Text('Auto')),
                    ],
                    selected: {ref.watch(themeModeProvider)},
                    onSelectionChanged: (v) => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(v.first),
                    style: SegmentedButton.styleFrom(
                      backgroundColor: cs.surfaceVariant,
                      selectedBackgroundColor: accent.primaryContainer,
                      foregroundColor: cs.onSurface,
                      selectedForegroundColor: accent.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Data & Backup ──────────────────────────────────────
            _SettingGroupHeader(label: 'Data & Backup'),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.upload_file_rounded,
                    iconColor: accent.primary,
                    iconBg: accent.primary.withValues(alpha: 0.12),
                    title: 'Export Data to JSON',
                    subtitle: 'Copy full habit history to clipboard',
                    onTap: () {
                      final jsonString = BackupService.exportHabitsToJson(box);
                      Clipboard.setData(ClipboardData(text: jsonString));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: accent.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.card)),
                          content: Text('📋 Habit backup JSON copied!',
                              style: AppTypography.bodyMedium(
                                  color: Colors.white)),
                        ),
                      );
                    },
                  ),
                  Divider(
                      height: 1,
                      thickness: 0.5,
                      color: cs.onSurfaceDim.withValues(alpha: 0.3)),
                  _SettingsRow(
                    icon: Icons.download_rounded,
                    iconColor: accent.primary,
                    iconBg: accent.primary.withValues(alpha: 0.12),
                    title: 'Import Data from JSON',
                    subtitle: 'Restore habits from clipboard JSON',
                    onTap: () => _showImportDialog(context, ref, accent),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Notifications ──────────────────────────────────────
            _SettingGroupHeader(label: 'Notifications'),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              child: _SettingsRow(
                icon: Icons.notifications_active_rounded,
                iconColor: Colors.amberAccent,
                iconBg: Colors.amberAccent.withValues(alpha: 0.12),
                title: 'Send Test Notification',
                subtitle: 'Verify push notifications are working',
                onTap: () async {
                  await NotificationService().showStreakWarningNotification(
                    title: '🔥 StreakFlow Test Alert!',
                    body:
                        'Your notification system is working! Don\'t break your streak today.',
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SvgPicture.asset(
                      'assets/images/app_logo.svg',
                      width: 64,
                      height: 64,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'StreakFlow',
                    style: AppTypography.titleMedium(color: cs.onSurface).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Version 1.0.0 • Personal Habit Tracker',
                    style: AppTypography.labelSmall(color: cs.onSurfaceMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(
      BuildContext context, WidgetRef ref, AppAccent accent) {
    final controller = TextEditingController();
    final cs = AppColorScheme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
        title: Text('Paste Backup JSON',
            style: AppTypography.titleMedium(color: cs.onSurface)),
        content: TextField(
          controller: controller,
          maxLines: 6,
          style: AppTypography.bodyMedium(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'Paste raw JSON string here...',
            hintStyle:
                AppTypography.bodyMedium(color: cs.onSurfaceMuted),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTypography.bodyMedium(
                    color: cs.onSurfaceMuted)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: accent.primary),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                try {
                  final box = ref.read(habitBoxProvider);
                  final count =
                      await BackupService.importHabitsFromJson(box, text);
                  ref.read(habitsProvider.notifier).refreshAllStreaks();
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.green.shade900,
                    content: Text('✅ Restored $count habits!',
                        style: AppTypography.bodyMedium(
                            color: cs.onSurface)),
                  ));
                } catch (_) {
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text('❌ Invalid JSON format.'),
                  ));
                }
              }
            },
            child: Text('Import',
                style: AppTypography.bodyMedium(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

class _SettingGroupHeader extends StatelessWidget {
  final String label;
  const _SettingGroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = AppColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall(color: cs.onSurfaceMuted)
            .copyWith(letterSpacing: 1.2, fontSize: 11),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = AppColorScheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.cardRadius,
        border:
            Border.all(color: cs.onSurfaceDim.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = AppColorScheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.bodyMedium(color: cs.onSurface)
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTypography.labelSmall(
                          color: cs.onSurfaceMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
