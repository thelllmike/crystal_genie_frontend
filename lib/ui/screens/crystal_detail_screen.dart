import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_router.dart';
import '../../core/constants/feature_flags.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../../models/crystal.dart';
import '../widgets/cg.dart';

/// Read-only crystal detail page (opened from "Learn more" in the library
/// or saved crystals). Styled to match the scan result screen.
class CrystalDetailScreen extends StatefulWidget {
  final String crystalName;

  const CrystalDetailScreen({super.key, required this.crystalName});

  @override
  State<CrystalDetailScreen> createState() => _CrystalDetailScreenState();
}

class _CrystalDetailScreenState extends State<CrystalDetailScreen> {
  Crystal? _crystal;
  bool _loading = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final crystal = await DbService.fetchCrystalByName(widget.crystalName);
      if (!mounted) return;
      setState(() {
        _crystal = crystal;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_saved) return;
    if (!AuthService.isLoggedIn) {
      CG.snack(context, 'Sign in to save crystals');
      return;
    }
    try {
      await DbService.saveCrystal(
        crystalName: _crystal?.name ?? widget.crystalName,
        headline: _crystal?.headline ?? '',
      );
      if (!mounted) return;
      setState(() => _saved = true);
      CG.snack(context, '${_crystal?.name ?? widget.crystalName} saved');
    } catch (e) {
      if (!mounted) return;
      CG.snack(context, 'Could not save: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _crystal?.name ?? widget.crystalName;
    final headline = _crystal?.headline ?? '';
    final desc = _crystal?.description ?? '';
    final star = _crystal?.starSign ?? '';
    final chakras = _crystal?.chakras ?? '';
    final color = CG.crystalColor(name);
    final photo = FeatureFlags.showCrystalPhotos ? _crystal?.imageUrl : null;

    return CGPage(
      glow: color,
      glowTop: -200,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const CGBack(),
                  const Spacer(),
                  CGIconButton(
                    icon: _saved
                        ? HugeIcons.strokeRoundedBookmarkCheck02
                        : HugeIcons.strokeRoundedBookmark02,
                    tooltip: _saved ? 'Saved' : 'Save crystal',
                    background: _saved ? CG.brand : null,
                    foreground: _saved ? CG.onBrand : null,
                    borderColor: _saved ? CG.brand : null,
                    onTap: _save,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const CGLoading()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                      children: [
                        Row(
                          children: [
                            CrystalThumb(
                              name: name,
                              imageUrl: photo,
                              width: 128,
                              height: 150,
                              radius: 28,
                              fallbackChild: GemCluster(color: color, width: 92, height: 106),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CRYSTAL', style: CG.eyebrow()),
                                  const SizedBox(height: 6),
                                  Text(name, style: CG.display(name.length > 14 ? 32 : 40).copyWith(height: 1.02)),
                                  if (headline.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(headline, style: CG.sub(14.5).copyWith(fontStyle: FontStyle.italic)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (CG.splitList(chakras).isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final c in CG.splitList(chakras)) CGTag(c, color: color),
                            ],
                          ),
                        ],
                        const SizedBox(height: 22),
                        CGFactGrid(starSign: star, chakras: chakras),
                        const SizedBox(height: 26),
                        Text('Meaning', style: CG.display(20)),
                        const SizedBox(height: 8),
                        Text(
                          desc.isNotEmpty ? desc : 'No description available for this crystal yet.',
                          style: CG.sub(14.5).copyWith(
                            height: 1.6,
                            fontStyle: desc.isNotEmpty ? null : FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: CGButton(
                label: 'Shop crystals',
                icon: HugeIcons.strokeRoundedShoppingBag02,
                onPressed: () => Navigator.of(context).pushNamed(AppRouter.shop),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
