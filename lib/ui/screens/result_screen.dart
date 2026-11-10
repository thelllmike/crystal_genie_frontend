// lib/ui/screens/result_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../../models/detection.dart';
import '../widgets/cg.dart';
import '../widgets/page_transitions.dart';
import 'crystal_detail_screen.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final List<Detection> detections;

  const ResultScreen({
    Key? key,
    required this.imageFile,
    required this.detections,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saved = false;

  File get imageFile => widget.imageFile;
  List<Detection> get detections => widget.detections;

  Future<void> _saveCrystal() async {
    if (_saved) return;
    if (!AuthService.isLoggedIn) {
      CG.snack(context, 'Sign in to save crystals');
      return;
    }
    final det = detections.first;
    try {
      await DbService.saveCrystal(
        crystalName: det.className,
        headline: det.description.headline,
      );
      if (!mounted) return;
      setState(() => _saved = true);
      CG.snack(context, '${det.className} saved');
    } catch (e) {
      if (!mounted) return;
      CG.snack(context, 'Could not save: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final det = detections.first;
    final name = det.className;
    final headline = det.description.headline;
    final desc = det.description.description;
    final star = det.description.starSign;
    final chakras = det.description.chakras;
    final pct = (det.confidence * 100).clamp(0, 100).toDouble();
    final color = CG.crystalColor(name);

    return CGPage(
      glow: color,
      glowTop: -120,
      glowSize: 720,
      rings: true,
      ringsTop: 70,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  CGBack(onTap: () => Navigator.of(context).pop()),
                  const Spacer(),
                  const CGChip("You've got a"),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                children: [
                  Center(
                    child: Container(
                      width: 148,
                      height: 172,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: color.withValues(alpha: .55), width: 2),
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: .28), blurRadius: 36, offset: const Offset(0, 14)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.file(imageFile, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(name, textAlign: TextAlign.center, style: CG.display(54).copyWith(height: 1)),
                  ),
                  if (headline.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: CG.sub(16).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                  if (CG.splitList(chakras).isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [for (final c in CG.splitList(chakras)) CGTag(c, color: color)],
                    ),
                  ],
                  const SizedBox(height: 20),
                  CGCard(
                    padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF0EDFC), Color(0xFFE6F3F2)]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(HugeIcons.strokeRoundedCamera01, color: CG.brand, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${pct.toStringAsFixed(0)}% match',
                                  style: CG.body(16, weight: FontWeight.w700, height: 1.2)),
                              const SizedBox(height: 7),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: pct / 100,
                                  minHeight: 6,
                                  backgroundColor: CG.s3,
                                  color: CG.brand,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        CGLink('Retake', onTap: () => Navigator.of(context).pop()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  CGFactGrid(starSign: star, chakras: chakras),
                  const SizedBox(height: 16),
                  Text(
                    desc.isNotEmpty ? desc : 'No description available for this crystal yet.',
                    style: CG.sub(14.5).copyWith(
                      height: 1.55,
                      fontStyle: desc.isNotEmpty ? null : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Tooltip(
                      message: _saved ? 'Saved' : 'Save to collection',
                      child: Material(
                        color: _saved ? CG.brand : CG.s2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: _saved ? CG.brand : CG.line2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: _saveCrystal,
                          child: SizedBox(
                            height: 54,
                            child: Icon(
                              _saved
                                  ? HugeIcons.strokeRoundedBookmarkCheck02
                                  : HugeIcons.strokeRoundedBookmark02,
                              color: _saved ? CG.onBrand : CG.tx,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CGButton(
                      label: 'Learn more',
                      onPressed: () => Navigator.of(context).push(
                        SmoothPageRoute(
                          transition: SmoothTransition.slide,
                          builder: (_) => CrystalDetailScreen(crystalName: name),
                        ),
                      ),
                    ),
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
