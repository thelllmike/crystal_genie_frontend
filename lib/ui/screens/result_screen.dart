import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';

/// Screen showing the result of capturing or selecting a crystal,
/// with overlapping image and a scrollable detail card that blurs the image beneath.
class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _selectedNav = 0;
  final String crystalName = 'Agnitite';
  final String subtitle = 'A stone to harness collective energy';
  final String imagePath = 'assets/images/takephoto.png';
  final String description =
      'The currents of Agnitite are powerful and often make the body feel warm or even hot. '
      'They tend to enter through the crown chakra, working their way down to the heart, and flowing from there throughout the body. '
      'Agnitite stimulates the entire liquid crystal body matrix, and helps the body learn to resonate in vibrational unity. '
      'It can enhance qualities such as intuition, healing, strength of will, a sense of one’s purpose, and awareness of one’s shared consciousness with that of the world at large. '
      'For spiritual self healing agnitite is recommended to those wishing to purify the blood and cellular tissues. '
      'It can act as a detoxifying influence at the same time it energizes all of one’s system. '
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
      'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
      'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
      'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  // Fixed dimensions
  static const double _imageHeight = 380;
  static const double _detailHeight = 464;
  static const double _overlap = 64;

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double cardWidth = screenW - 32; // padding 16 each side

    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(
        children: [
          // Background "You've got a" text
          Positioned(
            top: 40,
            left: 16,
            child: Text(
              'You\'ve got a',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontSize: 32,
                height: 1.0,
                letterSpacing: 0,
                color: AppColors.primary,
              ),
            ),
          ),
          // Content scroll
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Pill-shaped header bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          width: cardWidth,
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.neutral.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: AppColors.neutral.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  crystalName,
                                  style: const TextStyle(
                                    fontFamily: 'PlayfairDisplay',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 24,
                                    height: 1.0,
                                    color: Color(0xFF1A181B),
                                  ),
                                ),
                              ),
                              const Icon(
                                HugeIcons.strokeRoundedBookmark02,
                                size: 24,
                                color: Color(0xFF1A181B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Overlapping image + details
                    SizedBox(
                      width: cardWidth,
                      height: _imageHeight + _detailHeight - _overlap,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Static image frame
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: cardWidth,
                              height: _imageHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.neutral.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Detail card
                          Positioned(
                            top: _imageHeight - _overlap,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 128, sigmaY: 128),
                                child: Container(
                                  width: cardWidth,
                                  height: _detailHeight,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0x59FBF5F3),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        crystalName,
                                        style: const TextStyle(
                                          fontFamily: 'PlayfairDisplay',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: const [
                                          Icon(HugeIcons.strokeRoundedConstellation, size: 20),
                                          SizedBox(width: 4),
                                          Text('N/A', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
                                          SizedBox(width: 16),
                                          Icon(HugeIcons.strokeRoundedSpirals, size: 20),
                                          SizedBox(width: 4),
                                          Text('Root and earth star', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Scrollable description within the detail card
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Text(
                                            description,
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // spacing to allow full scroll
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation bar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _BottomNavBar(
              selectedIndex: _selectedNav,
              onTap: (idx) => setState(() => _selectedNav = idx),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable blurred pill-shaped bottom navigation
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
            color: active ? AppColors.primary20.withOpacity(0.35) : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: active
                  ? AppColors.primary20.withOpacity(0.35)
                  : AppColors.neutral.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: active ? AppColors.primary60 : AppColors.neutral100,
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
            color: AppColors.neutral20.withOpacity(0.2),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.neutral.withOpacity(0.5), width: 1),
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