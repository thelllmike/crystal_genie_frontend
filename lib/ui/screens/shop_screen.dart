import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_router.dart';
import '../../core/constants/colors.dart';
import '../../core/services/db_service.dart';
import '../../models/product.dart';
import '../widgets/glass.dart';

/// Crystal shop — products come from the Supabase `products` table.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Future<List<Product>> _products;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _products = DbService.fetchProducts();
    DbService.isAdmin().then((admin) {
      if (mounted && admin) setState(() => _isAdmin = true);
    });
  }

  void _reload() {
    setState(() => _products = DbService.fetchProducts());
  }

  Future<void> _addToCart(Product product) async {
    try {
      await DbService.addToCart(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add to cart: $e')),
      );
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${product.name}?'),
        content: const Text(
            'This removes the product from the shop and from all carts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFF932115))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await DbService.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} deleted')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e')),
      );
    }
  }

  Future<void> _showAddProductDialog() async {
    final name = TextEditingController();
    final headline = TextEditingController();
    final price = TextEditingController();
    final stock = TextEditingController(text: '10');
    final imageUrl = TextEditingController();

    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: headline,
                decoration:
                    const InputDecoration(labelText: 'Headline (optional)'),
              ),
              TextField(
                controller: price,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price (\$)'),
              ),
              TextField(
                controller: stock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
              ),
              TextField(
                controller: imageUrl,
                decoration:
                    const InputDecoration(labelText: 'Image URL (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final p = double.tryParse(price.text.trim());
              if (name.text.trim().isEmpty || p == null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text('Name and a valid price are required')),
                );
                return;
              }
              try {
                await DbService.addProduct(
                  name: name.text.trim(),
                  headline: headline.text.trim(),
                  price: p,
                  stock: int.tryParse(stock.text.trim()) ?? 0,
                  imageUrl: imageUrl.text.trim(),
                );
                if (ctx.mounted) Navigator.of(ctx).pop(true);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Could not add: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (added == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 45,
            left: 0,
            right: 0,
            child: const Center(child: BackgroundTitle(text: 'Crystal shop')),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.width * 0.15),
                  // Back + cart row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassIconButton(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Row(
                        children: [
                          if (_isAdmin) ...[
                            GlassIconButton(
                              icon: HugeIcons.strokeRoundedPlusSignCircle,
                              onTap: _showAddProductDialog,
                            ),
                            const SizedBox(width: 8),
                          ],
                          GlassIconButton(
                            icon: HugeIcons.strokeRoundedShoppingCart01,
                            onTap: () =>
                                Navigator.of(context).pushNamed(AppRouter.cart),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: FutureBuilder<List<Product>>(
                      future: _products,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snap.hasError) {
                          return Center(
                            child: Text(
                              'Could not load the shop:\n${snap.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontFamily: 'Montserrat'),
                            ),
                          );
                        }
                        final products = snap.data ?? [];
                        if (products.isEmpty) {
                          return const Center(
                            child: Text(
                              'No products yet — check back soon!',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: products.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, i) => _ProductCard(
                            product: products[i],
                            onAdd: () => _addToCart(products[i]),
                            onDelete: _isAdmin
                                ? () => _deleteProduct(products[i])
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  final VoidCallback? onDelete;

  const _ProductCard({required this.product, required this.onAdd, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final soldOut = product.stock <= 0;

    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFBF5F3), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/item.png',
                        fit: BoxFit.cover),
                  )
                : Image.asset('assets/images/item.png', fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            height: 1.1,
                            color: Color(0xFF1A181B),
                          ),
                        ),
                      ),
                      if (onDelete != null)
                        GestureDetector(
                          onTap: onDelete,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              HugeIcons.strokeRoundedDelete02,
                              size: 20,
                              color: Color(0xFF932115),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (product.headline.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Color(0xFF5E5E5E),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.primary40,
                          ),
                        ),
                      ),
                      soldOut
                          ? const Text(
                              'Sold out',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 13,
                                color: Color(0xFF932115),
                              ),
                            )
                          : GradientButton(
                              label: 'Add to cart',
                              height: 34,
                              onPressed: onAdd,
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
