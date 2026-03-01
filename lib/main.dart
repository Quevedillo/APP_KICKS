import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'presentation/router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/stripe_service.dart';
import 'logic/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar locale para intl
  await initializeDateFormatting('es_ES', null);
  
  try {
    const supabaseUrl = String.fromEnvironment('PUBLIC_SUPABASE_URL');
    const supabaseKey = String.fromEnvironment('PUBLIC_SUPABASE_ANON_KEY');

    if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
    } else {
      print('❌ Warning: Supabase credentials not found. Ensure you pass them via --dart-define');
    }

    // Inicializar Stripe
    await StripeService.init();
  } catch (e) {
    print('❌ Error during initialization: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch guest order linker to auto-link orders on login
    ref.watch(guestOrderLinkerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'KicksPremium',
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
    );
  }
}
