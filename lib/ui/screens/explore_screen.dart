import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app_router.dart';
import '../../core/constants/colors.dart';
import '../../core/services/db_service.dart';
import '../../models/crystal.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/glass.dart';

/// Screen displaying a searchable crystal library with bottom navigation and a background title.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All'];
  final int _selectedFilter = 0;

  List<Crystal> _allCrystals = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final crystals = await DbService.fetchCrystals();
      if (!mounted) return;
      setState(() {
        _allCrystals = crystals;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  List<Crystal> get _visibleCrystals {
    if (_query.isEmpty) return _allCrystals;
    final q = _query.toLowerCase();
    return _allCrystals
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.headline.toLowerCase().contains(q))
        .toList();
  }

  void _onNavTap(int idx) {
    if (idx == 2) return;
    if (idx == 0) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRouter.home, (r) => false);
    } else {
      Navigator.of(context).pushNamed(AppRouter.takePhoto);
    }
  }

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
            top: MediaQuery.of(context).padding.top + 45,
            left: 0,
            right: 0,
            child:
                const Center(child: BackgroundTitle(text: 'Crystal library')),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenWidth * 0.15), // title overlap, like home
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
                                      onChanged: (v) =>
                                          setState(() => _query = v.trim()),
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
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(
                                child: Text(
                                  'Could not load the library:\n$_error',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat'),
                                ),
                              )
                            : _visibleCrystals.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No crystals found',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding:
                                        const EdgeInsets.only(bottom: 100),
                                    itemCount: _visibleCrystals.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final item = _visibleCrystals[index];
                                      return _CrystalCard(
                                        imagePath: 'assets/images/item.png',
                                        title: item.name,
                                        subtitle: item.headline,
                                        description: item.description,
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
            child: BottomNavBar(
              selectedIndex: 2,
              onTap: _onNavTap,
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
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0x80FBF5F3), // White-50
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crystal image
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 12),
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
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: Color(0xFF5E5E5E),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.35,
                        color: Color(0xFF303030),
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

