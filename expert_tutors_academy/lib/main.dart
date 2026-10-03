import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'config/firebase_options.dart';
import 'config/router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  usePathUrlStrategy(); // Enable clean URLs without #
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase initialization notice: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: ExpertTutorsApp(),
    ),
  );
}

class ExpertTutorsApp extends ConsumerWidget {
  const ExpertTutorsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Expert Tutors Academy — ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
