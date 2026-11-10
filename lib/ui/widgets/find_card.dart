import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'cg.dart';

/// A crystal row card: gem tile, name, headline and an optional time.
/// Used for "Recent finds" on Home and the Saved crystals list.
class FindCard extends StatelessWidget {
  final String name;
  final String headline;
  final String? timeAgo;
  final VoidCallback? onTap;

  /// Replaces the chevron, e.g. a bookmark button.
  final Widget? trailing;

  const FindCard({
    super.key,
    required this.name,
    required this.headline,
    this.timeAgo,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return CGCard(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(12, 12, trailing == null ? 16 : 12, 12),
      child: Row(
        children: [
          GemTile(color: CG.crystalColor(name), width: 64, height: 64, gemWidth: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CG.display(20).copyWith(height: 1.15),
                ),
                if (headline.isNotEmpty)
                  Text(
                    headline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CG.sub(13),
                  ),
                if (timeAgo != null) ...[
                  const SizedBox(height: 2),
                  Text(timeAgo!, style: CG.mute(12)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              const Icon(HugeIcons.strokeRoundedArrowRight01, size: 22, color: CG.tx3),
        ],
      ),
    );
  }
}
