// Shared UI components for AgriGate — reusable primitives that all features use.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../tokens/agri_colors.dart';
import '../tokens/agri_typography.dart';

// ─── AgriAppBar ───────────────────────────────────────────────────────────────

class AgriAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AgriAppBar({
    super.key,
    this.backLabel,
    this.onBack,
    this.dark = false,
    this.statusBadge,
    this.actions,
  });

  final String? backLabel;
  final VoidCallback? onBack;
  final bool dark;
  final Widget? statusBadge;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final tone = dark ? const Color(0xFFF0EDE1) : AgriColors.ink;
    final bgColor = dark ? AgriColors.forest : AgriColors.background;

    return Material(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                if (onBack != null)
                  _BackButton(
                      label: backLabel, onBack: onBack!, dark: dark, tone: tone)
                else
                  _AgriLogo(tone: tone, dark: dark),
                const Spacer(),
                if (onBack == null) statusBadge ?? _LiveBadge(dark: dark),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.label,
    required this.onBack,
    required this.dark,
    required this.tone,
  });

  final String? label;
  final VoidCallback onBack;
  final bool dark;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        height: 48,
        padding: const EdgeInsets.only(left: 14, right: 18),
        decoration: BoxDecoration(
          color: dark ? const Color(0x14F0EDE1) : AgriColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: dark ? const Color(0x24F0EDE1) : AgriColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_left_rounded, size: 20, color: tone),
            SizedBox(width: 4.w),
            Text(
              label ?? 'Kembali',
              style:
                  AgriTypography.textTheme.titleMedium!.copyWith(color: tone),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgriLogo extends StatelessWidget {
  const _AgriLogo({required this.tone, required this.dark});

  final Color tone;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AgriColors.lime,
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.eco_rounded, size: 18, color: AgriColors.forest),
        ),
        SizedBox(width: 10.w),
        Text(
          'AgriGate',
          style: AgriTypography.textTheme.headlineMedium!.copyWith(color: tone),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? const Color(0x2EC8F04D) : AgriColors.card,
        borderRadius: BorderRadius.circular(20),
        border: dark ? null : Border.all(color: AgriColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AgriColors.lime,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'LIVE',
            style: AgriTypography.liveIndicator.copyWith(
              color: dark ? AgriColors.lime : AgriColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SectionLabel ─────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AgriTypography.sectionLabel);
  }
}

// ─── StatusBadge ──────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cfg = _statusConfig(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: cfg.dot,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AgriTypography.badgeText.copyWith(color: cfg.text),
          ),
        ],
      ),
    );
  }

  _StatusCfg _statusConfig(String label) {
    switch (label) {
      case 'Aktif':
        return const _StatusCfg(
          bg: AgriColors.statusAktifBg,
          text: AgriColors.statusAktifText,
          dot: Color(0xFF3A5E15),
        );
      case 'Perencanaan':
        return const _StatusCfg(
          bg: AgriColors.statusPerencanaanBg,
          text: AgriColors.statusPerencanaanText,
          dot: Color(0xFFA07520),
        );
      default:
        return const _StatusCfg(
          bg: AgriColors.statusTidakAktifBg,
          text: AgriColors.statusTidakAktifText,
          dot: Color(0xFF6B6358),
        );
    }
  }
}

class _StatusCfg {
  const _StatusCfg({required this.bg, required this.text, required this.dot});

  final Color bg;
  final Color text;
  final Color dot;
}

// ─── AgriCard ─────────────────────────────────────────────────────────────────

class AgriCard extends StatelessWidget {
  const AgriCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.color = AgriColors.card,
    this.border = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color color;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ? Border.all(color: AgriColors.border) : null,
      ),
      padding: padding ?? EdgeInsets.all(16.w),
      child: child,
    );
  }
}

// ─── AgriPrimaryButton ────────────────────────────────────────────────────────

class AgriPrimaryButton extends StatelessWidget {
  const AgriPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !loading;
    return GestureDetector(
      onTap: isActive ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isActive ? AgriColors.lime : const Color(0xFFD4D2C6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AgriColors.forest),
                ),
              )
            else if (icon != null) ...[
              Icon(icon,
                  size: 22,
                  color: isActive ? AgriColors.forest : AgriColors.inkMuted),
              SizedBox(width: 10.w),
            ],
            if (!loading)
              Text(
                label,
                style: AgriTypography.ctaButton.copyWith(
                  color: isActive ? AgriColors.forest : AgriColors.inkMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── StickyBottomBar ──────────────────────────────────────────────────────────

class StickyBottomBar extends StatelessWidget {
  const StickyBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.7, 1.0],
          colors: [AgriColors.background, Color(0x00EBE9E0)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20.w, 16, 20.w, 20 + MediaQuery.viewPaddingOf(context).bottom),
      child: child,
    );
  }
}

// ─── TopoPattern ─────────────────────────────────────────────────────────────

class TopoPattern extends StatelessWidget {
  const TopoPattern({
    super.key,
    this.opacity = 0.12,
    this.color = AgriColors.lime,
  });

  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        painter: _TopoPainter(color: color),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TopoPainter extends CustomPainter {
  const _TopoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Use a uniform "cover" scale so the pattern is never distorted on
    // cards whose aspect ratio differs from the 400×400 design space.
    final s = (size.width / 400).clamp(size.height / 400, double.infinity);
    final sx = s;
    final sy = s;

    void drawCurve(List<Offset> pts) {
      if (pts.length < 3) return;
      final path = Path()..moveTo(pts[0].dx * sx, pts[0].dy * sy);
      for (var i = 1; i < pts.length - 1; i++) {
        final mid = Offset(
          (pts[i].dx + pts[i + 1].dx) / 2 * sx,
          (pts[i].dy + pts[i + 1].dy) / 2 * sy,
        );
        path.quadraticBezierTo(
          pts[i].dx * sx,
          pts[i].dy * sy,
          mid.dx,
          mid.dy,
        );
      }
      // close to last point
      final last = pts.last;
      path.lineTo(last.dx * sx, last.dy * sy);
      canvas.drawPath(path, paint);
    }

    // 10 contour lines — full top-to-bottom coverage with organic undulation
    drawCurve([
      const Offset(-20, 18),
      const Offset(70, 6),
      const Offset(170, 22),
      const Offset(280, 8),
      const Offset(370, 20),
      const Offset(420, 14),
    ]);
    drawCurve([
      const Offset(-20, 62),
      const Offset(60, 48),
      const Offset(150, 70),
      const Offset(260, 52),
      const Offset(360, 66),
      const Offset(420, 58),
    ]);
    drawCurve([
      const Offset(-20, 108),
      const Offset(75, 90),
      const Offset(165, 118),
      const Offset(245, 96),
      const Offset(330, 112),
      const Offset(420, 104),
    ]);
    drawCurve([
      const Offset(-20, 158),
      const Offset(65, 140),
      const Offset(150, 168),
      const Offset(230, 150),
      const Offset(320, 160),
      const Offset(420, 152),
    ]);
    drawCurve([
      const Offset(-20, 204),
      const Offset(80, 186),
      const Offset(165, 214),
      const Offset(255, 195),
      const Offset(345, 208),
      const Offset(420, 200),
    ]);
    drawCurve([
      const Offset(-20, 252),
      const Offset(85, 236),
      const Offset(175, 260),
      const Offset(270, 242),
      const Offset(355, 256),
      const Offset(420, 248),
    ]);
    drawCurve([
      const Offset(-20, 300),
      const Offset(72, 284),
      const Offset(162, 308),
      const Offset(258, 290),
      const Offset(348, 304),
      const Offset(420, 296),
    ]);
    drawCurve([
      const Offset(-20, 346),
      const Offset(80, 330),
      const Offset(170, 354),
      const Offset(265, 336),
      const Offset(355, 350),
      const Offset(420, 342),
    ]);
    drawCurve([
      const Offset(-20, 388),
      const Offset(90, 374),
      const Offset(185, 396),
      const Offset(280, 378),
      const Offset(370, 392),
      const Offset(420, 384),
    ]);

    void drawEllipse(double cx, double cy, double rx, double ry) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx * sx, cy * sy),
          width: rx * 2 * sx,
          height: ry * 2 * sy,
        ),
        paint,
      );
    }

    // 4 topo-ring clusters spread across the canvas
    drawEllipse(110, 190, 88, 54);
    drawEllipse(110, 190, 62, 36);
    drawEllipse(110, 190, 36, 20);
    drawEllipse(110, 190, 16, 9);

    drawEllipse(300, 80, 68, 42);
    drawEllipse(300, 80, 44, 26);
    drawEllipse(300, 80, 22, 13);

    drawEllipse(270, 320, 76, 46);
    drawEllipse(270, 320, 50, 30);
    drawEllipse(270, 320, 26, 16);

    drawEllipse(60, 60, 48, 30);
    drawEllipse(60, 60, 28, 17);
  }

  @override
  bool shouldRepaint(_TopoPainter old) => old.color != color;
}

// ─── StickyCtaWrapper (correct implementation) ───────────────────────────────

class StickyCtaWrapper extends StatelessWidget {
  const StickyCtaWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.7, 1.0],
          colors: [AgriColors.background, Color(0x00EBE9E0)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16, 20.w, 20 + bottomPadding),
      child: child,
    );
  }
}

// ─── MetricCard ───────────────────────────────────────────────────────────────

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.suffix,
    required this.badge,
    required this.badgeBg,
    required this.badgeText,
    required this.description,
    required this.icon,
  });

  final String label;
  final String value;
  final String suffix;
  final String badge;
  final Color badgeBg;
  final Color badgeText;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: AgriTypography.sectionLabel,
              ),
              Icon(icon, size: 16, color: AgriColors.inkMuted),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: AgriTypography.metricValue),
              if (suffix.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    suffix,
                    style: AgriTypography.textTheme.titleLarge!
                        .copyWith(color: AgriColors.ink),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: AgriTypography.badgeText.copyWith(
                fontSize: 12,
                color: badgeText,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: AgriTypography.textTheme.bodySmall!.copyWith(
              fontSize: 12,
              color: AgriColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
