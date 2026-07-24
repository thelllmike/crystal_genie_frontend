import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';
import '../../core/services/db_service.dart';
import '../../models/find.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/glass.dart';
import '../widgets/page_transitions.dart';
import 'crystal_detail_screen.dart';
import 'main_shell.dart';

/// Screen showing user's saved crystals with tabs for "My finds" and "Favorites".
class SavedCrystalsScreen extends StatefulWidget {
  const SavedCrystalsScreen({Key? key}) : super(key: key);

  @override
  _SavedCrystalsScreenState createState() => _SavedCrystalsScreenState();
}

class _SavedCrystalsScreenState extends State<SavedCrystalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0 = My finds, 1 = Favorites
  String _query = '';

  List<Find> _myFinds = [];
  List<Find> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results =
          await Future.wait([DbService.recentFinds(), DbService.savedCrystals()]);
      if (!mounted) return;
      setState(() {
        _myFinds = results[0];
        _favorites = results[1];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load saved crystals: $e')),
      );
    }
  }

  List<Find> get _visible {
    final source = _selectedTab == 0 ? _myFinds : _favorites;
    if (_query.isEmpty) return source;
    final q = _query.toLowerCase();
    return source
        .where((f) => f.crystalName.toLowerCase().contains(q))
        .toList();
  }

  void _onNavTap(int idx) {
    MainShell.goToTab(context, idx);
  }

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
            top: MediaQuery.of(context).padding.top + 45,
            left: 0,
            right: 0,
            child:
                const Center(child: BackgroundTitle(text: 'Saved Crystals')),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenW * 0.15), // title overlap, like home

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
                                      onChanged: (v) =>
                                          setState(() => _query = v.trim()),
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
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _visible.isEmpty
                            ? Center(
                                child: Text(
                                  _selectedTab == 0
                                      ? 'No finds yet — scan your first crystal!'
                                      : 'No favorites yet — bookmark a result to save it',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 100),
                                itemCount: _visible.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, i) {
                                  final item = _visible[i];
                                  return _SavedCard(
                                    imagePath: 'assets/images/item.png',
                                    title: item.crystalName,
                                    description: item.headline.isNotEmpty
                                        ? item.headline
                                        : item.timeAgo,
                                    onLearnMore: () => Navigator.of(context).push(
                                      SmoothPageRoute(
                                        transition: SmoothTransition.slide,
                                        builder: (_) => CrystalDetailScreen(
                                            crystalName: item.crystalName),
                                      ),
                                    ),
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
            child: BottomNavBar(
              selectedIndex: 0,
              onTap: _onNavTap,
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
  final VoidCallback onLearnMore;

  const _SavedCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: double.infinity,
          height: 130,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0x80FBF5F3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // image
              Container(
                width: 114,
                height: 114,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFBF5F3), width: 1),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        height: 1.1,
                        color: Color(0xFF1A181B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                        height: 1.3,
                        color: Color(0xFF5E5E5E),
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
                          child: GestureDetector(
                            onTap: onLearnMore,
                            child: Container(
                              height: 36,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Color(0xFF34A0A4), Color(0xFF50B2C8)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF98CBCC), width: 1),
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
                                  Icon(HugeIcons.strokeRoundedArrowRight01,
                                      size: 20),
                                ],
                              ),
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

