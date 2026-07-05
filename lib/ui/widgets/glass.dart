import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

/// Frosted-glass card used across the app (matches the Figma glass panels).
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0x59FBF5F3),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0x80FBF5F3), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Text input styled like the library search box.
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x80FBF5F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
            fontSize: 14,
            color: Color(0xFF5E5E5E),
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xFF1A181B),
        ),
      ),
    );
  }
}

/// Teal gradient button matching the "Learn more" style in FindCard.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF34A0A4), Color(0xFF50B2C8)],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF98CBCC), width: 1),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.accent40,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Frosted circular icon button used in screen top bars.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const GlassIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0x59FBF5F3),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x80FBF5F3), width: 1),
        ),
        child: Icon(icon, size: 22, color: AppColors.neutral100),
      ),
    );
  }
}

/// Large teal display title shown behind screen content, styled exactly
/// like the "Hi welcome," header on the home screen.
class BackgroundTitle extends StatelessWidget {
  final String text;

  const BackgroundTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.visible,
      softWrap: false,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        fontSize: (w * 0.08).clamp(24.0, 40.0),
        height: 1.0,
        color: const Color(0xFF50B2C8),
      ),
    );
  }
}
