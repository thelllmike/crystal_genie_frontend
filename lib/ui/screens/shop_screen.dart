import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_router.dart';
import '../../core/services/db_service.dart';
import '../../models/product.dart';
import '../widgets/cg.dart';

/// Crystal shop — products come from the Supabase `products` table.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Future<List<Product>> _products;
  bool _isAdmin = false;
  int _cartCount = 0;
  double _cartTotal = 0;

  @override
  void initState() {
    super.initState();
    _products = DbService.fetchProducts();
    _loadCart();
    DbService.isAdmin().then((admin) {
      if (mounted && admin) setState(() => _isAdmin = true);
    });
  }

  void _reload() {
    setState(() { _products = DbService.fetchProducts(); });
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final items = await DbService.fetchCart();
      if (!mounted) return;
      setState(() {
        _cartCount = items.fold(0, (n, i) => n + i.quantity);
        _cartTotal = items.fold(0.0, (t, i) => t + i.lineTotal);
      });
    } catch (_) {}
  }

  Future<void> _openCart() async {
    await Navigator.of(context).pushNamed(AppRouter.cart);
    if (mounted) _loadCart();
  }

  Future<void> _addToCart(Product product) async {
    try {
      await DbService.addToCart(product.id);
      if (!mounted) return;
      _loadCart();
      CG.snack(context, '${product.name} added to cart');
    } catch (e) {
      if (!mounted) return;
      CG.snack(context, 'Could not add to cart: $e');
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showCGConfirm(
      context,
      title: 'Delete ${product.name}?',
      message: 'This removes the product from the shop and from all carts.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: HugeIcons.strokeRoundedDelete02,
    );
    if (confirmed != true) return;
    try {
      await DbService.deleteProduct(product.id);
      if (!mounted) return;
      CG.snack(context, '${product.name} deleted');
      _reload();
    } catch (e) {
      if (!mounted) return;
      CG.snack(context, 'Could not delete: $e');
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
      barrierColor: const Color(0x6B14262A),
      builder: (ctx) => CGDialog(
        title: 'Add product',
        body: Column(
          children: [
            CGField(label: 'Name', controller: name, small: true),
            const SizedBox(height: 12),
            CGField(label: 'Headline (optional)', controller: headline, small: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CGField(
                    label: 'Price (\$)',
                    controller: price,
                    small: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CGField(
                    label: 'Stock',
                    controller: stock,
                    small: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CGField(label: 'Image URL (optional)', controller: imageUrl, small: true),
          ],
        ),
        actions: [
          CGButton(
            label: 'Add product',
            onPressed: () async {
              final p = double.tryParse(price.text.trim());
              if (name.text.trim().isEmpty || p == null) {
                CG.snack(ctx, 'Name and a valid price are required');
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
                if (ctx.mounted) CG.snack(ctx, 'Could not add: $e');
              }
            },
          ),
          CGButton.ghost(label: 'Cancel', onPressed: () => Navigator.of(ctx).pop(false)),
        ],
      ),
    );
    if (added == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return CGPage(
      glowTop: -340,
      bottom: _cartCount > 0
          ? Positioned(
              left: 20,
              right: 20,
              bottom: 0,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: CG.brand,
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _openCart,
                    child: SizedBox(
                      height: 64,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$_cartCount ${_cartCount == 1 ? 'item' : 'items'} · \$${_cartTotal.toStringAsFixed(2)}',
                                style: CG.body(16, color: CG.onBrand, weight: FontWeight.w700),
                              ),
                            ),
                            Text('View cart', style: CG.body(16, color: CG.onBrand, weight: FontWeight.w700)),
                            const SizedBox(width: 6),
                            const Icon(HugeIcons.strokeRoundedArrowRight01, color: CG.onBrand, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      child: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Product>>(
          future: _products,
          builder: (context, snap) {
            final header = <Widget>[
              Row(
                children: [
                  const CGBack(),
                  const Spacer(),
                  if (_isAdmin) ...[
                    CGIconButton(
                      icon: HugeIcons.strokeRoundedPlusSignCircle,
                      tooltip: 'Add product',
                      onTap: _showAddProductDialog,
                    ),
                    const SizedBox(width: 10),
                  ],
                  CGIconButton(
                    icon: HugeIcons.strokeRoundedShoppingCart01,
                    tooltip: 'Cart',
                    badge: _cartCount,
                    onTap: _openCart,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const CGHeading(eyebrow: 'Hand-picked', title: 'Crystal shop'),
              const SizedBox(height: 22),
            ];
            Widget body;
            if (snap.connectionState != ConnectionState.done) {
              body = const Padding(padding: EdgeInsets.only(top: 60), child: CGLoading());
            } else if (snap.hasError) {
              body = CGEmpty(
                title: 'Could not load the shop',
                message: '${snap.error}',
                action: 'Try again',
                onAction: _reload,
              );
            } else if ((snap.data ?? []).isEmpty) {
              body = const CGEmpty(
                title: 'No products yet',
                message: 'Check back soon for hand-picked crystals.',
              );
            } else {
              final products = snap.data!;
              body = Column(
                children: [
                  for (final p in products) ...[
                    _ProductCard(
                      product: p,
                      onAdd: () => _addToCart(p),
                      onDelete: _isAdmin ? () => _deleteProduct(p) : null,
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              );
            }
            return RefreshIndicator(
              color: CG.brand,
              onRefresh: () async => _reload(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                children: [...header, body],
              ),
            );
          },
        ),
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
    final color = CG.crystalColor(product.name);
    return CGCard(
      padding: const EdgeInsets.all(12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Opacity(
              opacity: soldOut ? .55 : 1,
              child: CrystalThumb(
                name: product.name,
                imageUrl: product.imageUrl,
                width: 112,
                height: 128,
                fallbackChild: GemCluster(color: color, width: 76, height: 88),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: CG.display(20, color: soldOut ? CG.tx2 : CG.tx).copyWith(height: 1.15),
                        ),
                      ),
                      if (onDelete != null)
                        InkWell(
                          onTap: onDelete,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(HugeIcons.strokeRoundedDelete02, size: 18, color: CG.danger),
                          ),
                        ),
                    ],
                  ),
                  if (product.headline.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(product.headline, maxLines: 2, overflow: TextOverflow.ellipsis, style: CG.sub(13)),
                  ],
                  const SizedBox(height: 12),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: CG.body(17, weight: FontWeight.w700, color: soldOut ? CG.tx3 : CG.tx),
                        ),
                      ),
                      if (soldOut)
                        const CGStatus('Sold out', color: CG.off)
                      else
                        CGButton(label: 'Add', small: true, expand: false, onPressed: onAdd),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
