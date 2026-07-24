import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';
import 'TakePhotoScreen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';

/// Hosts the three bottom-nav destinations in a single route.
///
/// Tapping a tab only swaps the visible child of an [IndexedStack] — no route
/// is pushed, so pages are never rebuilt and keep their scroll position and
/// already-loaded data. The nav bar lives here rather than in each screen.
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  static const int homeTab = 0;
  static const int cameraTab = 1;
  static const int exploreTab = 2;

  /// The visible tab. Shared so pages pushed on top of the shell (the scan
  /// result, saved crystals) can switch tabs and drop back to it.
  static final ValueNotifier<int> selectedTab = ValueNotifier<int>(homeTab);

  /// Shows [index] in the shell and closes anything stacked above it.
  static void goToTab(BuildContext context, int index) {
    selectedTab.value = index;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    MainShell.selectedTab.value = widget.initialIndex;
    MainShell.selectedTab.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    MainShell.selectedTab.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final index = MainShell.selectedTab.value;

    return Scaffold(
      // Each tab paints its own full-bleed background, so the shell must not
      // inset them — only the nav bar respects the safe area.
      body: Stack(
        children: [
          // Positioned.fill + expand so each tab's Scaffold gets tight
          // constraints and fills the screen exactly as it did on its own.
          Positioned.fill(
            child: IndexedStack(
              index: index,
              sizing: StackFit.expand,
              children: [
                const HomeScreen(),
                // The camera is only powered up while its tab is visible.
                TakePhotoScreen(active: index == MainShell.cameraTab),
                const ExploreScreen(),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BottomNavBar(
                  selectedIndex: index,
                  onTap: (i) => MainShell.selectedTab.value = i,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
