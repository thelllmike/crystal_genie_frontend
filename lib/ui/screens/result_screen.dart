// lib/ui/screens/result_screen.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_router.dart';
import '../../core/constants/colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../../models/detection.dart';
import '../widgets/bottom_nav_bar.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save crystals')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${det.className} saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    }
  }

  void _onNavTap(int idx) {
    if (idx == 0) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRouter.home, (r) => false);
    } else if (idx == 1) {
      Navigator.of(context).pop(); // back to camera
    } else {
      Navigator.of(context).pushNamed(AppRouter.explore);
    }
  }

  @override
  Widget build(BuildContext context) {
    final det      = detections.first;
    final name     = det.className;
    final headline = det.description.headline;
    final desc     = det.description.description;
    final star     = det.description.starSign;
    final chakras  = det.description.chakras;
    final conf     = '${(det.confidence * 100).toStringAsFixed(0)}% match';

    const imgH    = 380.0;
    const overlap =  64.0;
    final cardW   = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      backgroundColor: AppColors.neutral20,
     
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0, right: 0,
            child: Center(
              child: Text(
                'You\'ve got a',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  height: 1.0,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 45),

                  // Name pill
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        width: cardW, height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.neutral.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: AppColors.neutral.withOpacity(0.5), width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'PlayfairDisplay',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  height: 1.0,
                                  color: Color(0xFF1A181B),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _saveCrystal,
                              child: Icon(
                                _saved
                                    ? HugeIcons.strokeRoundedBookmarkCheck02
                                    : HugeIcons.strokeRoundedBookmark02,
                                size: 24,
                                color: _saved
                                    ? AppColors.primary40
                                    : const Color(0xFF1A181B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: cardW, height: imgH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.neutral.withOpacity(0.5), width: 2),
                      ),
                      child: Image.file(imageFile, fit: BoxFit.cover),
                    ),
                  ),

                  // Detail card overlapping the image, sized to its content
                  Transform.translate(
                    offset: const Offset(0, -overlap),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 128, sigmaY: 128),
                        child: Container(
                          width: cardW,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0x59FBF5F3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontFamily: 'PlayfairDisplay',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0x3434A0A4),
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(
                                          color: const Color(0x5934A0A4)),
                                    ),
                                    child: Text(
                                      conf,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: AppColors.primary40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (headline.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  headline,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              if (star.isNotEmpty || chakras.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    if (star.isNotEmpty) ...[
                                      const Icon(
                                          HugeIcons.strokeRoundedConstellation,
                                          size: 20),
                                      const SizedBox(width: 4),
                                      Text(star),
                                      const SizedBox(width: 16),
                                    ],
                                    if (chakras.isNotEmpty) ...[
                                      const Icon(HugeIcons.strokeRoundedSpirals,
                                          size: 20),
                                      const SizedBox(width: 4),
                                      Flexible(child: Text(chakras)),
                                    ],
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                              Text(
                                desc.isNotEmpty
                                    ? desc
                                    : 'No description available for this crystal yet.',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.4,
                                  fontStyle: desc.isNotEmpty
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                  color: desc.isNotEmpty
                                      ? const Color(0xFF1A181B)
                                      : const Color(0xFF5E5E5E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),

          // bottom nav
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: BottomNavBar(selectedIndex: 1, onTap: _onNavTap),
          ),
        ],
      ),
    );
  }
}

