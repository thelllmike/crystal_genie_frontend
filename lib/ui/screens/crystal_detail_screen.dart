import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/constants/colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../../models/crystal.dart';
import '../widgets/glass.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save crystals')),
      );
      return;
    }
    try {
      await DbService.saveCrystal(
        crystalName: _crystal?.name ?? widget.crystalName,
        headline: _crystal?.headline ?? '',
      );
      if (!mounted) return;
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_crystal?.name ?? widget.crystalName} saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _crystal?.name ?? widget.crystalName;
    final headline = _crystal?.headline ?? '';
    final desc = _crystal?.description ?? '';
    final star = _crystal?.starSign ?? '';
    final chakras = _crystal?.chakras ?? '';

    const imgH = 380.0;
    const overlap = 64.0;
    final cardW = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 45,
            left: 0,
            right: 0,
            child: const Center(child: BackgroundTitle(text: 'You\'ve got a')),
          ),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.width * 0.15),

                        // Name pill with back + bookmark
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(
                              width: cardW,
                              height: 60,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0x59FBF5F3),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                    color: const Color(0x80FBF5F3), width: 1),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const Icon(
                                        HugeIcons.strokeRoundedArrowLeft01,
                                        size: 22,
                                        color: Color(0xFF1A181B)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                    onTap: _save,
                                    child: Icon(
                                      _saved
                                          ? HugeIcons
                                              .strokeRoundedBookmarkCheck02
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

                        // Image (placeholder — crystals have no stored photo)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: cardW,
                            height: imgH,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0x80FFFFFF), width: 2),
                            ),
                            child: Image.asset('assets/images/item.png',
                                fit: BoxFit.cover),
                          ),
                        ),

                        // Detail card overlapping the image
                        Transform.translate(
                          offset: const Offset(0, -overlap),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 128, sigmaY: 128),
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
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontFamily: 'PlayfairDisplay',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24,
                                        color: Color(0xFF1A181B),
                                      ),
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
                                          color: Color(0xFF5E5E5E),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                            HugeIcons.strokeRoundedConstellation,
                                            size: 20,
                                            color: Color(0xFF1A181B)),
                                        const SizedBox(width: 4),
                                        Text(
                                          star.isNotEmpty ? star : 'N/A',
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 13,
                                            color: Color(0xFF1A181B),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(
                                            HugeIcons.strokeRoundedSpirals,
                                            size: 20,
                                            color: Color(0xFF1A181B)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            chakras.isNotEmpty ? chakras : 'N/A',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13,
                                              color: Color(0xFF1A181B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      desc.isNotEmpty
                                          ? desc
                                          : 'No description available for this crystal yet.',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        height: 1.5,
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

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
