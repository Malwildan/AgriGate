// Hero greeting card widget for the lahan list screen.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_design_system/agri_design_system.dart';

class HeroGreetingCard extends StatelessWidget {
  const HeroGreetingCard({
    super.key,
    required this.lahanCount,
    required this.totalScans,
    required this.activeCount,
  });

  final int lahanCount;
  final int totalScans;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AgriColors.forest,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: TopoPattern(opacity: 0.18, color: AgriColors.lime),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELAMAT DATANG',
                  style: AgriTypography.sectionLabel.copyWith(
                    color: AgriColors.lime,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tingkatkan\nproduksi pertanian',
                  style: AgriTypography.textTheme.displayMedium!.copyWith(
                    color: const Color(0xFFF5F3E9),
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Analisis tanah cerdas untuk hasil panen optimal '
                  'melalui sensor & rekomendasi rotasi tanaman.',
                  style: AgriTypography.textTheme.bodyMedium!.copyWith(
                    color: const Color(0xB3F0EDE1),
                  ),
                ),
                SizedBox(height: 20.h),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatChip(label: 'Lahan', value: lahanCount),
                      SizedBox(width: 12.w),
                      _StatChip(label: 'Total Scan', value: totalScans),
                      SizedBox(width: 12.w),
                      _StatChip(label: 'Aktif', value: activeCount),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0x14F0EDE1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x24F0EDE1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: AgriTypography.textTheme.headlineMedium!.copyWith(
                fontSize: 30,
                color: const Color(0xFFF5F3E9),
                letterSpacing: -0.6,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label.toUpperCase(),
              style: AgriTypography.sectionLabel.copyWith(
                color: const Color(0x99F0EDE1),
                fontSize: 11,
                letterSpacing: 0.6,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
