/// A crystal from the Supabase `crystals` catalog (the library screen).
class Crystal {
  final String name;
  final String headline;
  final String description;
  final String starSign;
  final String chakras;

  /// Photo uploaded from the admin panel; null shows the placeholder.
  final String? imageUrl;

  Crystal({
    required this.name,
    required this.headline,
    required this.description,
    required this.starSign,
    required this.chakras,
    this.imageUrl,
  });

  factory Crystal.fromJson(Map<String, dynamic> j) => Crystal(
        name: j['name'] as String? ?? '',
        headline: j['headline'] as String? ?? '',
        description: j['description'] as String? ?? '',
        starSign: j['star_sign'] as String? ?? '',
        chakras: j['chakras'] as String? ?? '',
        imageUrl: (j['image_url'] as String?)?.trim().isEmpty ?? true
            ? null
            : j['image_url'] as String,
      );
}
