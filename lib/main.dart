import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.dart';
import 'core/constants/stripe_config.dart';
import 'core/constants/supabase_config.dart';
import 'core/services/apple_subscription.dart';
import 'core/services/subscription_service.dart';
import 'ui/widgets/cg.dart';

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
  if (SubscriptionService.usesApplePurchase) AppleSubscription.start();
  runApp(const CrystalGenieApp());
}

class CrystalGenieApp extends StatelessWidget {
  const CrystalGenieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crystal Genie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CG.brand,
          primary: CG.brand,
          surface: CG.bg,
          error: CG.danger,
        ),
        fontFamily: CG.sans,
        scaffoldBackgroundColor: CG.bg,
        splashFactory: InkSparkle.splashFactory,
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: CG.brand),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: CG.tx,
          contentTextStyle: CG.body(14,
              color: Colors.white, weight: FontWeight.w700, height: 1.3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: CG.s2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28)),
          titleTextStyle: CG.display(24),
          contentTextStyle: CG.sub(14.5),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: CG.brand,
            textStyle: CG.body(15, weight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: CG.s1,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: CG.line2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: CG.line2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: CG.brand, width: 1.5),
          ),
        ),
      ),
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
