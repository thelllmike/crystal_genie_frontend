import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_store_config.dart';
import '../../core/services/apple_subscription.dart';
import '../../core/services/subscription_service.dart';
import '../widgets/cg.dart';

/// Premium upsell shown when the free trial has run out, and reachable from
/// the profile screen while the trial is still running.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _busy = false;
  bool _restoring = false;

  /// On iPhone, Apple's price in the user's own currency.
  String? _applePrice;

  @override
  void initState() {
    super.initState();
    if (SubscriptionService.usesApplePurchase) {
      AppleSubscription.product().then((product) {
        if (mounted && product != null) {
          setState(() => _applePrice = '${product.price}/month');
        }
      }).catchError((_) {});
    }
  }

  static const _perks = [
    ('Unlimited crystal scans', HugeIcons.strokeRoundedCamera01),
    ('Instant identification with meanings', HugeIcons.strokeRoundedSparkles),
    ('Your full find history, saved forever', HugeIcons.strokeRoundedBookmark02),
  ];

  Future<void> _subscribe() async {
    setState(() => _busy = true);
    try {
      final subscribed = await SubscriptionService.subscribe();
      if (!mounted) return;
      if (subscribed) {
        CG.snack(context, 'You\'re all set — happy scanning!');
        Navigator.of(context).pop(true);
      } else {
        CG.snack(context, 'Payment canceled');
      }
    } catch (e) {
      if (!mounted) return;
      CG.snack(context, 'Could not subscribe: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    try {
      final restored = await SubscriptionService.restore();
      if (!mounted) return;
      CG.snack(context, restored
            ? 'Purchase restored — happy scanning!'
            : 'No subscription found for this Apple ID');
      if (restored) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      CG.snack(context, 'Could not restore: $e');
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);

  @override
  Widget build(BuildContext context) {
    final status = SubscriptionService.current;
    final price = _applePrice ?? status?.priceLabel ?? '\$3.69/month';
    final apple = SubscriptionService.usesApplePurchase;
    final trialing = status?.isTrialActive ?? false;
    final daysLeft = status?.trialDaysLeft ?? 0;
    final amount = price.split('/').first;
    final period = price.contains('/') ? 'per ${price.split('/').last}' : '';

    return CGPage(
      glowTop: -200,
      glowSize: 720,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  CGBack(
                    icon: HugeIcons.strokeRoundedCancel01,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                  const Spacer(),
                  CGChip('Premium', background: CG.tint(CG.mint, .14), foreground: CG.brand),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                children: [
                  const Center(child: GemCluster(color: Color(0xFFA98BFF), width: 88, height: 102)),
                  const SizedBox(height: 14),
                  Text(
                    trialing
                        ? 'Your free trial ends in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}'
                        : 'Your free trial has ended',
                    textAlign: TextAlign.center,
                    style: CG.display(32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trialing
                        ? 'Subscribe now and keep identifying crystals without interruption.'
                        : 'Subscribe to keep identifying crystals with your camera.',
                    textAlign: TextAlign.center,
                    style: CG.sub(14.5),
                  ),
                  const SizedBox(height: 18),
                  CGCard(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(amount, style: CG.display(34).copyWith(height: 1)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(period, style: CG.sub(14))),
                            Text('Cancel anytime', style: CG.mute(12)),
                          ],
                        ),
                        const CGLine(vertical: 14),
                        for (final (i, perk) in _perks.indexed) ...[
                          if (i > 0) const SizedBox(height: 12),
                          CGCheckBullet(perk.$1),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Browsing the crystal library and the shop stay free.',
                    textAlign: TextAlign.center,
                    style: CG.mute(12.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    apple
                        ? 'Crystal Genie Premium is a monthly '
                            'auto-renewing subscription at $price. '
                            'Payment is charged to your Apple ID at '
                            'confirmation of purchase. It renews '
                            'automatically unless canceled at least 24 '
                            'hours before the end of the current period. '
                            'Manage or cancel any time in your App Store '
                            'account settings.'
                        : 'Crystal Genie Premium is a monthly '
                            'subscription at $price that renews '
                            'automatically until you cancel it in your '
                            'profile.',
                    textAlign: TextAlign.center,
                    style: CG.mute(10.5).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      CGLink('Terms of Use', size: 12, onTap: () => _open(AppStoreConfig.termsOfUseUrl)),
                      CGLink('Privacy Policy', size: 12, onTap: () => _open(AppStoreConfig.privacyPolicyUrl)),
                      if (apple)
                        CGLink(
                          _restoring ? 'Restoring…' : 'Restore Purchases',
                          size: 12,
                          onTap: _restoring || _busy ? null : _restore,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: CGButton(
                label: 'Subscribe for $price',
                loading: _busy,
                onPressed: _subscribe,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
