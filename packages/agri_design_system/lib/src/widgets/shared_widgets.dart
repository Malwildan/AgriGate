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

    final sx = size.width / 400;
    final sy = size.height / 400;

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
      canvas.drawPath(path, paint);
    }

    drawCurve([
      const Offset(-20, 80),
      const Offset(80, 40),
      const Offset(180, 90),
      const Offset(420, 110)
    ]);
    drawCurve([
      const Offset(-20, 130),
      const Offset(90, 100),
      const Offset(200, 140),
      const Offset(420, 160)
    ]);
    drawCurve([
      const Offset(-20, 200),
      const Offset(100, 160),
      const Offset(220, 210),
      const Offset(420, 220)
    ]);
    drawCurve([
      const Offset(-20, 260),
      const Offset(110, 230),
      const Offset(240, 270),
      const Offset(420, 280)
    ]);
    drawCurve([
      const Offset(-20, 320),
      const Offset(100, 290),
      const Offset(230, 330),
      const Offset(420, 340)
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

    drawEllipse(120, 200, 80, 50);
    drawEllipse(120, 200, 55, 32);
    drawEllipse(120, 200, 30, 16);
    drawEllipse(290, 120, 60, 38);
    drawEllipse(290, 120, 38, 22);
    drawEllipse(320, 300, 70, 42);
    drawEllipse(320, 300, 44, 24);
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
