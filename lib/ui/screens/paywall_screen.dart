import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/constants/colors.dart';
import '../../core/services/subscription_service.dart';
import '../widgets/glass.dart';

/// Premium upsell shown when the free trial has run out, and reachable from
/// the profile screen while the trial is still running.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _busy = false;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You\'re all set — happy scanning!')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment canceled')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not subscribe: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = SubscriptionService.current;
    final price = status?.priceLabel ?? '\$3.69/month';
    final trialing = status?.isTrialActive ?? false;
    final daysLeft = status?.trialDaysLeft ?? 0;

    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 45,
            left: 0,
            right: 0,
            child: const Center(child: BackgroundTitle(text: 'Premium')),
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
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 120),
                      children: [
                        Text(
                          trialing
                              ? 'Your free trial ends in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}'
                              : 'Your free trial has ended',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            height: 1.3,
                            color: Color(0xFF1A181B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trialing
                              ? 'Subscribe now and keep identifying crystals without interruption.'
                              : 'Subscribe to keep identifying crystals with your camera.',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF5E5E5E),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    price.split('/').first,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 34,
                                      color: AppColors.primary40,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    price.contains('/')
                                        ? 'per ${price.split('/').last}'
                                        : '',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      color: Color(0xFF5E5E5E),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Cancel anytime.',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  color: Color(0xFF5E5E5E),
                                ),
                              ),
                              const Divider(height: 28),
                              for (final (label, icon) in _perks)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Row(
                                    children: [
                                      Icon(icon,
                                          size: 20, color: AppColors.primary40),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                            color: Color(0xFF1A181B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Browsing the crystal library and the shop stay free.',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: Color(0xFF5E5E5E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: GradientButton(
              label: 'Subscribe for $price',
              loading: _busy,
              onPressed: _subscribe,
            ),
          ),
        ],
      ),
    );
  }
}
