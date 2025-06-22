// lib/src/ui/screens/take_photo_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';

/// Screen for capturing a crystal photo.
class TakePhotoScreen extends StatelessWidget {
  const TakePhotoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // calculate full‐width pill (screen minus 16px padding each side)
    final double screenW   = MediaQuery.of(context).size.width;
    final double pillWidth = screenW - 32;
    // preview frame is square
    final double frameSize = pillWidth;

    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(
        children: [
          // 1) Top pill with back arrow + instruction
          Positioned(
            top: 16,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  width: pillWidth,
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9), // #D9D9D9
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: const Color(0x80FBF5F3), // White-50
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
                        color: AppColors.neutral100,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Keep your crystal within the frame',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            height: 1.0,
                            letterSpacing: 0,
                            color: Color(0xFF1A181B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // balance the Row
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2) Preview frame with embedded placeholder image
          Positioned(
            top: 88, // 16 + 60 + 12 spacing
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: frameSize,
                height: frameSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0x80FBF5F3), // White-50
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/takephoto.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // 3) Bottom pill with controls
          Positioned(
            bottom: 16,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: pillWidth,
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x33FBF5F3), // White-20
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: const Color(0x80FBF5F3), // White-50
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedAlbum02,
                        size: 28,
                        color: AppColors.neutral100,
                      ),
                      Image.asset(
                        'assets/icons/takephotobutton.png',
                        width: 64,
                        height: 64,
                      ),
                      Icon(
                        HugeIcons.strokeRoundedExchange01,
                        size: 28,
                        color: AppColors.neutral100,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}