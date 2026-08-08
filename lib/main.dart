import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/habit.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely initialize Hive DB with fallbacks to prevent black screen on launch
  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitAdapter());
    }
    await Hive.openBox<Habit>('habits');
    await Hive.openBox('settings');
  } catch (e) {
    debugPrint('Hive Initialization Error: $e. Attempting clean recovery...');
    try {
      await Hive.deleteBoxFromDisk('habits');
      await Hive.openBox<Habit>('habits');
      // Settings box is non-critical, try to open it anyway
      try {
        await Hive.openBox('settings');
      } catch (_) {}
    } catch (err) {
      debugPrint('Hive Recovery Error: $err');
    }
  }

  // Safely initialize notifications asynchronously without blocking UI render
  NotificationService().init().then((_) {
    NotificationService().requestPermissions();
    NotificationService().scheduleDailyEveningReminder();
  }).catchError((e) {
    debugPrint('Notification Initialization Error: $e');
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recompute streaks when app resumes across midnight
    if (state == AppLifecycleState.resumed) {
      ref.read(habitsProvider.notifier).refreshAllStreaks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'StreakFlow',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
        extensions: <ThemeExtension<dynamic>>[accent],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent.primary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        extensions: <ThemeExtension<dynamic>>[accent],
      ),
      home: const HomeScreen(),
    );
  }
}