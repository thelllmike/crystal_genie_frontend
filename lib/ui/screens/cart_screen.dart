import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/constants/colors.dart';
import '../../core/services/db_service.dart';
import '../../models/cart_item.dart';
import '../widgets/glass.dart';

/// Shopping cart with checkout (creates an order in Supabase).
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _items = [];
  bool _loading = true;
  bool _checkingOut = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load cart: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update cart: $e')),
      );
      _load();
    }
  }

  Future<void> _checkout() async {
    setState(() => _checkingOut = true);
    try {
      final orderId = await DbService.placeOrder();
      if (!mounted) return;
      setState(() => _items = []);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Order placed!'),
          content: Text(
              'Order #$orderId has been created. We\'ll be in touch about payment and delivery.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: const Center(child: BackgroundTitle(text: 'Your cart')),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.width * 0.06),
                  GlassIconButton(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _items.isEmpty
                            ? const Center(
                                child: Text(
                                  'Your cart is empty',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 140),
                                itemCount: _items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, i) => _CartRow(
                                  item: _items[i],
                                  onChange: (d) =>
                                      _changeQuantity(_items[i], d),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),

          // Total + checkout
          if (!_loading && _items.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: GlassCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                              color: Color(0xFF5E5E5E),
                            ),
                          ),
                          Text(
                            '\$${_total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              color: AppColors.primary40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: GradientButton(
                        label: 'Checkout',
                        loading: _checkingOut,
                        onPressed: _checkout,
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

class _CartRow extends StatelessWidget {
  final CartItem item;
  final void Function(int delta) onChange;

  const _CartRow({required this.item, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    Widget qtyButton(IconData icon, int delta) => GestureDetector(
          onTap: () => onChange(delta),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0x3434A0A4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0x5934A0A4), width: 1),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF34A0A4)),
          ),
        );

    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF1A181B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.primary40,
                  ),
                ),
              ],
            ),
          ),
          qtyButton(Icons.remove, -1),
          SizedBox(
            width: 36,
            child: Center(
              child: Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          qtyButton(Icons.add, 1),
        ],
      ),
    );
  }
}
