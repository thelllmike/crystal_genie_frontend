import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/find_card.dart';

/// Home screen displaying recent crystal finds with responsive layout.
class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({Key? key, this.userName = 'Jon'}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String profileImg = 'assets/images/profile.png';
  final List<Map<String, String>> finds = List.generate(
    5,
    (_) => {
      'image': 'assets/images/item.png',
      'title': 'Aegirine',
      'subtitle': 'A stone of mental health and protection',
      'timeAgo': '2 days ago',
    },
  );

  int _selectedNav = 0;

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
            Positioned(
              top: 45,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Hi welcome,',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: width * 0.08,
                    height: 1.0,
                    color: const Color(0xFF50B2C8),
                  ),
                ),
              ),
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
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: AssetImage(profileImg),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                            const Icon(HugeIcons.strokeRoundedSettings03,
                                size: 24, color: Colors.black87),
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
                    child: ListView.separated(
                      itemCount: finds.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) {
                        final f = finds[i];
                        return FindCard(
                          width: cardWidth,
                          imagePath: f['image']!,
                          title: f['title']!,
                          subtitle: f['subtitle']!,
                          timeAgo: f['timeAgo']!,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Floating bottom nav bar
            Positioned(
              bottom: padding,
              left: padding,
              right: padding,
              child: BottomNavBar(
                selectedIndex: _selectedNav,
                onTap: (idx) => setState(() => _selectedNav = idx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}