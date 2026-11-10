import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Crystal Genie design system (redesign).
///
/// White ground, ink text, one deep teal brand colour, and a colour per
/// crystal that tints its gem art, tags and the soft glow behind a screen.
class CG {
  CG._();

  // Surfaces
  static const Color bg = Color(0xFFFFFFFF);
  static const Color s1 = Color(0xFFFFFFFF);
  static const Color s2 = Color(0xFFF3F7F7);
  static const Color s3 = Color(0xFFE5EDED);
  static const Color line = Color(0x14183C40); // rgba(24,60,64,.08)
  static const Color line2 = Color(0x2E183C40); // rgba(24,60,64,.18)

  // Text
  static const Color tx = Color(0xFF14262A);
  static const Color tx2 = Color(0xFF44595D);
  static const Color tx3 = Color(0xFF58696D);

  // Brand + semantic
  static const Color brand = Color(0xFF1D7F80);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFB3261E);
  static const Color ok = Color(0xFF1B7A45);
  static const Color warn = Color(0xFF8A5A00);
  static const Color info = Color(0xFF2457A6);
  static const Color off = Color(0xFF5A6A6E);

  // Default accent for screen glows.
  static const Color violet = Color(0xFF7C6CF0);
  static const Color mint = Color(0xFF5ED3CB);

  static const String serif = 'Fraunces';
  static const String sans = 'DMSans';

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF6F5FD), Color(0xFFEFF7F6)],
  );

  static const LinearGradient avatarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA98BFF), Color(0xFF5ED3CB)],
  );

  // ---------- Type ----------
  static TextStyle display(double size, {Color color = tx, FontStyle? style}) =>
      TextStyle(
        fontFamily: serif,
        fontWeight: FontWeight.w500,
        fontSize: size,
        height: 1.08,
        letterSpacing: -0.02 * size,
        color: color,
        fontStyle: style,
      );

  static TextStyle body(
    double size, {
    Color color = tx,
    FontWeight weight = FontWeight.w400,
    double height = 1.45,
    FontStyle? style,
  }) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
        fontStyle: style,
      );

  static TextStyle sub([double size = 15]) => body(size, color: tx2);
  static TextStyle mute([double size = 13]) => body(size, color: tx3);
  static TextStyle eyebrow({Color color = brand}) => TextStyle(
        fontFamily: sans,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: color,
      );

  // ---------- Crystal colours ----------
  static const Map<String, Color> _crystalColors = {
    'amethyst': Color(0xFFA98BFF),
    'rose quartz': Color(0xFFF4A9C4),
    'citrine': Color(0xFFF2BE4B),
    'black tourmaline': Color(0xFF8B94AD),
    'clear quartz': Color(0xFFBFE6EE),
    'labradorite': Color(0xFF5B9BB8),
    'tigers eye': Color(0xFFC98A3A),
    "tiger's eye": Color(0xFFC98A3A),
    'malachite': Color(0xFF3FA36B),
    'lapis lazuli': Color(0xFF3F63C9),
    'carnelian': Color(0xFFE5753F),
    'aventurine': Color(0xFF5DBB7E),
    'green aventurine': Color(0xFF5DBB7E),
    'jade': Color(0xFF4FB08A),
    'obsidian': Color(0xFF5B5F6E),
    'moonstone': Color(0xFFC9D4E8),
    'selenite': Color(0xFFDDE3EC),
    'fluorite': Color(0xFF8E7FD6),
    'turquoise': Color(0xFF3FB7B0),
    'smoky quartz': Color(0xFF9A8778),
    'pyrite': Color(0xFFC4A949),
    'sodalite': Color(0xFF4A62B5),
    'aquamarine': Color(0xFF7FCFDF),
    'garnet': Color(0xFFB8384B),
    'hematite': Color(0xFF6D7380),
    'howlite': Color(0xFFD5D8DC),
    'opal': Color(0xFFB7D9E8),
    'agate': Color(0xFFB98A78),
    'jasper': Color(0xFFB65F45),
    'red jasper': Color(0xFFB65F45),
    'onyx': Color(0xFF4B4F5A),
    'peridot': Color(0xFF9CC64B),
    'quartz': Color(0xFFBFE6EE),
  };

  static const List<Color> _fallback = [
    Color(0xFFA98BFF),
    Color(0xFFF4A9C4),
    Color(0xFFF2BE4B),
    Color(0xFF5B9BB8),
    Color(0xFF5ED3CB),
    Color(0xFF8B94AD),
    Color(0xFFE5753F),
    Color(0xFF5DBB7E),
  ];

  /// A stable colour for any crystal or product name.
  static Color crystalColor(String name) {
    final key = name.toLowerCase().trim();
    final exact = _crystalColors[key];
    if (exact != null) return exact;
    for (final e in _crystalColors.entries) {
      if (key.contains(e.key)) return e.value;
    }
    var h = 0;
    for (final c in key.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return _fallback[h % _fallback.length];
  }

  static Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;
  static Color shade(Color c, double amount) => mix(Colors.black, c, amount);
  static Color tint(Color c, double amount) => mix(Colors.white, c, amount);

  /// Splits "Crown, Third Eye and Heart" into ['Crown', 'Third Eye', 'Heart'].
  static List<String> splitList(String text) => text
      .split(RegExp(r'[,/;&]|\band\b'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty && e.toUpperCase() != 'N/A')
      .toList();

  // ---------- Snackbar ----------
  static void snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

// ======================================================================
// Backgrounds
// ======================================================================

/// White page with a soft, crystal-coloured glow at the top.
class CGPage extends StatelessWidget {
  final Widget child;
  final Color glow;
  final double glowTop;
  final double glowSize;
  final bool rings;
  final double ringsTop;
  final Widget? bottom;

  const CGPage({
    super.key,
    required this.child,
    this.glow = CG.violet,
    this.glowTop = -320,
    this.glowSize = 640,
    this.rings = false,
    this.ringsTop = 70,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CG.bg,
      body: Stack(
        children: [
          Positioned(
            top: glowTop,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                child: Container(
                  width: glowSize,
                  height: glowSize,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [glow.withValues(alpha: 0.13), glow.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (rings) ...[
            _ring(300, ringsTop),
            _ring(440, ringsTop - 70),
          ],
          Positioned.fill(child: child),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }

  Widget _ring(double size, double top) => Positioned(
        top: top,
        left: 0,
        right: 0,
        height: size,
        child: IgnorePointer(
          child: Center(
            child: OverflowBox(
              maxWidth: size,
              maxHeight: size,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CG.line),
                ),
              ),
            ),
          ),
        ),
      );
}

// ======================================================================
// Gem art
// ======================================================================

/// A single faceted crystal drawn in [color]. Width:height = 0.72.
class Gem extends StatelessWidget {
  final Color color;
  final double width;

  const Gem({super.key, required this.color, this.width = 48});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: width / 0.72,
        child: CustomPaint(painter: _GemPainter(color)),
      );
}

class _GemPainter extends CustomPainter {
  final Color c;
  _GemPainter(this.c);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    Offset p(double x, double y) => Offset(w * x, h * y);

    final body = Path()
      ..addPolygon([
        p(.5, 0),
        p(1, .2),
        p(1, .88),
        p(.72, 1),
        p(.28, 1),
        p(0, .88),
        p(0, .2),
      ], true);
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(Rect.fromLTWH(0, 0, w * .28, h), Paint()..color = CG.shade(c, .55));
    canvas.drawRect(Rect.fromLTWH(w * .28, 0, w * .44, h), Paint()..color = c);
    canvas.drawRect(Rect.fromLTWH(w * .72, 0, w * .28, h), Paint()..color = CG.shade(c, .78));
    canvas.restore();

    final top = Path()
      ..addPolygon([p(.5, 0), p(1, .2), p(.72, .32), p(.28, .32), p(0, .2)], true);
    canvas.save();
    canvas.clipPath(top);
    canvas.drawRect(Rect.fromLTWH(0, 0, w * .28, h), Paint()..color = CG.tint(c, .62));
    canvas.drawRect(Rect.fromLTWH(w * .28, 0, w * .44, h), Paint()..color = CG.tint(c, .38));
    canvas.drawRect(Rect.fromLTWH(w * .72, 0, w * .28, h), Paint()..color = CG.tint(c, .5));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GemPainter old) => old.c != c;
}

/// Three gems leaning together, the app's hero illustration.
class GemCluster extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const GemCluster({
    super.key,
    required this.color,
    this.width = 120,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    Widget gem(double w, double h, Color c) => SizedBox(
          width: w,
          height: h,
          child: CustomPaint(painter: _GemPainter(c)),
        );
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: width * .02,
            bottom: 0,
            child: Transform.rotate(
              angle: -15 * 3.14159 / 180,
              alignment: Alignment.bottomCenter,
              child: gem(width * .30, height * .68, CG.shade(color, .82)),
            ),
          ),
          Positioned(
            right: width * .02,
            bottom: 0,
            child: Transform.rotate(
              angle: 17 * 3.14159 / 180,
              alignment: Alignment.bottomCenter,
              child: gem(width * .30, height * .56, CG.tint(color, .9)),
            ),
          ),
          Positioned(
            left: width * .31,
            bottom: 0,
            child: gem(width * .38, height, color),
          ),
        ],
      ),
    );
  }
}

/// Rounded tile with a coloured glow behind a gem (or any [child]).
class GemTile extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final double radius;
  final Widget? child;
  final double? gemWidth;

  const GemTile({
    super.key,
    required this.color,
    this.width = 64,
    this.height = 64,
    this.radius = 18,
    this.child,
    this.gemWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CG.s2,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: CG.line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, .24),
                    radius: .55,
                    colors: [color.withValues(alpha: .34), color.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            child ?? Gem(color: color, width: gemWidth ?? width * .4),
          ],
        ),
      ),
    );
  }
}

/// Network photo if there is one, otherwise the gem tile.
class CrystalThumb extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double width;
  final double height;
  final double radius;
  final Widget? fallbackChild;

  const CrystalThumb({
    super.key,
    required this.name,
    this.imageUrl,
    this.width = 64,
    this.height = 64,
    this.radius = 18,
    this.fallbackChild,
  });

  @override
  Widget build(BuildContext context) {
    final tile = GemTile(
      color: CG.crystalColor(name),
      width: width,
      height: height,
      radius: radius,
      child: fallbackChild,
    );
    final url = imageUrl;
    if (url == null || url.isEmpty) return tile;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => tile,
      ),
    );
  }
}

// ======================================================================
// Buttons
// ======================================================================

enum CGButtonKind { primary, ghost, danger }

class CGButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CGButtonKind kind;
  final IconData? icon;
  final bool loading;
  final bool small;
  final bool expand;

  const CGButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = CGButtonKind.primary,
    this.icon,
    this.loading = false,
    this.small = false,
    this.expand = true,
  });

  const CGButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.small = false,
    this.expand = true,
  }) : kind = CGButtonKind.ghost;

  @override
  Widget build(BuildContext context) {
    final Color bg, fg;
    BorderSide side = BorderSide.none;
    switch (kind) {
      case CGButtonKind.primary:
        bg = CG.brand;
        fg = CG.onBrand;
      case CGButtonKind.ghost:
        bg = CG.s2;
        fg = CG.tx;
        side = const BorderSide(color: CG.line2);
      case CGButtonKind.danger:
        bg = CG.danger;
        fg = Colors.white;
    }
    final h = small ? 44.0 : 54.0;
    final content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CG.body(
                    small ? 14 : 16,
                    color: fg,
                    weight: kind == CGButtonKind.ghost ? FontWeight.w500 : FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          );
    final button = Material(
      color: onPressed == null && !loading ? bg.withValues(alpha: .5) : bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small ? 14 : 16),
        side: side,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: loading ? null : onPressed,
        child: SizedBox(
          height: h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: small ? 16 : 20),
            child: Center(widthFactor: 1, child: content),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// 44px round icon button on a pale surface.
class CGIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;
  final Color? background;
  final Color? foreground;
  final Color? borderColor;
  final int? badge;

  const CGIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 44,
    this.background,
    this.foreground,
    this.borderColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn = Material(
      color: background ?? CG.s2,
      shape: CircleBorder(side: BorderSide(color: borderColor ?? CG.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 22, color: foreground ?? CG.tx),
        ),
      ),
    );
    if (badge != null && badge! > 0) {
      btn = Stack(
        clipBehavior: Clip.none,
        children: [
          btn,
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: CG.brand,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '$badge',
                style: CG.body(11, color: CG.onBrand, weight: FontWeight.w700, height: 1),
              ),
            ),
          ),
        ],
      );
    }
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

/// Text link in brand colour.
class CGLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double size;

  const CGLink(this.label, {super.key, this.onTap, this.size = 14});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Text(
            label,
            style: CG.body(size, color: CG.brand, weight: FontWeight.w700, height: 1.2),
          ),
        ),
      );
}

// ======================================================================
// Surfaces
// ======================================================================

class CGCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Gradient? gradient;
  final Color? borderColor;

  const CGCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 22,
    this.gradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? CG.s1 : null,
        gradient: gradient,
        borderRadius: r,
        border: Border.all(color: borderColor ?? CG.line),
        boxShadow: const [
          BoxShadow(color: Color(0x0A183C40), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0D183C40), blurRadius: 28, offset: Offset(0, 10)),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Thin divider in the line colour.
class CGLine extends StatelessWidget {
  final double vertical;
  const CGLine({super.key, this.vertical = 0});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: vertical),
        child: Container(height: 1, color: CG.line),
      );
}

/// Grey pill chip; filled brand when [selected].
class CGChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? background;
  final Color? foreground;

  const CGChip(
    this.label, {
    super.key,
    this.selected = false,
    this.onTap,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? CG.brand : (background ?? CG.s2),
      shape: StadiumBorder(side: BorderSide(color: selected ? CG.brand : CG.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: CG.body(
              13,
              color: selected ? CG.onBrand : (foreground ?? CG.tx2),
              weight: selected ? FontWeight.w700 : FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Crystal-tinted tag with a coloured dot, e.g. a chakra.
class CGTag extends StatelessWidget {
  final String label;
  final Color color;
  final bool dot;

  const CGTag(this.label, {super.key, required this.color, this.dot = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: CG.tint(color, .16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: .4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: CG.body(12, color: CG.shade(color, .45), weight: FontWeight.w700, height: 1.2),
          ),
        ],
      ),
    );
  }
}

/// Status pill for orders / subscribers.
class CGStatus extends StatelessWidget {
  final String label;
  final Color color;

  const CGStatus(this.label, {super.key, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color),
        ),
        child: Text(label, style: CG.body(12, color: color, weight: FontWeight.w700, height: 1.1)),
      );
}

/// Two-option segmented control.
class CGSegmented extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const CGSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CG.s1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CG.line),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? CG.s3 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    options[i],
                    style: CG.body(
                      14,
                      color: i == selected ? CG.tx : CG.tx2,
                      weight: i == selected ? FontWeight.w700 : FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Rounded brand-filled check box.
class CGCheck extends StatelessWidget {
  final bool value;
  const CGCheck({super.key, required this.value});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value ? CG.brand : CG.s1,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: value ? CG.brand : CG.line2, width: 1.5),
        ),
        child: value ? const Icon(HugeIcons.strokeRoundedTick02, size: 18, color: CG.onBrand) : null,
      );
}

/// Brand check bullet used in feature lists.
class CGCheckBullet extends StatelessWidget {
  final String text;
  const CGCheckBullet(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const CGCheck(value: true),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: CG.body(14.5))),
        ],
      );
}

// ======================================================================
// Inputs
// ======================================================================

/// Labelled text field.
class CGField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType keyboardType;
  final bool small;
  final int maxLines;
  final String? helper;
  final TextInputAction? action;
  final Iterable<String>? autofill;
  final bool enabled;

  const CGField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.small = false,
    this.maxLines = 1,
    this.helper,
    this.action,
    this.autofill,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CG.body(12, color: CG.tx2, weight: FontWeight.w700, height: 1.2)
              .copyWith(letterSpacing: .36),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscure,
          keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
          maxLines: obscure ? 1 : maxLines,
          minLines: maxLines > 1 ? 4 : 1,
          textInputAction: action,
          autofillHints: autofill,
          style: CG.body(16, height: 1.3),
          cursorColor: CG.brand,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: CG.body(16, color: CG.tx3, height: 1.3),
            helperText: helper,
            helperMaxLines: 2,
            helperStyle: CG.mute(12),
            filled: true,
            fillColor: enabled ? CG.s1 : CG.s2,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: small ? 15 : 17,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: r,
              borderSide: const BorderSide(color: CG.line2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: r,
              borderSide: const BorderSide(color: CG.brand, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: r,
              borderSide: const BorderSide(color: CG.line),
            ),
            border: OutlineInputBorder(borderRadius: r),
          ),
        ),
      ],
    );
  }
}

/// Pill search box.
class CGSearch extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CGSearch({super.key, required this.hint, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: CG.s1,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: CG.line2),
      ),
      child: Row(
        children: [
          const Icon(HugeIcons.strokeRoundedSearch01, color: CG.tx3, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: CG.brand,
              style: CG.body(15, height: 1.2),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hint,
                hintStyle: CG.body(15, color: CG.tx3, height: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "—— or ——"
class CGDivider extends StatelessWidget {
  final String text;
  const CGDivider(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Expanded(child: CGLine()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(text, style: CG.mute(12)),
          ),
          const Expanded(child: CGLine()),
        ],
      );
}

/// Quantity stepper.
class CGStepper extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const CGStepper({
    super.key,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    Widget b(IconData i, VoidCallback f, String label) => Semantics(
          button: true,
          label: label,
          child: InkWell(
            onTap: f,
            customBorder: const CircleBorder(),
            child: SizedBox(width: 44, height: 44, child: Icon(i, size: 18, color: CG.tx)),
          ),
        );
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: CG.s2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CG.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          b(HugeIcons.strokeRoundedMinusSign, onMinus, 'Decrease'),
          SizedBox(
            width: 22,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: CG.body(15, weight: FontWeight.w700, height: 1.2)),
          ),
          b(HugeIcons.strokeRoundedPlusSign, onPlus, 'Increase'),
        ],
      ),
    );
  }
}

/// Settings-style row inside a [CGCard].
class CGListRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;
  final bool chevron;

  const CGListRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.color,
    this.chevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color ?? CG.tx2),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: CG.body(16, color: color ?? CG.tx))),
              if (trailing != null)
                trailing!
              else if (chevron && onTap != null)
                const Icon(HugeIcons.strokeRoundedArrowRight01, size: 20, color: CG.tx3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Column of [CGListRow]s separated by hairlines.
class CGListCard extends StatelessWidget {
  final List<Widget> rows;
  const CGListCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) => CGCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const CGLine(),
              rows[i],
            ],
          ],
        ),
      );
}

/// Initials avatar with the violet→mint gradient.
class CGAvatar extends StatelessWidget {
  final String initials;
  final double size;

  const CGAvatar({super.key, required this.initials, this.size = 48});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: CG.avatarGradient),
        child: Text(
          initials,
          style: CG.body(size * .32, color: const Color(0xFF0B0C11), weight: FontWeight.w700, height: 1),
        ),
      );
}

/// Centered loading spinner in brand colour.
class CGLoading extends StatelessWidget {
  const CGLoading({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: CG.brand, strokeWidth: 2.5),
      );
}

/// Dashed empty state with a grey gem.
class CGEmpty extends StatelessWidget {
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  const CGEmpty({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gem(color: Color(0xFFB9C3C5), width: 44),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: CG.display(22)),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(message, textAlign: TextAlign.center, style: CG.sub()),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              CGButton.ghost(label: action!, onPressed: onAction, small: true, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(26),
    ).deflate(.75);
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = CG.line2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ======================================================================
// Dialogs
// ======================================================================

/// Confirmation sheet in the redesign style. Returns true on confirm.
Future<bool> showCGConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x6B14262A),
    builder: (ctx) => CGDialog(
      icon: icon,
      destructive: destructive,
      title: title,
      body: Text(message, style: CG.sub(14.5).copyWith(height: 1.55)),
      actions: [
        CGButton.ghost(label: cancelLabel, onPressed: () => Navigator.of(ctx).pop(false)),
        CGButton(
          label: confirmLabel,
          kind: destructive ? CGButtonKind.danger : CGButtonKind.primary,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}

class CGDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final IconData? icon;
  final bool destructive;

  const CGDialog({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
    this.icon,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? CG.danger : CG.brand;
    return Dialog(
      backgroundColor: CG.s2,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: CG.line2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: CG.mix(CG.s2, accent, .18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent, size: 26),
                ),
                const SizedBox(height: 18),
              ],
              Text(title, style: CG.display(28)),
              const SizedBox(height: 10),
              body,
              const SizedBox(height: 22),
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                actions[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// Bottom navigation
// ======================================================================

/// Floating nav: Home · big Scan button · Library.
class CGNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CGNavBar({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget tab(IconData icon, String label, int idx) {
      final on = idx == selectedIndex;
      final c = on ? CG.brand : CG.tx3;
      return Semantics(
        button: true,
        selected: on,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(idx),
          child: SizedBox(
            width: 80,
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: c),
                const SizedBox(height: 2),
                Text(label, style: CG.body(11, color: c, weight: FontWeight.w700, height: 1.2)),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: CG.line2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    tab(HugeIcons.strokeRoundedHome08, 'Home', 0),
                    const SizedBox(width: 60),
                    tab(HugeIcons.strokeRoundedGem, 'Library', 2),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            child: Semantics(
              button: true,
              label: 'Scan a crystal',
              child: GestureDetector(
                onTap: () => onTap(1),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CG.brand,
                    shape: BoxShape.circle,
                    border: Border.all(color: CG.bg, width: 6),
                    boxShadow: const [
                      BoxShadow(color: Color(0x47187A7B), blurRadius: 24, offset: Offset(0, 10)),
                    ],
                  ),
                  child: const Icon(HugeIcons.strokeRoundedIrisScan, color: CG.onBrand, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// White fade behind the floating nav so list content slides under it.
class CGBottomFade extends StatelessWidget {
  final double height;
  const CGBottomFade({super.key, this.height = 150});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, .7],
              colors: [CG.bg.withValues(alpha: 0), CG.bg],
            ),
          ),
        ),
      );
}

/// Standard back button.
class CGBack extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  const CGBack({super.key, this.onTap, this.icon = HugeIcons.strokeRoundedArrowLeft01});

  @override
  Widget build(BuildContext context) => CGIconButton(
        icon: icon,
        tooltip: icon == HugeIcons.strokeRoundedCancel01 ? 'Close' : 'Back',
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
      );
}

/// Eyebrow + big serif title block.
class CGHeading extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final String? subtitle;
  final double size;

  const CGHeading({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(eyebrow!.toUpperCase(), style: CG.eyebrow()),
            const SizedBox(height: 8),
          ],
          Text(title, style: CG.display(size)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: CG.sub()),
          ],
        ],
      );
}

/// Two small facts side by side (star sign, chakras).
class CGFactGrid extends StatelessWidget {
  final String starSign;
  final String chakras;

  const CGFactGrid({super.key, required this.starSign, required this.chakras});

  @override
  Widget build(BuildContext context) {
    Widget fact(IconData icon, String label, String value) => Expanded(
          child: CGCard(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: CG.brand),
                    const SizedBox(width: 6),
                    Text(label.toUpperCase(), style: CG.eyebrow(color: CG.tx3).copyWith(fontSize: 10.5)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(value.isEmpty ? '—' : value, style: CG.body(14, weight: FontWeight.w700, height: 1.35)),
              ],
            ),
          ),
        );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          fact(HugeIcons.strokeRoundedConstellation, 'Star sign', starSign),
          const SizedBox(width: 12),
          fact(HugeIcons.strokeRoundedSpirals, 'Chakras', chakras),
        ],
      ),
    );
  }
}
