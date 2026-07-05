/// A shop item from the Supabase `products` table.
class Product {
  final int id;
  final String name;
  final String headline;
  final double price;
  final String? imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.headline,
    required this.price,
    required this.imageUrl,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
        headline: j['headline'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        imageUrl: j['image_url'] as String?,
        stock: (j['stock'] as num?)?.toInt() ?? 0,
      );
}
