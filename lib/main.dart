import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.dart';
import 'core/constants/colors.dart';
import 'core/constants/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
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
      routes: AppRouter.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
