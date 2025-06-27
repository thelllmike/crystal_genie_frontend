import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';

/// A reusable card for showing a crystal “find” in lists.
class FindCard extends StatelessWidget {
  final double width;
  final String imagePath;
  final String title;
  final String subtitle;
  final String timeAgo;

  const FindCard({
    Key? key,
    required this.width,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: width,
          height: 140,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0x80FBF5F3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x80FBF5F3), width: 1),
          ),
          child: Row(
            children: [
              // fixed-size image
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // flexible content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title / subtitle / time grouped and allowed to size to its content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                              color: Color(0xFF1A181B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: 8,
                              color: Color(0xFF1A181B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Color(0xFF5E5E5E),
                            ),
                          ),
                        ],
                      ),

                      // Push buttons row to bottom
                      const Spacer(),

                      // Buttons row
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 36,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0x3434A0A4), Color(0x3450B2C8)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0x5934A0A4), width: 1),
                            ),
                            child: const Icon(
                              HugeIcons.strokeRoundedBookmark02,
                              color: Color(0xFF34A0A4),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF34A0A4), Color(0xFF50B2C8)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF98CBCC), width: 1),
                              ),
                              child: const Center(
                                child: Text(
                                  'Learn more',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: AppColors.accent40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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