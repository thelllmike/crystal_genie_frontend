import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app_router.dart';
import '../../core/constants/colors.dart';
import '../../core/services/auth_service.dart';
import '../widgets/glass.dart';

/// Profile screen with blurred background elements and action cards.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = AuthService.notificationsEnabled;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editProfile() async {
    final name = TextEditingController(text: AuthService.displayName);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
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
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'New password (min. 6 characters)'),
            ),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
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
      builder: (ctx) => SimpleDialog(
        title: const Text('Language'),
        children: [
          ListTile(
            leading: const Icon(Icons.check, color: AppColors.primary),
            title: const Text('English'),
            onTap: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
            'This permanently deletes your account, finds, saved crystals, '
            'cart and orders. This cannot be undone.'),
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
    if (confirmed != true || !mounted) return;
    try {
      await AuthService.deleteAccount();
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRouter.login, (_) => false);
    } catch (e) {
      _snack('Could not delete account: $e');
    }
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(
        children: [
          // Background title (kept below the status bar)
          Positioned(
            top: topPad + 45,
            left: 0,
            right: 0,
            child: const Center(child: BackgroundTitle(text: 'Profile')),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 16),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(HugeIcons.strokeRoundedArrowLeft01, size: 20),
                              SizedBox(width: 4),
                              Text(
                                'Back',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Profile card
                        GlassCard(
                          width: double.infinity,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  AuthService.initials,
                                  style: const TextStyle(
                                    fontFamily: 'PlayfairDisplay',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 26,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AuthService.displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'PlayfairDisplay',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22,
                                        color: Color(0xFF1A181B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AuthService.email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13,
                                        color: Color(0xFF7A9596),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    OutlinedButton.icon(
                                      onPressed: _editProfile,
                                      icon: const Icon(
                                        HugeIcons.strokeRoundedPencilEdit01,
                                        size: 18,
                                        color: Color(0xFF34A0A4),
                                      ),
                                      label: const Text(
                                        'Edit profile',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Color(0xFF34A0A4),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        side: const BorderSide(
                                            color: Color(0xFF34A0A4), width: 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
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

                        // Logout button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(HugeIcons.strokeRoundedLogout03,
                                size: 24),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Settings list
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0x59FBF5F3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0x80FBF5F3), width: 1),
                              ),
                              child: Column(
                                children: [
                                  _buildOption(
                                    icon: HugeIcons.strokeRoundedBookmark02,
                                    label: 'Saved Crystals',
                                    onTap: () => Navigator.of(context)
                                        .pushNamed(AppRouter.savedCrystals),
                                  ),
                                  _divider(),
                                  _buildOption(
                                    icon: HugeIcons.strokeRoundedShoppingBag02,
                                    label: 'Crystal Shop',
                                    onTap: () => Navigator.of(context)
                                        .pushNamed(AppRouter.shop),
                                  ),
                                  _divider(),
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    leading: const Icon(
                                        HugeIcons.strokeRoundedNotification01,
                                        size: 24),
                                    title: const Text(
                                      'Notifications',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                    ),
                                    trailing: Switch(
                                      value: _notifications,
                                      activeThumbColor: AppColors.primary,
                                      onChanged: _toggleNotifications,
                                    ),
                                  ),
                                  _divider(),
                                  _buildOption(
                                    icon: HugeIcons
                                        .strokeRoundedSecurityValidation,
                                    label: 'Security',
                                    onTap: _changePassword,
                                  ),
                                  _divider(),
                                  _buildOption(
                                    icon:
                                        HugeIcons.strokeRoundedLanguageSquare,
                                    label: 'Language',
                                    onTap: _showLanguage,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Spacer(),

                        // Delete account button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _confirmDeleteAccount,
                            icon: const Icon(
                              HugeIcons.strokeRoundedDelete02,
                              size: 20,
                              color: Color(0xFF932115),
                            ),
                            label: const Text(
                              'Delete account',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Color(0xFF932115),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0x33932115),
                              side: const BorderSide(
                                  color: Color(0x59392115), width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, size: 24),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      trailing: const Icon(HugeIcons.strokeRoundedArrowRight01, size: 20),
    );
  }

  Divider _divider() {
    return const Divider(
      height: 1,
      color: Color(0xFFFBF5F3),
      indent: 16,
      endIndent: 16,
    );
  }
}
