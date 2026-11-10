import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../../core/services/order_email_service.dart';
import '../../core/services/payment_service.dart';
import '../../models/cart_item.dart';
import '../widgets/cg.dart';

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
      CG.snack(context, 'Please enter your $missing');
      return;
    }

    setState(() => _paying = true);
    try {
      // 1. Open the Stripe payment sheet.
      final paid = await PaymentService.payForCart();
      if (!paid) {
        if (mounted) {
          CG.snack(context, 'Payment canceled');
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
      CG.snack(context, 'Checkout failed: $e');
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CGPage(
      glowTop: -340,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AutofillGroup(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  children: [
                    Row(
                      children: [
                        CGBack(onTap: _paying ? null : () => Navigator.of(context).maybePop()),
                        const Spacer(),
                        const CGChip('Step 1 of 2 · Shipping'),
                        const Spacer(),
                        const SizedBox(width: 44),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('Checkout', style: CG.display(32)),
                    const SizedBox(height: 16),
                    CGField(
                      label: 'Full name',
                      controller: _name,
                      small: true,
                      action: TextInputAction.next,
                      autofill: const [AutofillHints.name],
                    ),
                    const SizedBox(height: 10),
                    CGField(
                      label: 'Phone number',
                      controller: _phone,
                      hint: '+94 77 123 4567',
                      small: true,
                      keyboardType: TextInputType.phone,
                      action: TextInputAction.next,
                      autofill: const [AutofillHints.telephoneNumber],
                    ),
                    const SizedBox(height: 10),
                    CGField(
                      label: 'Address',
                      controller: _address,
                      hint: 'Street and number',
                      small: true,
                      action: TextInputAction.next,
                      autofill: const [AutofillHints.streetAddressLine1],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CGField(
                            label: 'City',
                            controller: _city,
                            hint: 'City',
                            small: true,
                            action: TextInputAction.next,
                            autofill: const [AutofillHints.addressCity],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CGField(
                            label: 'Postal code',
                            controller: _postal,
                            hint: '00000',
                            small: true,
                            action: TextInputAction.done,
                            autofill: const [AutofillHints.postalCode],
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => setState(() => _saveAddress = !_saveAddress),
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 52),
                        child: Row(
                          children: [
                            CGCheck(value: _saveAddress),
                            const SizedBox(width: 12),
                            Text('Save this address for next time', style: CG.body(14.5)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    CGCard(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        children: [
                          for (final (i, item) in widget.items.indexed) ...[
                            if (i > 0) const SizedBox(height: 6),
                            _summaryRow('${item.product.name} ×${item.quantity}',
                                '\$${item.lineTotal.toStringAsFixed(2)}'),
                          ],
                          const CGLine(vertical: 10),
                          Row(
                            children: [
                              Expanded(child: Text('Total', style: CG.display(19))),
                              Text('\$${widget.total.toStringAsFixed(2)}', style: CG.display(22)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  CGButton(
                    label: 'Pay \$${widget.total.toStringAsFixed(2)}',
                    loading: _paying,
                    onPressed: _pay,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(HugeIcons.strokeRoundedSecurityLock, size: 14, color: CG.tx3),
                      const SizedBox(width: 6),
                      Text('Secure card payment by Stripe', style: CG.mute(12)),
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

  Widget _summaryRow(String label, String value) => Row(
        children: [
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: CG.sub(14)),
          ),
          Text(value, style: CG.body(14)),
        ],
      );
}
