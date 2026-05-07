
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';

class ScanHistoryTimeline extends StatelessWidget {
  const ScanHistoryTimeline({
    super.key,
    required this.scanHistory,
    this.onRecordTap,
  });

  final List<ScanRecord> scanHistory;
  final ValueChanged<ScanRecord>? onRecordTap;

  static String formatRecordedAt(DateTime value) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    return '$day ${months[local.month]} ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final orderedHistory = [...scanHistory]
      ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));

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
          ...orderedHistory.asMap().entries.map((e) {
            final idx = e.key;
            final record = e.value;
            final isLast = idx == orderedHistory.length - 1;
            return _TimelineItem(
              record: record,
              isLast: isLast,
              onTap: onRecordTap == null ? null : () => onRecordTap!(record),
            );
          }),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.record,
    required this.isLast,
    this.onTap,
  });

  final ScanRecord record;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rec = CropRecommendation(
      main: record.recommendation,
      alternatives: const [],
      insight: '',
      phLabel: phLabelFor(record.ph),
      moistureLabel: moistureLabelFor(record.moisture),
    );
    final cardChild = AgriCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  ScanHistoryTimeline.formatRecordedAt(record.recordedAt),
                  maxLines: 1,
                  minFontSize: 10,
                  style: AgriTypography.textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AgriColors.inkSoft,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              AutoSizeText(
                rec.main,
                maxLines: 1,
                minFontSize: 10,
                style: AgriTypography.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AgriColors.ink,
                ),
              ),
              if (onTap != null) ...[
                SizedBox(width: 6.w),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AgriColors.inkMuted,
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _Chip(
                  icon: Icons.science_rounded,
                  label: 'pH ${record.ph.toStringAsFixed(1)}',
                  badge: rec.phLabel,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _Chip(
                  icon: Icons.water_drop_rounded,
                  label: '${record.moisture}%',
                  badge: rec.moistureLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
      child: Stack(
        children: [
          if (!isLast)
            Positioned(
              left: 13,
              top: 19,
              bottom: 0,
              child: Container(
                width: 2,
                color: AgriColors.border,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AgriColors.limeDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: onTap == null
                    ? cardChild
                    : GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onTap,
                        child: cardChild,
                      ),
              ),
            ],
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
        children: [
          Icon(icon, size: 13, color: AgriColors.inkMuted),
          SizedBox(width: 4.w),
          Expanded(
            child: AutoSizeText(
              '$label · $badge',
              maxLines: 1,
              minFontSize: 9,
              style: AgriTypography.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
