import 'package:flutter/material.dart';
import '../../core/constants/feature_flags.dart';
import '../../core/services/db_service.dart';
import '../../models/crystal.dart';
import '../widgets/cg.dart';
import '../widgets/page_transitions.dart';
import 'crystal_detail_screen.dart';

/// Screen displaying a searchable crystal library with bottom navigation and a background title.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// Mood filters match words in a crystal's headline and description.
  static const Map<String, List<String>> _filters = {
    'All': [],
    'Calm': ['calm', 'peace', 'sleep', 'tranquil', 'sooth', 'relax', 'stress'],
    'Protection': ['protect', 'ground', 'shield', 'negative'],
    'Love': ['love', 'heart', 'compassion', 'relationship'],
    'Abundance': ['abundan', 'prosper', 'wealth', 'success', 'luck', 'money'],
    'Clarity': ['clarity', 'focus', 'mind', 'intuition', 'wisdom'],
  };
  String _filter = 'All';

  List<Crystal> _allCrystals = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final crystals = await DbService.fetchCrystals();
      if (!mounted) return;
      setState(() {
        _allCrystals = crystals;
        _loading = false;
        _error = null;
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
    final q = _query.toLowerCase();
    final words = _filters[_filter] ?? const [];
    return _allCrystals.where((c) {
      final text = '${c.name} ${c.headline} ${c.description}'.toLowerCase();
      if (q.isNotEmpty &&
          !c.name.toLowerCase().contains(q) &&
          !c.headline.toLowerCase().contains(q)) {
        return false;
      }
      if (words.isNotEmpty && !words.any(text.contains)) return false;
      return true;
    }).toList();
  }

  void _open(Crystal c) => Navigator.of(context).push(
        SmoothPageRoute(
          transition: SmoothTransition.slide,
          builder: (_) => CrystalDetailScreen(crystalName: c.name),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final items = _visibleCrystals;
    return CGPage(
      glowTop: -340,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: CG.brand,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CGHeading(eyebrow: 'Explore', title: 'Crystal library'),
                      const SizedBox(height: 18),
                      CGSearch(
                        hint: 'Search for crystals',
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v.trim()),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = _filters.keys.elementAt(i);
                      return CGChip(
                        f,
                        selected: f == _filter,
                        onTap: () => setState(() => _filter = f),
                      );
                    },
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(hasScrollBody: false, child: CGLoading())
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                    child: Center(
                      child: CGEmpty(
                        title: 'Could not load the library',
                        message: _error!,
                        action: 'Try again',
                        onAction: () {
                          setState(() => _loading = true);
                          _load();
                        },
                      ),
                    ),
                  ),
                )
              else if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                    child: Center(
                      child: CGEmpty(
                        title: 'No crystals found',
                        message: 'Try another name or filter.',
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      // Grows with the phone's text size so text never clips.
                      mainAxisExtent: 148 + MediaQuery.textScalerOf(context).scale(66),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _CrystalCard(
                        crystal: items[i],
                        onTap: () => _open(items[i]),
                      ),
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid card for a crystal in the library.
class _CrystalCard extends StatelessWidget {
  final Crystal crystal;
  final VoidCallback onTap;

  const _CrystalCard({required this.crystal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = FeatureFlags.showCrystalPhotos ? crystal.imageUrl : null;
    return CGCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (_, c) => CrystalThumb(
              name: crystal.name,
              imageUrl: url,
              width: c.maxWidth,
              height: 112,
              fallbackChild: Gem(color: CG.crystalColor(crystal.name), width: 44),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              crystal.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CG.display(19).copyWith(height: 1.15),
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                crystal.headline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CG.sub(12.5).copyWith(height: 1.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
