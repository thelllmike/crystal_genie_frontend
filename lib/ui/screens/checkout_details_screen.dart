import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/constants/colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../../core/services/order_email_service.dart';
import '../../core/services/payment_service.dart';
import '../../models/cart_item.dart';
import '../widgets/glass.dart';

/// Shipping/contact details + order summary shown before payment.
///
/// On a successful payment it places the order and pops back to the cart with
/// the new order id; the cart shows the confirmation and clears itself.
class CheckoutDetailsScreen extends StatefulWidget {
  final List<CartItem> items;
  final double total;

  const CheckoutDetailsScreen({
    super.key,
    required this.items,
    required this.total,
  });

  @override
  State<CheckoutDetailsScreen> createState() => _CheckoutDetailsScreenState();
}

class _CheckoutDetailsScreenState extends State<CheckoutDetailsScreen> {
  // Prefill from a previously saved address; fall back to the display name.
  late final TextEditingController _name = TextEditingController(
      text: AuthService.shipName.isNotEmpty
          ? AuthService.shipName
          : AuthService.displayName);
  late final _phone = TextEditingController(text: AuthService.shipPhone);
  late final _address = TextEditingController(text: AuthService.shipAddress);
  late final _city = TextEditingController(text: AuthService.shipCity);
  late final _postal = TextEditingController(text: AuthService.shipPostal);

  bool _paying = false;
  bool _saveAddress = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _postal.dispose();
    super.dispose();
  }

  String? _missingField() {
    if (_name.text.trim().isEmpty) return 'name';
    if (_phone.text.trim().isEmpty) return 'phone number';
    if (_address.text.trim().isEmpty) return 'address';
    if (_city.text.trim().isEmpty) return 'city';
    if (_postal.text.trim().isEmpty) return 'postal code';
    return null;
  }

  Future<void> _pay() async {
    final missing = _missingField();
    if (missing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your $missing')),
      );
      return;
    }

    setState(() => _paying = true);
    try {
      // 1. Open the Stripe payment sheet.
      final paid = await PaymentService.payForCart();
      if (!paid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment canceled')),
          );
        }
        return;
      }

      // 2. Payment succeeded — create the order with the shipping details.
      final orderId = await DbService.placeOrder(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        postal: _postal.text.trim(),
      );

      // 3. Email the confirmation from the shop's admin mailbox. Best effort —
      // the order is already placed, so a mail failure must not fail checkout.
      unawaited(OrderEmailService.sendConfirmation(orderId));

      // 4. Optionally remember the address for next time (best effort).
      if (_saveAddress) {
        try {
          await AuthService.saveShippingAddress(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
            city: _city.text.trim(),
            postal: _postal.text.trim(),
          );
        } catch (_) {
          // Saving the address is non-critical; the order already went through.
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(orderId); // hand the id back to the cart
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
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
            child: const Center(child: BackgroundTitle(text: 'Checkout')),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.width * 0.15),
                  GlassIconButton(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 120),
                      children: [
                        _sectionLabel('Shipping details'),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: Column(
                            children: [
                              GlassTextField(
                                controller: _name,
                                hint: 'Full name',
                              ),
                              const SizedBox(height: 12),
                              GlassTextField(
                                controller: _phone,
                                hint: 'Phone number',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              GlassTextField(
                                controller: _address,
                                hint: 'Address',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GlassTextField(
                                      controller: _city,
                                      hint: 'City',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GlassTextField(
                                      controller: _postal,
                                      hint: 'Postal code',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    setState(() => _saveAddress = !_saveAddress),
                                child: Row(
                                  children: [
                                    Icon(
                                      _saveAddress
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      size: 20,
                                      color: AppColors.primary40,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Save this address for next time',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        color: Color(0xFF1A181B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _sectionLabel('Order summary'),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: Column(
                            children: [
                              for (final item in widget.items)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _summaryRow(
                                    '${item.product.name}  ×${item.quantity}',
                                    '\$${item.lineTotal.toStringAsFixed(2)}',
                                  ),
                                ),
                              const Divider(height: 16),
                              _summaryRow(
                                'Total',
                                '\$${widget.total.toStringAsFixed(2)}',
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pay button pinned to the bottom.
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: GradientButton(
              label: 'Pay \$${widget.total.toStringAsFixed(2)}',
              loading: _paying,
              onPressed: _pay,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Color(0xFF1A181B),
        ),
      );

  Widget _summaryRow(String label, String value, {bool bold = false}) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                fontSize: bold ? 16 : 14,
                color: const Color(0xFF1A181B),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: bold ? 16 : 14,
              color: bold ? AppColors.primary40 : const Color(0xFF1A181B),
            ),
          ),
        ],
      );
}
