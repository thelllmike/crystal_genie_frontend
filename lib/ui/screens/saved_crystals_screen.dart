import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/services/db_service.dart';
import '../../models/find.dart';
import '../widgets/cg.dart';
import '../widgets/find_card.dart';
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
      CG.snack(context, 'Could not load saved crystals: $e');
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    final count = _myFinds.length;
    return CGPage(
      glowTop: -340,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: CG.brand,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              const Align(alignment: Alignment.centerLeft, child: CGBack()),
              const SizedBox(height: 16),
              CGHeading(
                title: 'Saved crystals',
                subtitle: _loading
                    ? ' '
                    : '$count ${count == 1 ? 'stone' : 'stones'} in your collection',
              ),
              const SizedBox(height: 20),
              CGSearch(
                hint: 'Search saved crystals',
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
              const SizedBox(height: 14),
              CGSegmented(
                options: const ['My finds', 'Favorites'],
                selected: _selectedTab,
                onChanged: (i) => setState(() => _selectedTab = i),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Padding(padding: EdgeInsets.only(top: 60), child: CGLoading())
              else if (items.isEmpty)
                CGEmpty(
                  title: _selectedTab == 0 ? 'No finds yet' : 'No favorites yet',
                  message: _query.isNotEmpty
                      ? 'Nothing matches "$_query".'
                      : _selectedTab == 0
                          ? 'Scan your first crystal and it will show up here.'
                          : 'Bookmark a scan result to keep it here.',
                  action: _selectedTab == 0 && _query.isEmpty ? 'Open camera' : null,
                  onAction: () => MainShell.goToTab(context, MainShell.cameraTab),
                )
              else
                for (final item in items) ...[
                  FindCard(
                    name: item.crystalName,
                    headline: item.headline,
                    timeAgo: item.timeAgo,
                    trailing: _selectedTab == 1
                        ? const Icon(HugeIcons.strokeRoundedBookmarkCheck02, color: CG.brand, size: 22)
                        : null,
                    onTap: () => Navigator.of(context).push(
                      SmoothPageRoute(
                        transition: SmoothTransition.slide,
                        builder: (_) => CrystalDetailScreen(crystalName: item.crystalName),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
