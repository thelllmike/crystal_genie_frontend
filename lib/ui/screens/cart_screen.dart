import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/services/db_service.dart';
import '../../models/cart_item.dart';
import '../widgets/cg.dart';
import '../widgets/page_transitions.dart';
import 'checkout_details_screen.dart';
import 'main_shell.dart';

/// Shopping cart with checkout (creates an order in Supabase).
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await DbService.fetchCart();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      CG.snack(context, 'Could not load cart: $e');
    }
  }

  double get _total => _items.fold(0, (sum, item) => sum + item.lineTotal);

  Future<void> _changeQuantity(CartItem item, int delta) async {
    final newQty = item.quantity + delta;
    // Optimistic update, rolled back on failure.
    setState(() {
      if (newQty <= 0) {
        _items.remove(item);
      } else {
        item.quantity = newQty;
      }
    });
    try {
      await DbService.setCartQuantity(item.id, newQty);
    } catch (e) {
      if (!mounted) return;
      CG.snack(context, 'Could not update cart: $e');
      _load();
    }
  }

  Future<void> _checkout() async {
    // Go to the shipping-details screen; it collects the address, runs the
    // Stripe payment, and returns the new order id on success.
    final orderId = await Navigator.of(context).push<int>(
      SmoothPageRoute(
        transition: SmoothTransition.slide,
        builder: (_) => CheckoutDetailsScreen(items: _items, total: _total),
      ),
    );
    if (orderId == null || !mounted) return;

    final ordered = List<CartItem>.of(_items);
    final total = _total;
    setState(() => _items = []);
    await Navigator.of(context).pushReplacement(
      SmoothPageRoute(
        builder: (_) => OrderConfirmedScreen(orderId: orderId, items: ordered, total: total),
      ),
    );
  }

  Future<void> _remove(CartItem item) => _changeQuantity(item, -item.quantity);

  @override
  Widget build(BuildContext context) {
    final count = _items.fold(0, (n, i) => n + i.quantity);
    return CGPage(
      glowTop: -340,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                children: [
                  const Align(alignment: Alignment.centerLeft, child: CGBack()),
                  const SizedBox(height: 16),
                  CGHeading(
                    title: 'Your cart',
                    subtitle: _loading ? ' ' : '$count ${count == 1 ? 'item' : 'items'}',
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Padding(padding: EdgeInsets.only(top: 60), child: CGLoading())
                  else if (_items.isEmpty)
                    CGEmpty(
                      title: 'Your cart is empty',
                      message: 'Add a crystal from the shop and it will appear here.',
                      action: 'Back to shop',
                      onAction: () => Navigator.of(context).maybePop(),
                    )
                  else
                    for (final item in _items) ...[
                      _CartRow(
                        item: item,
                        onChange: (d) => _changeQuantity(item, d),
                        onRemove: () => _remove(item),
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
            if (_items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Subtotal', style: CG.sub())),
                        Text('\$${_total.toStringAsFixed(2)}', style: CG.body(15, weight: FontWeight.w500)),
                      ],
                    ),
                    const CGLine(vertical: 14),
                    Row(
                      children: [
                        Expanded(child: Text('Total', style: CG.display(22))),
                        Text('\$${_total.toStringAsFixed(2)}', style: CG.display(26)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    CGButton(label: 'Checkout', onPressed: _checkout),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  final void Function(int delta) onChange;
  final VoidCallback onRemove;

  const _CartRow({required this.item, required this.onChange, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return CGCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrystalThumb(name: product.name, imageUrl: product.imageUrl, width: 72, height: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: CG.display(19).copyWith(height: 1.15)),
                    const SizedBox(height: 2),
                    Text('\$${product.price.toStringAsFixed(2)} each', style: CG.mute(13)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove ${product.name}',
                onPressed: onRemove,
                icon: const Icon(HugeIcons.strokeRoundedDelete02, size: 18, color: CG.tx3),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 86),
            child: Row(
              children: [
                CGStepper(
                  value: item.quantity,
                  onMinus: () => onChange(-1),
                  onPlus: () => onChange(1),
                ),
                Expanded(
                  child: Text(
                    '\$${item.lineTotal.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: CG.body(17, weight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen confirmation after a successful payment.
class OrderConfirmedScreen extends StatelessWidget {
  final int orderId;
  final List<CartItem> items;
  final double total;

  const OrderConfirmedScreen({
    super.key,
    required this.orderId,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return CGPage(
      glow: CG.mint,
      glowTop: -60,
      glowSize: 720,
      rings: true,
      ringsTop: 120,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 90),
                  children: [
                    Center(
                      child: Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: CG.brand,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: CG.mint.withValues(alpha: .14), spreadRadius: 12)],
                        ),
                        child: const Icon(HugeIcons.strokeRoundedTick02, color: CG.onBrand, size: 52),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Text('Payment received!', textAlign: TextAlign.center, style: CG.display(36)),
                    const SizedBox(height: 12),
                    Text(
                      "Order #$orderId is confirmed. We'll be in touch about delivery.",
                      textAlign: TextAlign.center,
                      style: CG.sub(),
                    ),
                    const SizedBox(height: 32),
                    CGCard(
                      child: Column(
                        children: [
                          for (final (i, it) in items.indexed) ...[
                            if (i > 0) const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(child: Text('${it.product.name} ×${it.quantity}', style: CG.sub(14))),
                                Text('\$${it.lineTotal.toStringAsFixed(2)}', style: CG.body(14)),
                              ],
                            ),
                          ],
                          const CGLine(vertical: 10),
                          Row(
                            children: [
                              Expanded(child: Text('Paid', style: CG.display(18))),
                              Text('\$${total.toStringAsFixed(2)}', style: CG.display(22)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CGButton(
                label: 'Done',
                onPressed: () => MainShell.goToTab(context, MainShell.homeTab),
              ),
              const SizedBox(height: 12),
              CGButton.ghost(label: 'Back to shop', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}
