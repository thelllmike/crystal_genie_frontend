import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../../models/find.dart';
import '../widgets/find_card.dart';
import '../widgets/glass.dart';
import '../widgets/page_transitions.dart';
import 'crystal_detail_screen.dart';

/// Home screen displaying recent crystal finds with responsive layout.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Find>> _finds;

  @override
  void initState() {
    super.initState();
    _finds = DbService.recentFinds();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const padding = 16.0;
    final cardWidth = width - padding * 2;

   return Scaffold(
      backgroundColor: const Color(0xFF98CBCC),
      body: SafeArea(
        child: Stack(
          children: [
            // Centered “Hi welcome,” behind the bar
            const Positioned(
              top: 45,
              left: 0,
              right: 0,
              child: Center(child: BackgroundTitle(text: 'Hi welcome,')),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: padding, vertical: padding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: width * 0.15),

                  // Blurred pill AppBar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        width: cardWidth,
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0x59FBF5F3),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                              color: const Color(0x80FBF5F3), width: 1),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRouter.profile),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        const Color(0xFF34A0A4),
                                    child: Text(
                                      AuthService.initials,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AuthService.displayName,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                  HugeIcons.strokeRoundedShoppingBag02,
                                  size: 24,
                                  color: Colors.black87),
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRouter.shop),
                            ),
                            IconButton(
                              icon: const Icon(
                                  HugeIcons.strokeRoundedSettings03,
                                  size: 24,
                                  color: Colors.black87),
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRouter.profile),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Recent Finds',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 1.0,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List of FindCards
                  Expanded(
                    child: FutureBuilder<List<Find>>(
                      future: _finds,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final finds = snap.data ?? [];
                        if (finds.isEmpty) {
                          return const Center(
                            child: Text(
                              'No finds yet — scan your first crystal!',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: finds.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, i) {
                            final f = finds[i];
                            return FindCard(
                              width: cardWidth,
                              imagePath: 'assets/images/item.png',
                              title: f.crystalName,
                              subtitle: f.headline,
                              timeAgo: f.timeAgo,
                              onLearnMore: () => Navigator.of(context).push(
                                SmoothPageRoute(
                                  transition: SmoothTransition.slide,
                                  builder: (_) => CrystalDetailScreen(
                                    crystalName: f.crystalName,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // The floating bottom nav bar is owned by MainShell.
          ],
        ),
      ),
    );
  }
}