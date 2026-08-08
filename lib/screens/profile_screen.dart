import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_profile_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_accent.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _goalController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();

    // Load existing profile into controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider);
      _nameController.text = profile.name;
      _ageController.text = profile.age;
      _bioController.text = profile.bio;
      _goalController.text = profile.goal;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _goalController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked != null) {
      await ref.read(userProfileProvider.notifier).setImage(picked.path);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    await ref.read(userProfileProvider.notifier).saveProfile(
          name: _nameController.text.trim(),
          age: _ageController.text.trim(),
          bio: _bioController.text.trim(),
          goal: _goalController.text.trim(),
        );
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).extension<AppAccent>()!.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card)),
          content: const Text('✅ Profile saved successfully!',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final accent = Theme.of(context).extension<AppAccent>()!;
    final habits = ref.watch(habitsProvider);
    final totalStreaks = habits.fold<int>(0, (s, h) => s + h.currentStreak);
    final longestEver = habits.isEmpty
        ? 0
        : habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
    final totalCheckIns =
        habits.fold<int>(0, (s, h) => s + h.completedDates.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── Hero Header ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.gradientStart, accent.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
                    child: Column(
                      children: [
                        // Profile Photo
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.glow.withValues(alpha: 0.45),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 58,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.15),
                                  backgroundImage: profile.imagePath != null
                                      ? FileImage(File(profile.imagePath!))
                                      : null,
                                  child: profile.imagePath == null
                                      ? const Icon(Icons.person_rounded,
                                          size: 60, color: Colors.white70)
                                      : null,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.camera_alt_rounded,
                                    size: 18, color: accent.gradientEnd),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Name & bio display
                        if (!_isEditing) ...[
                          Text(
                            profile.name.isEmpty ? 'Your Name' : profile.name,
                            style: AppTypography.headlineMedium().copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          if (profile.bio.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              profile.bio,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium()
                                  .copyWith(color: Colors.white70),
                            ),
                          ],
                          if (profile.goal.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: AppRadius.pillRadius,
                              ),
                              child: Text(
                                '🎯 ${profile.goal}',
                                style: AppTypography.labelSmall()
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        // Stat chips row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _HeroStatChip(
                                emoji: '🔥',
                                value: '$totalStreaks',
                                label: 'Active\nStreaks'),
                            _HeroStatChip(
                                emoji: '🏆',
                                value: '$longestEver',
                                label: 'Best\nRecord'),
                            _HeroStatChip(
                                emoji: '✅',
                                value: '$totalCheckIns',
                                label: 'Total\nCheck-ins'),
                            _HeroStatChip(
                                emoji: '📖',
                                value: '${habits.length}',
                                label: 'Total\nHabits'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Profile Details Card ────────────────────────────
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Profile Details',
                                style: AppTypography.titleMedium()),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: _isEditing
                                  ? Row(
                                      key: const ValueKey('editing'),
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            final p =
                                                ref.read(userProfileProvider);
                                            _nameController.text = p.name;
                                            _ageController.text = p.age;
                                            _bioController.text = p.bio;
                                            _goalController.text = p.goal;
                                            setState(() => _isEditing = false);
                                          },
                                          child: Text('Cancel',
                                              style: AppTypography.labelSmall(
                                                  color:
                                                      AppColors.onSurfaceMuted)),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accent.primary,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: AppSpacing.md,
                                                vertical: AppSpacing.xs),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.card)),
                                          ),
                                          onPressed:
                                              _isSaving ? null : _saveProfile,
                                          child: _isSaving
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white))
                                              : Text('Save',
                                                  style:
                                                      AppTypography.labelSmall(
                                                          color: Colors.white)
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                        ),
                                      ],
                                    )
                                  : IconButton(
                                      key: const ValueKey('view'),
                                      icon: Icon(Icons.edit_rounded,
                                          color: accent.primary),
                                      onPressed: () =>
                                          setState(() => _isEditing = true),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_isEditing) ...[
                          _ProfileField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            hint: 'e.g. Alex Johnson',
                            accent: accent,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ProfileField(
                            controller: _ageController,
                            label: 'Age',
                            icon: Icons.cake_outlined,
                            hint: 'e.g. 24',
                            keyboardType: TextInputType.number,
                            accent: accent,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ProfileField(
                            controller: _bioController,
                            label: 'Short Bio',
                            icon: Icons.info_outline,
                            hint: 'e.g. I love building productive routines',
                            maxLines: 2,
                            accent: accent,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ProfileField(
                            controller: _goalController,
                            label: 'Main Habit Goal',
                            icon: Icons.flag_outlined,
                            hint: 'e.g. Build a 30-day no-sugar streak',
                            accent: accent,
                          ),
                        ] else ...[
                          _InfoRow(
                              icon: Icons.person_outline,
                              label: 'Name',
                              value: profile.name.isEmpty
                                  ? '—'
                                  : profile.name),
                          _InfoRow(
                              icon: Icons.cake_outlined,
                              label: 'Age',
                              value:
                                  profile.age.isEmpty ? '—' : profile.age),
                          _InfoRow(
                              icon: Icons.info_outline,
                              label: 'Bio',
                              value:
                                  profile.bio.isEmpty ? '—' : profile.bio),
                          _InfoRow(
                              icon: Icons.flag_outlined,
                              label: 'Goal',
                              value: profile.goal.isEmpty
                                  ? '—'
                                  : profile.goal),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Settings & Data ─────────────────────────────────
                  _SettingsSection(accent: accent),

                  const SizedBox(height: AppSpacing.xxl),

                  // App Info
                  Center(
                    child: Text(
                      'StreakFlow v1.0.0 • ENEX 386 Software Engineering',
                      style:
                          AppTypography.labelSmall(color: AppColors.onSurfaceDim),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────

class _HeroStatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _HeroStatChip(
      {required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border:
            Border.all(color: AppColors.onSurfaceDim.withValues(alpha: 0.2)),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.onSurfaceMuted),
          const SizedBox(width: AppSpacing.sm),
          Text('$label: ',
              style: AppTypography.labelSmall(color: AppColors.onSurfaceMuted)),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium(color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final AppAccent accent;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.accent,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTypography.bodyMedium(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.labelSmall(color: AppColors.onSurfaceMuted),
        hintText: hint,
        hintStyle: AppTypography.labelSmall(color: AppColors.onSurfaceDim),
        prefixIcon: Icon(icon, color: accent.primary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppRadius.cardRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.cardRadius,
          borderSide:
              BorderSide(color: AppColors.onSurfaceDim.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.cardRadius,
          borderSide: BorderSide(color: accent.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── Embedded Settings & Data ────────────────────────────────────────────────

class _SettingsSection extends ConsumerWidget {
  final AppAccent accent;
  const _SettingsSection({required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = ref.watch(habitBoxProvider);
    final currentAccent = ref.watch(accentThemeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(
              bottom: AppSpacing.md, left: AppSpacing.xs),
          child: Row(
            children: [
              const Icon(Icons.settings_rounded,
                  color: AppColors.onSurfaceMuted, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text('Settings & Data',
                  style: AppTypography.titleMedium()
                      .copyWith(color: AppColors.onSurfaceMuted, fontSize: 14)),
            ],
          ),
        ),

        // ── Accent Theme ──────────────────────────────────────────────
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accent Theme',
                  style: AppTypography.labelSmall(
                      color: AppColors.onSurfaceMuted)),
              const SizedBox(height: AppSpacing.md),
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
                        width: 46,
                        height: 46,
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

        // ── Theme Mode ──────────────────────────────────────────────
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme Mode',
                  style: AppTypography.labelSmall(
                      color: AppColors.onSurfaceMuted)),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('Light')),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Dark')),
                    ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('System')),
                  ],
                  selected: {ref.watch(themeModeProvider)},
                  onSelectionChanged: (Set<ThemeMode> v) => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(v.first),
                  style: SegmentedButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    selectedBackgroundColor: accent.primaryContainer,
                    foregroundColor: AppColors.onSurface,
                    selectedForegroundColor: accent.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Data & Backup ──────────────────────────────────────────
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data & Backup',
                  style: AppTypography.labelSmall(
                      color: AppColors.onSurfaceMuted)),
              const SizedBox(height: AppSpacing.sm),
              _SettingsTile(
                icon: Icons.upload_file_rounded,
                title: 'Export Data to JSON',
                subtitle: 'Copy full habit history to clipboard',
                iconColor: accent.primary,
                onTap: () {
                  final jsonString = BackupService.exportHabitsToJson(box);
                  Clipboard.setData(ClipboardData(text: jsonString));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: accent.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.card)),
                      content: Text('📋 Habit backup JSON copied!',
                          style: AppTypography.bodyMedium(
                              color: AppColors.onSurface)),
                    ),
                  );
                },
              ),
              const Divider(
                  height: 1, color: Color(0x22FFFFFF), thickness: 0.5),
              _SettingsTile(
                icon: Icons.download_rounded,
                title: 'Import Data from JSON',
                subtitle: 'Restore habits from copied JSON string',
                iconColor: accent.primary,
                onTap: () => _showImportDialog(context, ref, accent),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Notifications ──────────────────────────────────────────
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notifications',
                  style: AppTypography.labelSmall(
                      color: AppColors.onSurfaceMuted)),
              const SizedBox(height: AppSpacing.sm),
              _SettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Send Test Push Notification',
                subtitle: 'Test local notification system on your device',
                iconColor: Colors.amberAccent,
                onTap: () async {
                  await NotificationService().showStreakWarningNotification(
                    title: '🔥 StreakFlow Test Alert!',
                    body:
                        'Your notification system is working perfectly! Don\'t break your streak today.',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImportDialog(
      BuildContext context, WidgetRef ref, AppAccent accent) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
        title: Text('Paste Backup JSON',
            style: AppTypography.titleMedium(color: AppColors.onSurface)),
        content: TextField(
          controller: controller,
          maxLines: 6,
          style: AppTypography.bodyMedium(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Paste raw JSON string here...',
            hintStyle:
                AppTypography.bodyMedium(color: AppColors.onSurfaceMuted),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTypography.bodyMedium(
                    color: AppColors.onSurfaceMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: accent.primary),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green.shade900,
                      content: Text('✅ Restored $count habits!',
                          style: AppTypography.bodyMedium(
                              color: AppColors.onSurface)),
                    ),
                  );
                } catch (_) {
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('❌ Invalid JSON backup format.'),
                    ),
                  );
                }
              }
            },
            child: Text('Import',
                style:
                    AppTypography.bodyMedium(color: AppColors.onSurface)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: AppTypography.bodyMedium(color: AppColors.onSurface)
            .copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.labelSmall(color: AppColors.onSurfaceMuted),
      ),
      onTap: onTap,
    );
  }
}
