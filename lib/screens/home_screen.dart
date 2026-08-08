import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/habit_card.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import '../widgets/milestone_badges_sheet.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_accent.dart';

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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(searchedAndSortedHabitsProvider);
    final allHabits = ref.watch(habitsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final userProfile = ref.watch(userProfileProvider);

    final accent = Theme.of(context).extension<AppAccent>()!;
    final cs = AppColorScheme.of(context);

    // Calculate Loss Aversion "At Risk" habits
    final uncompletedActiveHabits = allHabits.where((h) {
      final done = ref.read(habitsProvider.notifier).isCompletedToday(h);
      return !done && h.currentStreak > 0;
    }).toList();

    return Scaffold(
      backgroundColor: cs.background,
      body: IndexedStack(
        index: _currentIndex == 1 ? 1 : (_currentIndex == 2 ? 2 : 0),
        children: [
          Column(
            children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent.gradientStart, accent.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 2),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: userProfile.imagePath != null
                            ? FileImage(File(userProfile.imagePath!))
                            : null,
                        child: userProfile.imagePath == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${allHabits.fold<int>(0, (max, h) => h.currentStreak > max ? h.currentStreak : max)}',
                                style: AppTypography.labelMedium().copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '${DateTime.now().hour < 12 ? "Good Morning" : DateTime.now().hour < 17 ? "Good Afternoon" : "Good Evening"}!',
                  style: AppTypography.headlineMedium().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep the streak alive, spark your daily motivation.',
                  style: AppTypography.bodyMedium().copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          // Search & Sort Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outline, width: 0.5),
                    ),
                    child: TextField(
                      style: AppTypography.bodyMedium(color: cs.onSurface),
                      onChanged: (val) {
                        ref.read(searchQueryProvider.notifier).state = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Search habits...',
                        hintStyle: AppTypography.bodyMedium(color: cs.onSurfaceMuted),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: cs.onSurfaceDim, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outline, width: 0.5),
                  ),
                  child: DropdownButton<String>(
                    value: sortOption,
                    underline: const SizedBox(),
                    dropdownColor: cs.surfaceVariant,
                    icon: Icon(Icons.sort_rounded,
                        color: cs.onSurfaceMuted, size: 20),
                    style: AppTypography.bodySmall(color: cs.onSurface),
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.warningGradientStart,
                      AppColors.warningGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warningGradientEnd.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Streak at Risk!',
                            style: AppTypography.labelLarge(color: Colors.white).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${uncompletedActiveHabits.length} habit(s) not checked today. Complete them before midnight!',
                            style: AppTypography.bodySmall(color: Colors.white70),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: ['All', 'Fitness', 'Coding', 'Study', 'Health', 'General']
                  .map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category;
                    },
                    backgroundColor: cs.surfaceVariant,
                    selectedColor: accent.primary,
                    labelStyle: AppTypography.labelMedium(
                      color: isSelected ? Colors.white : cs.onSurfaceMuted,
                    ).copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      side: BorderSide(
                        color: isSelected
                            ? accent.primary
                            : cs.outline,
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
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(100, 100),
                              painter: DashedCirclePainter(color: cs.onSurfaceDim),
                            ),
                            Icon(
                              Icons.local_fire_department_outlined,
                              size: 48,
                              color: cs.onSurfaceDim,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _showAddOrEditHabitDialog(context, ref),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: accent.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.primary.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Tap Here To Start',
                          style: AppTypography.titleLarge().copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Create your first habit and start your journey.',
                          style: AppTypography.bodyMedium().copyWith(color: cs.onSurfaceMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return _StaggeredItem(
                        index: index,
                        child: HabitCard(
                          habit: habit,
                          onEdit: () => _showAddOrEditHabitDialog(
                              context, ref, habit: habit),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      const StatsScreen(),
      const ProfileScreen(),
    ],
  ),
  bottomNavigationBar: _buildBottomNav(accent, cs, allHabits),
);
  }

  Widget _buildBottomNav(AppAccent accent, AppColorScheme cs, List<Habit> allHabits) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.local_fire_department, Icons.local_fire_department_outlined, accent, cs),
            _buildNavItem(1, Icons.calendar_month, Icons.calendar_month_outlined, accent, cs),
            
            GestureDetector(
              onTap: () => _showAddOrEditHabitDialog(context, ref),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
            
            _buildNavItem(3, Icons.workspace_premium, Icons.workspace_premium_outlined, accent, cs, isAction: true, onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => MilestoneBadgesSheet(habits: allHabits),
              );
            }),
            _buildNavItem(2, Icons.person, Icons.person_outline, accent, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, AppAccent accent, AppColorScheme cs, {bool isAction = false, VoidCallback? onTap}) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (isAction && onTap != null) {
          onTap();
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? accent.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? accent.primary : cs.onSurfaceMuted,
          size: 26,
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

    final accent = Theme.of(context).extension<AppAccent>()!;
    final cs = AppColorScheme.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          String? errorMessage;

          return AlertDialog(
            backgroundColor: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sheet),
            ),
            title: Text(
              isEditing ? 'Edit Habit' : 'Build New Habit',
              style: AppTypography.headlineSmall(color: cs.onSurface),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Habit Name
                  TextField(
                    controller: nameController,
                    style: AppTypography.bodyLarge(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Habit name (e.g. Daily Running)',
                      hintStyle: AppTypography.bodyLarge(color: cs.onSurfaceDim),
                      errorText: errorMessage,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: cs.onSurfaceDim),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accent.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Emoji Preset Quick Selector & Custom Emoji Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Icon Emoji',
                          style: AppTypography.labelSmall(color: cs.onSurfaceMuted)),
                      Text(
                        'Active: ${emojiController.text}',
                        style: AppTypography.labelMedium(color: Colors.amberAccent)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                                  ? accent.primary.withValues(alpha: 0.3)
                                  : cs.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? accent.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(e, style: const TextStyle(fontSize: 22)),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Custom Emoji Keyboard Input Field
                  TextField(
                    controller: emojiController,
                    style: TextStyle(color: cs.onSurface, fontSize: 18),
                    onChanged: (_) {
                      setDialogState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: 'Or type/paste custom emoji (+)',
                      labelStyle: AppTypography.labelSmall(color: accent.primary),
                      hintText: 'e.g. 🚴, 🎸, 🧗, 🥑, 🎮',
                      hintStyle: AppTypography.labelSmall(color: cs.onSurfaceDim),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      prefixIcon: Icon(Icons.add_reaction_outlined, color: accent.primary, size: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.onSurfaceDim),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Category Selector
                  Text('Category',
                      style: AppTypography.labelSmall(color: cs.onSurfaceMuted)),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: cs.surfaceVariant,
                    style: AppTypography.bodyMedium(color: cs.onSurface),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.onSurfaceDim),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent.primary),
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
                child: Text('Cancel',
                    style: AppTypography.labelLarge(color: cs.onSurfaceMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent.primary,
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
                  style: AppTypography.labelLarge(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _StaggeredItem({
    required this.child,
    required this.index,
  });

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.2),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final circumference = 2 * 3.14159 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace)) / radius;
      final sweepAngle = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}