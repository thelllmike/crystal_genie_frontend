import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';

/// Screen showing user's saved crystals with tabs for "My finds" and "Favorites".
class SavedCrystalsScreen extends StatefulWidget {
  const SavedCrystalsScreen({Key? key}) : super(key: key);

  @override
  _SavedCrystalsScreenState createState() => _SavedCrystalsScreenState();
}

class _SavedCrystalsScreenState extends State<SavedCrystalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0 = My finds, 1 = Favorites

  // Sample data
  final List<Map<String, String>> _myFinds = List.generate(
    4,
    (_) => {
      'image': 'assets/images/item.png',
      'name': 'Aegirine',
      'description': 'The currents of Aegirine are powerful and often make the body feel warm or even hot. They tend to enter through the crown chakra, working their way down to the heart,...'
    },
  );
  final List<Map<String, String>> _favorites = <Map<String, String>>[];

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double outer = screenW - 32;

    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(
        children: [
          // Background title
          Positioned(
            top: 20,
            left: 16,
            child: Text(
              'Saved Crystals',
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
                  const SizedBox(height: 60),

                  // Search bar + grid toggle
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        width: outer,
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x59FBF5F3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // input
                            Container(
                              width: 328,
                              height: 24,
                              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                              decoration: BoxDecoration(
                                color: const Color(0x80FBF5F3),
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
                                        hintText: 'Search saved crystals',
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
                                  const Icon(HugeIcons.strokeRoundedSearch01, size: 20),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(HugeIcons.strokeRoundedGridView, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tabs
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        width: outer,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x59FBF5F3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: Container(
                                width: 178,
                                height: 36,
                                margin: const EdgeInsets.all(2),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  gradient: _selectedTab == 0
                                      ? const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [Color(0xFF34A0A4), Color(0xFF50B2C8)],
                                        )
                                      : null,
                                  color: _selectedTab == 1
                                      ? const Color(0x59FBF5F3)
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFF98CBCC), width: 1),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'My finds',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: _selectedTab == 0
                                        ? Colors.white
                                        : const Color(0xFF34A0A4),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: Container(
                                width: 178,
                                height: 36,
                                margin: const EdgeInsets.all(2),
                                alignment: Alignment.center,
                                child: Text(
                                  'Favorites',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: _selectedTab == 1
                                        ? Colors.white
                                        : const Color(0xFF34A0A4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List
                  Expanded(
                    child: ListView.separated(
                      itemCount: _selectedTab == 0 ? _myFinds.length : _favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final item = (_selectedTab == 0 ? _myFinds : _favorites)[i];
                        return _SavedCard(
                          imagePath: item['image']!,
                          title: item['name']!,
                          description: item['description']!,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BottomNavBar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _BottomNavBar(
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}

// Card for saved crystals list
class _SavedCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _SavedCard({
    required this.imagePath,
    required this.title,
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
            color: const Color(0x80FBF5F3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // image
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFBF5F3), width: 1),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // details
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
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        fontSize: 8,
                        height: 1.0,
                      ),
                    ),
                    const Spacer(),
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
                              colors: [
                                Color(0x3434A0A4),
                                Color(0x3450B2C8)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary20.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            HugeIcons.strokeRoundedBookmark02,
                            color: Color(0xFF34A0A4),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // learn more button
                        Expanded(
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF34A0A4), Color(0xFF50B2C8)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF98CBCC), width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Learn more',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    height: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(HugeIcons.strokeRoundedArrowRight01, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
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

/// Reusable bottom nav bar (same as other screens)
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
              color: active ? AppColors.primary20.withOpacity(0.35) : AppColors.neutral.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(icon, color: active ? AppColors.primary60 : AppColors.neutral100),
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
