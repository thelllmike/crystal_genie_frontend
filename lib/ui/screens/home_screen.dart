import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../../core/services/subscription_service.dart';
import '../../models/find.dart';
import '../widgets/find_card.dart';
import '../widgets/cg.dart';
import '../widgets/page_transitions.dart';
import 'crystal_detail_screen.dart';
import 'main_shell.dart';

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
    // Reload after a scan saves a find, and whenever Home is shown again.
    DbService.findsChanged.addListener(_reload);
    MainShell.selectedTab.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    DbService.findsChanged.removeListener(_reload);
    MainShell.selectedTab.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (MainShell.selectedTab.value == MainShell.homeTab) _reload();
  }

  Future<void> _reload() {
    if (!mounted) return Future.value();
    final next = DbService.recentFinds();
    setState(() { _finds = next; });
    return next.then((_) {}, onError: (_) {});
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName {
    final name = AuthService.displayName.trim();
    return name.isEmpty ? 'there' : name.split(RegExp(r'\s+')).first;
  }

  void _openDetail(String name) => Navigator.of(context).push(
        SmoothPageRoute(
          transition: SmoothTransition.slide,
          builder: (_) => CrystalDetailScreen(crystalName: name),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CGPage(
      glowTop: -300,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: CG.brand,
          onRefresh: _reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
            children: [
              _header(),
              const SizedBox(height: 24),
              const _ScanHero(),
              const SizedBox(height: 28),
              FutureBuilder<List<Find>>(
                future: _finds,
                builder: (context, snap) {
                  final loading =
                      snap.connectionState != ConnectionState.done && !snap.hasData;
                  final finds = snap.data ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Recent finds', style: CG.display(22))),
                          if (finds.isNotEmpty)
                            CGLink(
                              'See all',
                              onTap: () => Navigator.of(context).pushNamed(AppRouter.savedCrystals),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (loading)
                        const Padding(padding: EdgeInsets.only(top: 40), child: CGLoading())
                      else if (finds.isEmpty)
                        CGEmpty(
                          title: 'No finds yet',
                          message: 'Scan your first crystal and it will show up here.',
                          action: 'Open camera',
                          onAction: () => MainShell.selectedTab.value = MainShell.cameraTab,
                        )
                      else
                        for (final f in finds) ...[
                          FindCard(
                            name: f.crystalName,
                            headline: f.headline,
                            timeAgo: f.timeAgo,
                            onTap: () => _openDetail(f.crystalName),
                          ),
                          const SizedBox(height: 12),
                        ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Profile',
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRouter.profile),
            child: CGAvatar(initials: AuthService.initials),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting, style: CG.mute(13)),
              Text(_firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CG.display(24).copyWith(height: 1.1)),
            ],
          ),
        ),
        CGIconButton(
          icon: HugeIcons.strokeRoundedBookmark02,
          tooltip: 'Saved crystals',
          onTap: () => Navigator.of(context).pushNamed(AppRouter.savedCrystals),
        ),
        const SizedBox(width: 12),
        CGIconButton(
          icon: HugeIcons.strokeRoundedShoppingBag02,
          tooltip: 'Crystal shop',
          onTap: () => Navigator.of(context).pushNamed(AppRouter.shop),
        ),
      ],
    );
  }
}

/// "Identify a crystal" card with the trial/premium status.
class _ScanHero extends StatelessWidget {
  const _ScanHero();

  String? _statusLabel(SubscriptionStatus? s) {
    if (s == null) return null;
    if (s.isSubscribed) return 'Premium';
    if (s.isTrialActive) {
      final d = s.trialDaysLeft;
      return 'Free trial · $d ${d == 1 ? 'day' : 'days'} left';
    }
    return 'Trial ended';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 196,
      decoration: BoxDecoration(
        gradient: CG.softGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: CG.line2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            const Positioned(
              right: 20,
              bottom: -6,
              child: GemCluster(color: Color(0xFFA98BFF), width: 128, height: 150),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<SubscriptionStatus?>(
                    valueListenable: SubscriptionService.notifier,
                    builder: (_, status, __) {
                      final label = _statusLabel(status);
                      if (label == null) return const SizedBox(height: 26);
                      return CGTag(label, color: CG.mint, dot: false);
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 190,
                    child: Text('Identify a crystal', style: CG.display(28)),
                  ),
                  const Spacer(),
                  CGButton(
                    label: 'Scan now',
                    icon: HugeIcons.strokeRoundedCamera01,
                    small: true,
                    expand: false,
                    onPressed: () => MainShell.selectedTab.value = MainShell.cameraTab,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
