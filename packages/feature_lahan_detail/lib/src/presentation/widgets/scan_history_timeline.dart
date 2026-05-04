// ScanHistoryTimeline — dated scan records with pH/moisture chips.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';

class ScanHistoryTimeline extends StatelessWidget {
  const ScanHistoryTimeline({super.key, required this.scanHistory});

  final List<ScanRecord> scanHistory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionLabel('Riwayat Scan'),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(height: 1, color: AgriColors.borderStrong),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (scanHistory.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(
              child: Text(
                'Belum ada riwayat scan.',
                style: AgriTypography.textTheme.bodyMedium!
                    .copyWith(color: AgriColors.inkMuted),
              ),
            ),
          )
        else
          ...scanHistory.reversed.toList().asMap().entries.map((e) {
            final idx = e.key;
            final record = e.value;
            final isLast = idx == scanHistory.length - 1;
            return _TimelineItem(record: record, isLast: isLast);
          }),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.record, required this.isLast});

  final ScanRecord record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final rec = GetRecommendationUseCase.compute(
      ph: record.ph,
      moisture: record.moisture,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    color: AgriColors.lime,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AgriColors.border,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: AgriCard(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record.date,
                          style: AgriTypography.textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AgriColors.inkSoft,
                          ),
                        ),
                        Text(
                          rec.main,
                          style: AgriTypography.textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AgriColors.ink,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _Chip(
                          icon: Icons.science_rounded,
                          label: 'pH ${record.ph.toStringAsFixed(1)}',
                          badge: rec.phLabel,
                        ),
                        SizedBox(width: 8.w),
                        _Chip(
                          icon: Icons.water_drop_rounded,
                          label: '${record.moisture}%',
                          badge: rec.moistureLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.badge,
  });

  final IconData icon;
  final String label;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AgriColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AgriColors.inkMuted),
          SizedBox(width: 4.w),
          Text(
            '$label · $badge',
            style: AgriTypography.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
