// lib/src/ui/screens/home_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({Key? key, this.userName = 'Jon'}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String profileImg = 'assets/images/profile.png';
  final List<Map<String, String>> finds = [
    {
      'image':    'assets/images/item.png',
      'title':    'Aegirine',
      'subtitle': 'A stone of mental health and protection',
      'timeAgo':  '2 days ago',
    },
    {
      'image':    'assets/images/item.png',
      'title':    'Aegirine',
      'subtitle': 'A stone of mental health and protection',
      'timeAgo':  '2 days ago',
    },
  ];

  int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF98CBCC), // Primary-BG
      body: Stack(
        children: [
          // 1) Giant “Hi welcome,” behind the bar
          Positioned(
            top: 40,
            left: 16,
            child: Text(
              'Hi welcome,',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontSize: 72,
                height: 1.0,
                color: Color(0xFF50B2C8),
              ),
            ),
          ),

          // 2) Main content (AppBar + List)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Blurred pill AppBar ───────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0x59FBF5F3),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: const Color(0x80FBF5F3), width: 1),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 18, backgroundImage: AssetImage(profileImg)),
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
                            const Icon(HugeIcons.strokeRoundedSettings03, size: 24, color: Colors.black87),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── Header ───────────────────────────────────
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

                  // ─── List of cards ─────────────────────────────
                  Expanded(
                    child: ListView.separated(
                      itemCount: finds.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) {
                        final f = finds[i];
                        return _FindCard(
                          imagePath: f['image']!,
                          title:     f['title']!,
                          subtitle:  f['subtitle']!,
                          timeAgo:   f['timeAgo']!,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3) Floating bottom nav bar
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _BottomNavBar(
                selectedIndex: _selectedNav,
                onTap: (idx) => setState(() => _selectedNav = idx),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Extracted card widget to keep build() tidy
class _FindCard extends StatelessWidget {
  final String imagePath, title, subtitle, timeAgo;
  const _FindCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          height: 138,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0x80FBF5F3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x80FBF5F3), width: 1),
          ),
          child: Row(
            children: [
              // fixed-size image
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1),
                  image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
                ),
              ),

              const SizedBox(width: 8),

              // flexible content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // title/subtitle/time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                              color: Color(0xFF1A181B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: 8,
                              color: Color(0xFF1A181B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Color(0xFF5E5E5E),
                            ),
                          ),
                        ],
                      ),

                      // buttons
                      Row(
                        children: [
                          // bookmark
                          Container(
                            width: 48,
                            height: 36,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0x3434A0A4), Color(0x3450B2C8)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0x5934A0A4), width: 1),
                            ),
                            child: const Icon(HugeIcons.strokeRoundedBookmark02, color: Color(0xFF34A0A4), size: 20),
                          ),

                          const SizedBox(width: 8),

                          // learn more
                          Expanded(
                            child: Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Color(0xFF34A0A4), Color(0xFF50B2C8)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF98CBCC), width: 1),
                              ),
                              child: const Center(
                                child: Text(
                                  'Learn more',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Extracted bottom nav bar for clarity
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget _item(IconData icon, int idx) {
      final bool active = idx == selectedIndex;
      return GestureDetector(
        onTap: () => onTap(idx),
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? const Color(0x5934A0A4) : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: active ? const Color(0x5934A0A4) : const Color(0x80FBF5F3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: active ? Colors.white : const Color(0xFF1A181B),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x33FBF5F3),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: const Color(0x80FBF5F3), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _item(HugeIcons.strokeRoundedHome08, 0),
              _item(HugeIcons.strokeRoundedIrisScan, 1),
              _item(HugeIcons.strokeRoundedGem, 2),
            ],
          ),
        ),
      ),
    );
  }
}