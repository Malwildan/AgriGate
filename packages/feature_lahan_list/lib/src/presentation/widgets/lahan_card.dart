// LahanCard widget — compact list item showing lahan summary.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import '../../mappers/crop_image_mapper.dart';

class LahanCard extends StatelessWidget {
  const LahanCard({
    super.key,
    required this.lahan,
    required this.onTap,
  });

  final Lahan lahan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latest = lahan.latestScan;
    final rec = latest != null
        ? GetRecommendationUseCase.compute(
            ph: latest.ph,
            moisture: latest.moisture,
          )
        : null;
    final cropImg = rec != null ? CropImageMapper.urlFor(rec.main) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AgriColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AgriColors.border),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(imageUrl: cropImg),
              SizedBox(width: 12.w),
              Expanded(
                child: _CardBody(
                  lahan: lahan,
                  latest: latest,
                  rec: rec,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AgriColors.forest,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.eco_rounded,
                size: 28,
                color: AgriColors.lime,
              ),
            )
          : const Icon(Icons.eco_rounded, size: 28, color: AgriColors.lime),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.lahan,
    required this.latest,
    required this.rec,
  });

  final Lahan lahan;
  final ScanRecord? latest;
  final CropRecommendation? rec;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lahan.owner,
                    style: AgriTypography.textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    lahan.area,
                    style: AgriTypography.textTheme.bodySmall!
                        .copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            StatusBadge(label: lahan.status.label),
          ],
        ),
        SizedBox(height: 10.h),
        if (latest != null && rec != null)
          _ScanSummaryRow(latest: latest!, rec: rec!)
        else
          Text(
            'Belum ada data scan',
            style: AgriTypography.textTheme.bodySmall!
                .copyWith(fontStyle: FontStyle.italic),
          ),
        if (lahan.location.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 11, color: AgriColors.inkMuted),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  lahan.location,
                  style: AgriTypography.textTheme.bodySmall!.copyWith(
                    fontSize: 12,
                    color: AgriColors.inkMuted,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ScanSummaryRow extends StatelessWidget {
  const _ScanSummaryRow({required this.latest, required this.rec});

  final ScanRecord latest;
  final CropRecommendation rec;

  @override
  Widget build(BuildContext context) {
    final style = AgriTypography.textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.w700,
      color: AgriColors.ink,
    );
    return Row(
      children: [
        const Icon(Icons.science_rounded, size: 13, color: AgriColors.inkMuted),
        SizedBox(width: 4.w),
        Text(latest.ph.toStringAsFixed(1), style: style),
        SizedBox(width: 12.w),
        const Icon(Icons.water_drop_rounded,
            size: 13, color: AgriColors.inkMuted),
        SizedBox(width: 4.w),
        Text('${latest.moisture}%', style: style),
        SizedBox(width: 12.w),
        const Icon(Icons.grass_rounded, size: 13, color: AgriColors.inkMuted),
        SizedBox(width: 4.w),
        Text(rec.main, style: style),
      ],
    );
  }
}
