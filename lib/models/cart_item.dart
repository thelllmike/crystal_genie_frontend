import 'product.dart';

/// A row from `cart_items` joined with its product.
class CartItem {
  final int id;
  final Product product;
  int quantity;

  CartItem({required this.id, required this.product, required this.quantity});

  double get lineTotal => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        id: (j['id'] as num).toInt(),
        quantity: (j['quantity'] as num).toInt(),
        product: Product.fromJson(j['products'] as Map<String, dynamic>),
      );
}
