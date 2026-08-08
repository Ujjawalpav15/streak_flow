import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_profile_provider.dart';
import '../providers/habit_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_accent.dart';
import 'settings_data_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _goalController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = ref.read(userProfileProvider);
      _nameController.text = p.name;
      _usernameController.text = p.age; // reusing age field as username handle
      _ageController.text = p.age;
      _bioController.text = p.bio;
      _goalController.text = p.goal;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _goalController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 512);
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
      final accent = Theme.of(context).extension<AppAccent>()!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: accent.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
        content: const Text('✅ Profile saved!',
            style: TextStyle(color: Colors.white)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final accent = Theme.of(context).extension<AppAccent>()!;
    final habits = ref.watch(habitsProvider);

    final activeStreaks = habits.where((h) => h.currentStreak > 0).length;
    final completedToday = habits
        .where((h) => ref.read(habitsProvider.notifier).isCompletedToday(h))
        .length;

    final cs = AppColorScheme.of(context);

    return Scaffold(
      backgroundColor: cs.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── Top App Bar ─────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: cs.background,
              elevation: 0,
              pinned: false,
              automaticallyImplyLeading: false,
              title: Text('Profile',
                  style: AppTypography.headlineMedium().copyWith(fontSize: 20)),
              centerTitle: true,
              actions: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isEditing
                      ? TextButton(
                          key: const ValueKey('save'),
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text('Save',
                                  style: AppTypography.labelMedium(
                                          color: accent.primary)
                                      .copyWith(fontWeight: FontWeight.bold)),
                        )
                      : IconButton(
                          key: const ValueKey('edit'),
                          icon: Icon(Icons.edit_outlined,
                              color: accent.primary, size: 22),
                          onPressed: () => setState(() => _isEditing = true),
                        ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    // ── Profile Photo ──────────────────────────────────
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: accent.primary.withValues(alpha: 0.4),
                                  width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.glow.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: cs.surface,
                              backgroundImage: profile.imagePath != null
                                  ? FileImage(File(profile.imagePath!))
                                  : null,
                              child: profile.imagePath == null
                                  ? Icon(Icons.person_rounded,
                                      size: 56,
                                      color: cs.onSurfaceMuted)
                                  : null,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accent.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: cs.background, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Name ────────────────────────────────────────────
                    if (_isEditing)
                      _EditField(
                        controller: _nameController,
                        label: 'Full Name',
                        accent: accent,
                      )
                    else
                      Text(
                        profile.name.isEmpty ? 'Your Name' : profile.name,
                        style: AppTypography.headlineMedium().copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xs),

                    // ── Bio / handle ────────────────────────────────────
                    if (_isEditing) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _EditField(
                        controller: _bioController,
                        label: 'Short Bio or Email',
                        accent: accent,
                        maxLines: 2,
                      ),
                    ] else
                      Text(
                        profile.bio.isEmpty
                            ? 'tap ✏️ to add your bio'
                            : profile.bio,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(
                            color: cs.onSurfaceMuted),
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Sleek Streak & Progress Summary Card ─────────
                    _StreakSummaryCard(
                      activeStreaks: activeStreaks,
                      completedToday: completedToday,
                      totalHabits: habits.length,
                      longestEver: habits.isEmpty
                          ? 0
                          : habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b),
                      totalCheckIns: habits.fold<int>(0, (s, h) => s + h.completedDates.length),
                      accent: accent,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Extra Edit Fields ──────────────────────────────
                    if (_isEditing) ...[
                      _EditField(
                        controller: _ageController,
                        label: 'Age',
                        accent: accent,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _EditField(
                        controller: _goalController,
                        label: 'Main Habit Goal',
                        accent: accent,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final p = ref.read(userProfileProvider);
                                _nameController.text = p.name;
                                _ageController.text = p.age;
                                _bioController.text = p.bio;
                                _goalController.text = p.goal;
                                setState(() => _isEditing = false);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: cs.onSurfaceMuted,
                                side: BorderSide(
                                    color: cs.onSurfaceDim
                                        .withValues(alpha: 0.5)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md),
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.cardRadius),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent.primary,
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md),
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.cardRadius),
                              ),
                              child: Text('Save Profile',
                                  style: AppTypography.labelMedium(
                                      color: Colors.white)
                                      .copyWith(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // ── Profile Info List ──────────────────────────────
                    if (!_isEditing) ...[
                      _ProfileInfoTile(
                        icon: Icons.person_outline_rounded,
                        iconColor: accent.primary,
                        title: 'Name',
                        subtitle:
                            profile.name.isEmpty ? 'Not set' : profile.name,
                      ),
                      _ProfileInfoTile(
                        icon: Icons.cake_outlined,
                        iconColor: const Color(0xFF10B981),
                        title: 'Age',
                        subtitle: profile.age.isEmpty ? 'Not set' : '${profile.age} years old',
                      ),
                      _ProfileInfoTile(
                        icon: Icons.flag_outlined,
                        iconColor: Colors.amberAccent,
                        title: 'Habit Goal',
                        subtitle:
                            profile.goal.isEmpty ? 'Not set' : profile.goal,
                      ),
                      _ProfileInfoTile(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: Colors.deepOrangeAccent,
                        title: 'Total Habits',
                        subtitle: '${habits.length} habits being tracked',
                      ),
                      _ProfileInfoTile(
                        icon: Icons.emoji_events_rounded,
                        iconColor: const Color(0xFFFFD700),
                        title: 'Longest Streak',
                        subtitle: habits.isEmpty
                            ? 'No streaks yet'
                            : '${habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b)} days',
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Settings & Data Button ────────────────────────
                      _NavTile(
                        icon: Icons.settings_rounded,
                        iconColor: accent.primary,
                        iconBg: accent.primary.withValues(alpha: 0.12),
                        title: 'Settings & Data',
                        subtitle: 'Appearance, backup, notifications',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsDataScreen()),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glassmorphic Streak Summary Card ──────────────────────────────────────

class _StreakSummaryCard extends StatelessWidget {
  final int activeStreaks;
  final int completedToday;
  final int totalHabits;
  final int longestEver;
  final int totalCheckIns;
  final AppAccent accent;

  const _StreakSummaryCard({
    required this.activeStreaks,
    required this.completedToday,
    required this.totalHabits,
    required this.longestEver,
    required this.totalCheckIns,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = AppColorScheme.of(context);
    final ratio = totalHabits == 0
        ? 0.0
        : (completedToday / totalHabits).clamp(0.0, 1.0);
    final percentage = (ratio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: accent.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.glow.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Today's Goal Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🎯', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Goal Progress',
                        style: AppTypography.bodyMedium(color: cs.onSurface)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$completedToday of $totalHabits habits done today',
                        style:
                            AppTypography.labelSmall(color: cs.onSurfaceMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.primary,
                  borderRadius: AppRadius.pillRadius,
                  boxShadow: [
                    BoxShadow(
                      color: accent.glow.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: cs.onSurfaceDim.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(accent.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: cs.onSurfaceDim.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: AppSpacing.md),
          // 3 Metric Pills Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricPill(
                emoji: '🔥',
                value: '$activeStreaks',
                label: 'Active Streaks',
                cs: cs,
              ),
              Container(
                height: 24,
                width: 1,
                color: cs.onSurfaceDim.withValues(alpha: 0.2),
              ),
              _MetricPill(
                emoji: '🏆',
                value: '${longestEver}d',
                label: 'Peak Record',
                cs: cs,
              ),
              Container(
                height: 24,
                width: 1,
                color: cs.onSurfaceDim.withValues(alpha: 0.2),
              ),
              _MetricPill(
                emoji: '✅',
                value: '$totalCheckIns',
                label: 'Check-ins',
                cs: cs,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final AppColorScheme cs;

  const _MetricPill({
    required this.emoji,
    required this.value,
    required this.label,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTypography.bodyMedium(color: cs.onSurface).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelSmall(color: cs.onSurfaceMuted)
              .copyWith(fontSize: 11),
        ),
      ],
    );
  }
}


// ── Profile Info Tile ────────────────────────────────────────────────────────

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _ProfileInfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = AppColorScheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurfaceDim.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
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
                    style: AppTypography.labelSmall(color: cs.onSurfaceMuted)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTypography.bodyMedium(color: cs.onSurface)
                        .copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav Tile (for Settings & Data) ───────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.onSurfaceDim.withValues(alpha: 0.15)),
        ),
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
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTypography.labelSmall(color: cs.onSurfaceMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Edit Field ────────────────────────────────────────────────────────────────

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final AppAccent accent;
  final int maxLines;
  final TextInputType? keyboardType;

  const _EditField({
    required this.controller,
    required this.label,
    required this.accent,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = AppColorScheme.of(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTypography.bodyMedium(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.labelSmall(color: cs.onSurfaceMuted),
        filled: true,
        fillColor: cs.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: AppRadius.cardRadius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.cardRadius,
          borderSide:
              BorderSide(color: cs.onSurfaceDim.withValues(alpha: 0.3)),
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
