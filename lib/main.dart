import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.dart';
import 'core/constants/colors.dart';
import 'core/constants/stripe_config.dart';
import 'core/constants/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  // Configure Stripe, but never let a bad/placeholder key blank the whole app.
  // Payment will error clearly at checkout instead of crashing at startup.
  final key = StripeConfig.publishableKey;
  if (key.startsWith('pk_') && !key.contains('REPLACE')) {
    try {
      Stripe.publishableKey = key;
      await Stripe.instance.applySettings();
    } catch (e, s) {
      debugPrint('Stripe init failed: $e\n$s');
    }
  } else {
    debugPrint('Stripe not configured: set a real key in StripeConfig.');
  }
  runApp(const CrystalGenieApp());
}

class CrystalGenieApp extends StatelessWidget {
  const CrystalGenieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crystal Genie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: AppColors.primaryBg,
      ),
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
