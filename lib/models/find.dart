/// A detection saved to the user's history (`finds`) or bookmarks
/// (`saved_crystals`).
class Find {
  final String crystalName;
  final String headline;
  final DateTime createdAt;

  Find({
    required this.crystalName,
    required this.headline,
    required this.createdAt,
  });

  factory Find.fromJson(Map<String, dynamic> j) => Find(
        crystalName: j['crystal_name'] as String? ?? '',
        headline: j['headline'] as String? ?? '',
        createdAt:
            DateTime.tryParse(j['created_at'] as String? ?? '')?.toLocal() ??
                DateTime.now(),
      );

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 30) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    final months = diff.inDays ~/ 30;
    return '$months month${months == 1 ? '' : 's'} ago';
  }
}
