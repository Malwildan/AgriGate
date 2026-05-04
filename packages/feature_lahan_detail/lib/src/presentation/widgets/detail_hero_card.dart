// DetailHeroCard — crop image hero with lahan owner, area, location, and latest rec.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';

const _cropImages = {
  'Jagung': 'https://images.unsplash.com/photo-1649251037465-72c9d378acb6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Padi': 'https://images.unsplash.com/photo-1655903724829-37b3cd3d4ab9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Singkong': 'https://images.unsplash.com/photo-1710425417427-fee66167fa35?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Kedelai': 'https://images.unsplash.com/photo-1758158329346-bed873fb6d9a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Kacang Tanah': 'https://images.unsplash.com/photo-1703542136049-dd9df98bd648?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Ubi Jalar': 'https://images.unsplash.com/photo-1741112480266-62def497fa27?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Kangkung': 'https://images.unsplash.com/photo-1767334573903-f280cb211993?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Bayam': 'https://images.unsplash.com/photo-1746258170547-35c35a8f9c9e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Sorgum': 'https://images.unsplash.com/photo-1758356860542-a2df92aad294?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Gandum': 'https://images.unsplash.com/photo-1657626625832-2c0851cdaa9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
};

class DetailHeroCard extends StatelessWidget {
  const DetailHeroCard({
    super.key,
    required this.lahan,
    required this.latest,
    required this.rec,
    required this.isPickerOpen,
    required this.onTogglePicker,
  });

  final Lahan lahan;
  final ScanRecord latest;
  final CropRecommendation rec;
  final bool isPickerOpen;
  final VoidCallback onTogglePicker;

  @override
  Widget build(BuildContext context) {
    final imgUrl = _cropImages[rec.main];
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AgriColors.forest,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imgUrl != null)
            Image.network(
              imgUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: AgriColors.forest),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x73141A16), Color(0xEB141A16)],
              ),
            ),
          ),
          const Positioned.fill(
            child: TopoPattern(opacity: 0.16, color: AgriColors.lime),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
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
                            style: AgriTypography.textTheme.headlineLarge!
                                .copyWith(color: const Color(0xFFF5F3E9)),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            lahan.area,
                            style: AgriTypography.textTheme.bodyMedium!
                                .copyWith(
                              color: const Color(0xC7F0EDE1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (lahan.location.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 13,
                                    color: Color(0xB3F0EDE1)),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    lahan.location,
                                    style: AgriTypography.textTheme.bodySmall!
                                        .copyWith(
                                      color: const Color(0xB3F0EDE1),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _StatusButton(
                      status: lahan.status,
                      isPickerOpen: isPickerOpen,
                      onTap: onTogglePicker,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'SCAN TERAKHIR · ${latest.date}'.toUpperCase(),
                  style: AgriTypography.sectionLabel.copyWith(
                    color: AgriColors.lime,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanaman direkomendasikan',
                            style: AgriTypography.textTheme.bodySmall!
                                .copyWith(
                              color: const Color(0xB3F0EDE1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            rec.main,
                            style: AgriTypography.textTheme.displayMedium!
                                .copyWith(
                              color: const Color(0xFFF5F3E9),
                              fontSize: 38,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AgriColors.lime,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.grass_rounded,
                          size: 26, color: AgriColors.forest),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.status,
    required this.isPickerOpen,
    required this.onTap,
  });

  final LahanStatus status;
  final bool isPickerOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg(status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cfg.bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: cfg.dot,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              status.label,
              style: AgriTypography.badgeText.copyWith(color: cfg.text),
            ),
            SizedBox(width: 4.w),
            Icon(
              isPickerOpen
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: cfg.text,
            ),
          ],
        ),
      ),
    );
  }

  _C _cfg(LahanStatus s) => switch (s) {
        LahanStatus.aktif => const _C(
            bg: AgriColors.statusAktifBg,
            text: AgriColors.statusAktifText,
            dot: Color(0xFF3A5E15),
          ),
        LahanStatus.perencanaan => const _C(
            bg: AgriColors.statusPerencanaanBg,
            text: AgriColors.statusPerencanaanText,
            dot: Color(0xFFA07520),
          ),
        LahanStatus.tidakAktif => const _C(
            bg: AgriColors.statusTidakAktifBg,
            text: AgriColors.statusTidakAktifText,
            dot: Color(0xFF6B6358),
          ),
      };
}

class _C {
  const _C({required this.bg, required this.text, required this.dot});
  final Color bg;
  final Color text;
  final Color dot;
}
