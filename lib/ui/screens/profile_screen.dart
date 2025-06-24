import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';

/// Profile screen with blurred background elements and action cards.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth - 32; // 16px padding each side

    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(
        children: [
          // Background title
          Positioned(
            top: 20,
            left: 16,
            child: Text(
              'Profile',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontSize: 52,
                height: 1.0,
                letterSpacing: 0,
                color: Color(0xFF34A0A4),
              ).copyWith(color: const Color(0xFF34A0A4).withOpacity(0.3)),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          children: const [
                            Icon(HugeIcons.strokeRoundedArrowLeft01, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Profile card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        width: cardWidth,
                        height: 192,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0x59FBF5F3), // White-35
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x80FBF5F3), width: 1),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 48,
                              backgroundImage: AssetImage('assets/images/profile.png'),
                            ),
                            const SizedBox(width: 16),
                            // Name & email + edit button
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Jon Doe',
                                    style: const TextStyle(
                                      fontFamily: 'PlayfairDisplay',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                      height: 1.0,
                                      color: Color(0xFF1A181B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'jon.doe@email.com',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Color(0xFF95B0B1),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      HugeIcons.strokeRoundedPencilEdit01,
                                      size: 20,
                                      color: Color(0xFF34A0A4),
                                    ),
                                    label: const Text(
                                      'Edit profile',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        height: 1.0,
                                        color: Color(0xFF34A0A4),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(144, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      side: const BorderSide(color: Color(0xFF34A0A4), width: 1),
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
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout button
                  SizedBox(
                    width: cardWidth,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        HugeIcons.strokeRoundedLogout03,
                        size: 24,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        width: cardWidth,
                        decoration: BoxDecoration(
                          color: const Color(0x59FBF5F3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x80FBF5F3), width: 1),
                        ),
                        child: Column(
                          children: [
                            _buildOption(
                              icon: HugeIcons.strokeRoundedBookmark02,
                              label: 'Saved Crystals',
                              onTap: () {},
                            ),
                            _divider(),
                            _buildOption(
                              icon: HugeIcons.strokeRoundedNotification01,
                              label: 'Notifications',
                              onTap: () {},
                            ),
                            _divider(),
                            _buildOption(
                              icon: HugeIcons.strokeRoundedSecurityValidation,
                              label: 'Security',
                              onTap: () {},
                            ),
                            _divider(),
                            _buildOption(
                              icon: HugeIcons.strokeRoundedLanguageSquare,
                              label: 'Language',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Delete account button
                  SizedBox(
                    width: cardWidth,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {},
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
                          height: 1.0,
                          color: Color(0xFF932115),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0x33932115),
                        side: const BorderSide(color: Color(0x59392115), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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