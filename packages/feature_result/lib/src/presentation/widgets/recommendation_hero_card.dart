
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
const _cropImages = {
  'Jagung':
      'https://images.unsplash.com/photo-1649251037465-72c9d378acb6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Padi':
      'https://images.unsplash.com/photo-1655903724829-37b3cd3d4ab9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Singkong':
      'https://images.unsplash.com/photo-1710425417427-fee66167fa35?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Kedelai':
      'https://images.unsplash.com/photo-1758158329346-bed873fb6d9a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Kacang Tanah':
      'https://images.unsplash.com/photo-1703542136049-dd9df98bd648?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Ubi Jalar':
      'https://images.unsplash.com/photo-1741112480266-62def497fa27?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Kangkung':
      'https://images.unsplash.com/photo-1767334573903-f280cb211993?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Bayam':
      'https://images.unsplash.com/photo-1746258170547-35c35a8f9c9e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Sorgum':
      'https://images.unsplash.com/photo-1758356860542-a2df92aad294?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
  'Gandum':
      'https://images.unsplash.com/photo-1657626625832-2c0851cdaa9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
};

class RecommendationHeroCard extends StatelessWidget {
  const RecommendationHeroCard({super.key, required this.recommendation});

  final CropRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final imgUrl = _cropImages[recommendation.main];
    return Container(
      height: 280,
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
                colors: [Color(0x8C141A16), Color(0xEB141A16)],
              ),
            ),
          ),
          const Positioned.fill(
            child: TopoPattern(opacity: 0.14, color: AgriColors.lime),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
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
                            'REKOMENDASI TANAM',
                            style: AgriTypography.sectionLabel.copyWith(
                              color: AgriColors.lime,
                              letterSpacing: 1.6,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          AutoSizeText(
                            recommendation.main,
                            style: AgriTypography.textTheme.displayLarge!
                                .copyWith(color: const Color(0xFFF5F3E9)),
                            maxLines: 1,
                            minFontSize: 18,
                            maxFontSize: 40,
                            stepGranularity: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AgriColors.lime,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.grass_rounded,
                          size: 28, color: AgriColors.forest),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'ALTERNATIF',
                  style: AgriTypography.sectionLabel.copyWith(
                    color: const Color(0xB3F0EDE1),
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recommendation.alternatives
                      .map((alt) => _AltChip(name: alt.name))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AltChip extends StatelessWidget {
  const _AltChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x1EF0EDE1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33F0EDE1)),
      ),
      child: Text(
        name,
        style: AgriTypography.textTheme.bodySmall!.copyWith(
          color: const Color(0xFFF0EDE1),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
