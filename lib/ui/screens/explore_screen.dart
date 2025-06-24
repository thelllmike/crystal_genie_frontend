import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';

/// Screen displaying a searchable crystal library with bottom navigation and a background title.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All', 'Type A', 'Type B'];
  int _selectedFilter = 0;
  int _selectedNav = 0;

  final List<Map<String, String>> _crystals = [
    {
      'image': 'assets/images/item.png',
      'name': 'Abalone (Paua Shell)',
      'subtitle': 'Stone of patience',
      'description': 'Abalone shell carries gentle yet deeply healing energy, guiding us toward emotional balance and inner clarity. It teaches patience and helps us look within for the answers we seek, fostering emotional control and self-understanding. As a powerful ally for chakra alignment, Abalone enhances awareness of both our inner strengths and vulnerabilities, encouraging growth thro...'
    },
     {
      'image': 'assets/images/item.png',
      'name': 'Abalone (Paua Shell)',
      'subtitle': 'Stone of patience',
      'description': 'Abalone shell carries gentle yet deeply healing energy, guiding us toward emotional balance and inner clarity. It teaches patience and helps us look within for the answers we seek, fostering emotional control and self-understanding. As a powerful ally for chakra alignment, Abalone enhances awareness of both our inner strengths and vulnerabilities, encouraging growth thro...'
    },
     {
      'image': 'assets/images/item.png',
      'name': 'Abalone (Paua Shell)',
      'subtitle': 'Stone of patience',
      'description': 'Abalone shell carries gentle yet deeply healing energy, guiding us toward emotional balance and inner clarity. It teaches patience and helps us look within for the answers we seek, fostering emotional control and self-understanding. As a powerful ally for chakra alignment, Abalone enhances awareness of both our inner strengths and vulnerabilities, encouraging growth thro...'
    },
     {
      'image': 'assets/images/item.png',
      'name': 'Abalone (Paua Shell)',
      'subtitle': 'Stone of patience',
      'description': 'Abalone shell carries gentle yet deeply healing energy, guiding us toward emotional balance and inner clarity. It teaches patience and helps us look within for the answers we seek, fostering emotional control and self-understanding. As a powerful ally for chakra alignment, Abalone enhances awareness of both our inner strengths and vulnerabilities, encouraging growth thro...'
    },
     {
      'image': 'assets/images/item.png',
      'name': 'Abalone (Paua Shell)',
      'subtitle': 'Stone of patience',
      'description': 'Abalone shell carries gentle yet deeply healing energy, guiding us toward emotional balance and inner clarity. It teaches patience and helps us look within for the answers we seek, fostering emotional control and self-understanding. As a powerful ally for chakra alignment, Abalone enhances awareness of both our inner strengths and vulnerabilities, encouraging growth thro...'
    },
    // Add more entries here
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double outerWidth = screenWidth - 32; // 16px padding each side

    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(
        children: [
          // Background title
          Positioned(
            top: 20,
            left: 16,
            child: Text(
              'Crystal library',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontSize: 52,
                height: 1.0,
                letterSpacing: 0,
                color: Color(0xFF34A0A4),
              ).copyWith(color: const Color(0xFF34A0A4).withOpacity(0.3)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60), // space for background title overlap
                  // Search & filter row
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        width: outerWidth,
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x59FBF5F3), // White-35
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Search box
                            Container(
                              width: 328,
                              height: 24,
                              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                              decoration: BoxDecoration(
                                color: const Color(0x80FBF5F3), // White-50
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isCollapsed: true,
                                        hintText: 'Search for crystals',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          height: 1.0,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    HugeIcons.strokeRoundedSearch01,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              HugeIcons.strokeRoundedFilterHorizontal,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Active filter label
                  Row(
                    children: [
                      const Text(
                        'Filters: ',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _filters[_selectedFilter],
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Crystal list
                  Expanded(
                    child: ListView.separated(
                      itemCount: _crystals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = _crystals[index];
                        return _CrystalCard(
                          imagePath: item['image']!,
                          title: item['name']!,
                          subtitle: item['subtitle']!,
                          description: item['description']!,
                        );
                      },
                    ),
                  ),
                ],
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

/// Card widget for each crystal entry.
class _CrystalCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String description;

  const _CrystalCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: 380,
          height: 138,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0x80FBF5F3), // White-50
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Crystal image
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFBF5F3),
                    width: 1,
                  ),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontWeight: FontWeight.w400,
                        fontSize: 24,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x801A181B), // Black-50
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                          fontSize: 8,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontSize: 8,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable blurred pill-shaped bottom navigation.
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
