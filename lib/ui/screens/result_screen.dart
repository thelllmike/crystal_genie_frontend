// lib/ui/screens/result_screen.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/constants/colors.dart';
import '../../models/detection.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final List<Detection> detections;

  const ResultScreen({
    Key? key,
    required this.imageFile,
    required this.detections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final det      = detections.first;
    final name     = det.className;
    final headline = det.description.headline;
    final desc     = det.description.description;
    final star     = det.description.starSign;
    final chakras  = det.description.chakras;
    final conf     = (det.confidence * 100).toStringAsFixed(1) + '%';

    const imgH    = 380.0;
    const detailH = 464.0;
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
                            const Icon(
                              HugeIcons.strokeRoundedBookmark02,
                              size: 24,
                              color: Color(0xFF1A181B),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Image + details
                  SizedBox(
                    width: cardW,
                    height: imgH + detailH - overlap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // image
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

                        // detail card
                        Positioned(
                          top: imgH - overlap,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 128, sigmaY: 128),
                              child: Container(
                                width: cardW, height: detailH,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0x59FBF5F3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontFamily: 'PlayfairDisplay',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24,
                                      ),
                                    ),
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
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(HugeIcons.strokeRoundedConstellation, size: 20),
                                        const SizedBox(width: 4),
                                        Text(star),
                                        const SizedBox(width: 16),
                                        const Icon(HugeIcons.strokeRoundedSpirals, size: 20),
                                        const SizedBox(width: 4),
                                        Text(chakras),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          desc,
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // bottom nav
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: _BottomNavBar(selectedIndex: 2, onTap: (_) {}),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, int idx) {
      final active = idx == selectedIndex;
      return GestureDetector(
        onTap: () => onTap(idx),
        child: Container(
          width: 48, height: 48, padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary20.withOpacity(0.35)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: active
                  ? AppColors.primary20.withOpacity(0.35)
                  : AppColors.neutral.withOpacity(0.5),
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
              item(HugeIcons.strokeRoundedHome08,   0),
              item(HugeIcons.strokeRoundedIrisScan, 1),
              item(HugeIcons.strokeRoundedGem,      2),
            ],
          ),
        ),
      ),
    );
  }
}