import 'package:flutter/material.dart';
import 'app_router.dart';

void main() => runApp(const CrystalGenieApp());

class CrystalGenieApp extends StatelessWidget {
  const CrystalGenieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crystal Genie',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}