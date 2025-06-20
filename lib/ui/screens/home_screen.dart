// lib/src/ui/screens/home_screen.dart

import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  const HomeScreen({Key? key, this.userName = 'there'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(),
              const SizedBox(height: 16),
              Text(
                'Hi welcome,',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  fontSize: 60,
                  height: 1.0,      // 100% line-height
                  letterSpacing: 0, // 0% letter-spacing
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Recent Finds',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
            ),
            const SizedBox(width: 8),
            Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        IconButton(
          icon: const Icon(HugeIcons.strokeRoundedSettings03, size: 24),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.primary.withOpacity(0.2),
                const Color(0xFF50B2C8).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.35), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/item.png', // replace with crystal thumbnail
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildCardInfo()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aegirine',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('A stone of mental health and protection', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            // Bookmark button
            Container(
              width: 48,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.primary, Color(0xFF50B2C8)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(HugeIcons.strokeRoundedBookmark02, size: 20, color: Colors.white),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            // Learn More button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColors.primary, Color(0xFF50B2C8)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Learn more', style: TextStyle(color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(HugeIcons.strokeRoundedArrowRight01, size: 20, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Icon(HugeIcons.strokeRoundedHome08, size: 28, color: AppColors.primary),
          Icon(HugeIcons.strokeRoundedGem, size: 28, color: AppColors.primary),
          Icon(HugeIcons.strokeRoundedIrisScan, size: 28, color: AppColors.primary), // replace with your scan icon
        ],
      ),
    );
  }
}
