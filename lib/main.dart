import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/habit.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely initialize Hive DB with fallbacks to prevent black screen on launch
  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitAdapter());
    }
    await Hive.openBox<Habit>('habits');
  } catch (e) {
    debugPrint('Hive Initialization Error: $e. Attempting clean recovery...');
    try {
      await Hive.deleteBoxFromDisk('habits');
      await Hive.openBox<Habit>('habits');
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
    return MaterialApp(
      title: 'StreakFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0E14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}