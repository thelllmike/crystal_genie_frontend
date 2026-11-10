import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_router.dart';
import '../../core/constants/app_store_config.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../../core/services/subscription_service.dart';
import '../widgets/cg.dart';
import '../widgets/page_transitions.dart';
import 'paywall_screen.dart';

/// Profile screen with blurred background elements and action cards.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = AuthService.notificationsEnabled;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    // Pick up a renewal or lapse that happened since the app was opened.
    SubscriptionService.refresh();
    DbService.isAdmin().then((admin) {
      if (mounted && admin) setState(() => _isAdmin = true);
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    CG.snack(context, message);
  }

  Future<void> _editProfile() async {
    final name = TextEditingController(text: AuthService.displayName);
    final saved = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x6B14262A),
      builder: (ctx) => CGDialog(
        icon: HugeIcons.strokeRoundedPencilEdit01,
        title: 'Edit profile',
        body: CGField(label: 'Name', controller: name, small: true),
        actions: [
          CGButton(label: 'Save', onPressed: () => Navigator.of(ctx).pop(true)),
          CGButton.ghost(label: 'Cancel', onPressed: () => Navigator.of(ctx).pop(false)),
        ],
      ),
    );
    if (saved != true) return;
    final newName = name.text.trim();
    if (newName.isEmpty) return;
    try {
      await AuthService.updateDisplayName(newName);
      if (mounted) setState(() {});
      _snack('Profile updated');
    } catch (e) {
      _snack('Could not update profile: $e');
    }
  }

  Future<void> _changePassword() async {
    final password = TextEditingController();
    final confirm = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x6B14262A),
      builder: (ctx) => CGDialog(
        icon: HugeIcons.strokeRoundedSecurityValidation,
        title: 'Change password',
        body: Column(
          children: [
            CGField(
              label: 'New password',
              controller: password,
              hint: 'At least 6 characters',
              obscure: true,
              small: true,
            ),
            const SizedBox(height: 12),
            CGField(label: 'Confirm password', controller: confirm, obscure: true, small: true),
          ],
        ),
        actions: [
          CGButton(label: 'Save', onPressed: () => Navigator.of(ctx).pop(true)),
          CGButton.ghost(label: 'Cancel', onPressed: () => Navigator.of(ctx).pop(false)),
        ],
      ),
    );
    if (saved != true) return;
    if (password.text.length < 6) {
      _snack('Password must be at least 6 characters');
      return;
    }
    if (password.text != confirm.text) {
      _snack('Passwords do not match');
      return;
    }
    try {
      await AuthService.changePassword(password.text);
      _snack('Password changed');
    } catch (e) {
      _snack('Could not change password: $e');
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() => _notifications = enabled);
    try {
      await AuthService.setNotificationsEnabled(enabled);
    } catch (e) {
      if (mounted) setState(() => _notifications = !enabled);
      _snack('Could not save setting: $e');
    }
  }

  Future<void> _showLanguage() async {
    await showDialog<void>(
      context: context,
      barrierColor: const Color(0x6B14262A),
      builder: (ctx) => CGDialog(
        icon: HugeIcons.strokeRoundedLanguageSquare,
        title: 'Language',
        body: CGCard(
          padding: EdgeInsets.zero,
          child: CGListRow(
            icon: HugeIcons.strokeRoundedTick02,
            color: CG.brand,
            label: 'English',
            trailing: const SizedBox.shrink(),
            onTap: () => Navigator.of(ctx).pop(),
          ),
        ),
        actions: [
          CGButton.ghost(label: 'Close', onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showCGConfirm(
      context,
      title: 'Delete account?',
      message: 'This permanently deletes your account, finds, saved crystals, '
          'cart and orders. This cannot be undone.',
      confirmLabel: 'Delete account',
      destructive: true,
      icon: HugeIcons.strokeRoundedDelete02,
    );
    if (!confirmed || !mounted) return;
    try {
      await AuthService.deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.login, (_) => false);
    } catch (e) {
      _snack('Could not delete account: $e');
    }
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    SubscriptionService.clear(); // don't leak access to the next account
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.login, (_) => false);
  }

  Future<void> _openPaywall() async {
    await Navigator.of(context).push(SmoothPageRoute<bool>(builder: (_) => const PaywallScreen()));
    if (mounted) setState(() {});
  }

  Future<void> _cancelSubscription() async {
    final confirmed = await showCGConfirm(
      context,
      title: 'Cancel subscription?',
      message: "You'll keep scanning until the end of the period you've paid for.",
      confirmLabel: 'Cancel subscription',
      cancelLabel: 'Keep it',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await SubscriptionService.cancel();
      if (mounted) setState(() {});
      _snack('Subscription canceled');
    } catch (e) {
      _snack('Could not cancel: $e');
    }
  }

  /// Trial countdown / subscription state, with the matching action.
  Widget _subscriptionCard() {
    return ValueListenableBuilder<SubscriptionStatus?>(
      valueListenable: SubscriptionService.notifier,
      builder: (context, status, _) {
        if (status == null) return const SizedBox.shrink();

        final String title;
        final String subtitle;
        if (status.isSubscribed) {
          title = 'Premium';
          final end = status.currentPeriodEnd;
          final when = end == null ? '' : ' ${end.day}/${end.month}/${end.year}';
          subtitle = status.cancelAtPeriodEnd ? 'Ends$when' : 'Renews$when for ${status.priceLabel}';
        } else if (status.isTrialActive) {
          title = 'Free trial';
          final d = status.trialDaysLeft;
          subtitle = '$d ${d == 1 ? 'day' : 'days'} left · then ${status.priceLabel}';
        } else {
          title = 'Trial ended';
          subtitle = 'Subscribe for ${status.priceLabel} to keep scanning';
        }

        Widget? action;
        if (status.isApple && status.isSubscribed) {
          // Apple handles cancelling; the app can only send people there.
          action = CGLink('Manage',
              onTap: () => launchUrl(
                    Uri.parse(AppStoreConfig.manageSubscriptionsUrl),
                    mode: LaunchMode.externalApplication,
                  ));
        } else if (status.isSubscribed && !status.cancelAtPeriodEnd) {
          action = CGLink('Cancel', onTap: _cancelSubscription);
        } else if (!status.isSubscribed) {
          action = CGButton(label: 'Upgrade', small: true, expand: false, onPressed: _openPaywall);
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CGCard(
            gradient: CG.softGradient,
            borderColor: CG.line2,
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              children: [
                const Icon(HugeIcons.strokeRoundedSparkles, size: 22, color: CG.brand),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: CG.body(15, weight: FontWeight.w700, height: 1.3)),
                      Text(subtitle, style: CG.sub(12.5)),
                    ],
                  ),
                ),
                if (action != null) ...[const SizedBox(width: 8), action],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CGPage(
      glowTop: -340,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Row(
              children: [
                const CGBack(),
                const SizedBox(width: 12),
                Text('Profile', style: CG.display(28)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                CGAvatar(initials: AuthService.initials, size: 68),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AuthService.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CG.display(24).copyWith(height: 1.1)),
                      Text(AuthService.email,
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: CG.sub(13)),
                    ],
                  ),
                ),
                CGIconButton(
                  icon: HugeIcons.strokeRoundedPencilEdit01,
                  tooltip: 'Edit profile',
                  onTap: _editProfile,
                ),
              ],
            ),
            _subscriptionCard(),
            const SizedBox(height: 14),
            CGListCard(rows: [
              if (_isAdmin)
                CGListRow(
                  icon: HugeIcons.strokeRoundedDashboardSquare02,
                  label: 'Admin dashboard',
                  onTap: () => Navigator.of(context).pushNamed(AppRouter.admin),
                ),
              CGListRow(
                icon: HugeIcons.strokeRoundedBookmark02,
                label: 'Saved crystals',
                onTap: () => Navigator.of(context).pushNamed(AppRouter.savedCrystals),
              ),
              CGListRow(
                icon: HugeIcons.strokeRoundedShoppingBag02,
                label: 'Crystal shop',
                onTap: () => Navigator.of(context).pushNamed(AppRouter.shop),
              ),
            ]),
            const SizedBox(height: 14),
            CGListCard(rows: [
              CGListRow(
                icon: HugeIcons.strokeRoundedNotification01,
                label: 'Notifications',
                onTap: () => _toggleNotifications(!_notifications),
                trailing: Switch(
                  value: _notifications,
                  activeThumbColor: CG.onBrand,
                  activeTrackColor: CG.brand,
                  inactiveThumbColor: CG.onBrand,
                  inactiveTrackColor: CG.s3,
                  trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                  onChanged: _toggleNotifications,
                ),
              ),
              CGListRow(
                icon: HugeIcons.strokeRoundedSecurityValidation,
                label: 'Security',
                onTap: _changePassword,
              ),
              CGListRow(
                icon: HugeIcons.strokeRoundedLanguageSquare,
                label: 'Language',
                onTap: _showLanguage,
              ),
              CGListRow(
                icon: HugeIcons.strokeRoundedPolicy,
                label: 'Privacy policy',
                onTap: () => launchUrl(
                  Uri.parse(AppStoreConfig.privacyPolicyUrl),
                  mode: LaunchMode.inAppBrowserView,
                ),
              ),
            ]),
            const SizedBox(height: 14),
            CGListCard(rows: [
              CGListRow(
                icon: HugeIcons.strokeRoundedLogout03,
                label: 'Log out',
                chevron: false,
                onTap: _logout,
              ),
              CGListRow(
                icon: HugeIcons.strokeRoundedDelete02,
                label: 'Delete account',
                color: CG.danger,
                chevron: false,
                onTap: _confirmDeleteAccount,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
