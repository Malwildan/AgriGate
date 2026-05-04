// WeatherContextCard — 6-month ECMWF SEAS5 seasonal forecast display.
// Shows a month-by-month strip plus parameter explanation cards with narration
// to help farmers understand what each number means for their crop choices.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';

class WeatherContextCard extends StatelessWidget {
  const WeatherContextCard({
    super.key,
    required this.weather,
    required this.climateInsight,
  });

  final WeatherData weather;
  final String? climateInsight;

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_outlined,
                  size: 18,
                  color: AgriColors.forest,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prakiraan Musiman 6 Bulan',
                      style: AgriTypography.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AgriColors.ink,
                      ),
                    ),
                    Text(
                      'Sumber: ECMWF SEAS5 via Open-Meteo',
                      style: AgriTypography.textTheme.bodySmall?.copyWith(
                        color: AgriColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Month strip ─────────────────────────────────────────────────
          if (weather.months.isNotEmpty) ...[
            SizedBox(height: 14.h),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: weather.months.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) => _MonthTile(month: weather.months[i]),
              ),
            ),
          ],

          SizedBox(height: 14.h),

          // ── Temperature card ─────────────────────────────────────────────
          _ParameterCard(
            icon: Icons.thermostat_rounded,
            label: 'Suhu Udara',
            valueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rata-rata: ${weather.tempMean.toStringAsFixed(1)} °C',
                  style: AgriTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AgriColors.ink,
                  ),
                ),
                Text(
                  'Min ${weather.tempMin.toStringAsFixed(0)} °C  ·  '
                  'Maks ${weather.tempMax.toStringAsFixed(0)} °C',
                  style: AgriTypography.textTheme.bodySmall?.copyWith(
                    color: AgriColors.inkMuted,
                  ),
                ),
              ],
            ),
            narration: _tempNarration(weather.tempMean, weather.tempMax),
          ),

          SizedBox(height: 10.h),

          // ── Precipitation card ────────────────────────────────────────────
          _ParameterCard(
            icon: Icons.water_drop_outlined,
            label: 'Curah Hujan',
            valueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total 6 bulan: ${weather.precipitationTotal.toStringAsFixed(0)} mm',
                  style: AgriTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AgriColors.ink,
                  ),
                ),
                Text(
                  'Rata-rata: ${(weather.precipitationTotal / 6).toStringAsFixed(0)} mm/bulan',
                  style: AgriTypography.textTheme.bodySmall?.copyWith(
                    color: AgriColors.inkMuted,
                  ),
                ),
              ],
            ),
            narration: _rainNarration(weather.precipitationTotal),
          ),

          SizedBox(height: 10.h),

          // ── ET₀ card ──────────────────────────────────────────────────────
          _ParameterCard(
            icon: Icons.opacity_rounded,
            label: 'Kebutuhan Air (ET₀)',
            valueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rata-rata: ${weather.et0Mean.toStringAsFixed(1)} mm/hari',
                  style: AgriTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AgriColors.ink,
                  ),
                ),
                Text(
                  _et0WaterBalance(weather.precipitationTotal, weather.et0Mean),
                  style: AgriTypography.textTheme.bodySmall?.copyWith(
                    color: AgriColors.inkMuted,
                  ),
                ),
              ],
            ),
            narration: _et0Narration(weather.precipitationTotal, weather.et0Mean),
          ),

          // ── Climate insight ───────────────────────────────────────────────
          if (climateInsight != null && climateInsight!.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AgriColors.lime,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_rounded,
                    size: 16,
                    color: AgriColors.forest,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      climateInsight!,
                      style: AgriTypography.textTheme.bodySmall?.copyWith(
                        color: AgriColors.forest,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Narration helpers ──────────────────────────────────────────────────────

  static String _tempNarration(double mean, double max) {
    const base =
        'Suhu optimal untuk tanaman tropis (padi, jagung, singkong) '
        'adalah 20–32 °C. ';
    if (max > 35) {
      return '${base}Prakiraan suhu maksimum ${max.toStringAsFixed(0)} °C '
          'berpotensi menyebabkan stres panas. Gunakan mulsa, tambah irigasi, '
          'dan pilih varietas tahan panas.';
    }
    if (mean < 20) {
      return '${base}Suhu rata-rata ${mean.toStringAsFixed(1)} °C terlalu dingin '
          'untuk kebanyakan tanaman tropis. Pertimbangkan varietas adaptif '
          'suhu rendah atau tunda tanam hingga musim lebih hangat.';
    }
    if (mean > 30) {
      return '${base}Suhu ${mean.toStringAsFixed(1)} °C termasuk hangat. '
          'Ketersediaan air yang cukup penting untuk menjaga produktivitas.';
    }
    return '${base}Suhu rata-rata ${mean.toStringAsFixed(1)} °C berada '
        'dalam kisaran optimal — kondisi baik untuk pertumbuhan tanaman.';
  }

  static String _rainNarration(double total6m) {
    if (total6m < 200) {
      return 'Curah hujan 6 bulan sangat rendah (${total6m.toStringAsFixed(0)} mm). '
          'Sistem irigasi penuh diperlukan. Pilih tanaman toleran kekeringan '
          'seperti singkong atau sorgum.';
    }
    if (total6m < 450) {
      return 'Curah hujan rendah–sedang (${total6m.toStringAsFixed(0)} mm / 6 bulan). '
          'Cocok untuk jagung (butuh ±500–700 mm/musim) atau kacang tanah. '
          'Irigasi suplemen sangat dianjurkan.';
    }
    if (total6m < 900) {
      return 'Curah hujan sedang–baik (${total6m.toStringAsFixed(0)} mm / 6 bulan). '
          'Mendukung padi gogo, jagung, dan kedelai. '
          'Padi sawah membutuhkan ±900–1.200 mm per musim tanam.';
    }
    return 'Curah hujan tinggi (${total6m.toStringAsFixed(0)} mm / 6 bulan). '
        'Sangat mendukung padi sawah. Pastikan sistem drainase lahan '
        'memadai untuk mencegah genangan dan penyakit akar.';
  }

  static String _et0Narration(double total6m, double et0DailyMean) {
    final rainDaily = total6m / 180; // mm/day average over 6 months
    const what =
        'ET₀ (Evapotranspirasi Referensi) adalah estimasi berapa banyak '
        'air yang diuapkan dari lahan terbuka per hari. '
        'Jika curah hujan harian lebih kecil dari ET₀, '
        'tanaman membutuhkan irigasi tambahan.';
    if (rainDaily < et0DailyMean * 0.7) {
      return '$what Dengan rata-rata curah hujan ${rainDaily.toStringAsFixed(1)} mm/hari '
          'dan ET₀ ${et0DailyMean.toStringAsFixed(1)} mm/hari, '
          'defisit air cukup besar — irigasi rutin sangat diperlukan.';
    }
    if (rainDaily < et0DailyMean) {
      return '$what Curah hujan harian (${rainDaily.toStringAsFixed(1)} mm) '
          'sedikit di bawah ET₀ (${et0DailyMean.toStringAsFixed(1)} mm/hari) — '
          'irigasi ringan pada musim kering disarankan.';
    }
    return '$what Curah hujan rata-rata (${rainDaily.toStringAsFixed(1)} mm/hari) '
        'melebihi ET₀ (${et0DailyMean.toStringAsFixed(1)} mm/hari) — '
        'kebutuhan air umumnya terpenuhi oleh hujan.';
  }

  static String _et0WaterBalance(double total6m, double et0DailyMean) {
    final rainDaily = total6m / 180;
    if (rainDaily >= et0DailyMean) return 'Neraca air: surplus';
    if (rainDaily >= et0DailyMean * 0.7) return 'Neraca air: defisit ringan';
    return 'Neraca air: defisit signifikan';
  }
}

// ─── Month tile ───────────────────────────────────────────────────────────────

class _MonthTile extends StatelessWidget {
  const _MonthTile({required this.month});

  final SeasonalMonthData month;

  @override
  Widget build(BuildContext context) {
    final isWet = month.precipitationSum >= 100;
    final isDry = month.precipitationSum < 30;
    final rainColor = isWet
        ? const Color(0xFFD0E8FF)
        : isDry
            ? const Color(0xFFFCEFD6)
            : AgriColors.surface;

    return Container(
      width: 72,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: rainColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriColors.borderStrong),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            // Show only the month part (e.g. "Mei" from "Mei 2026")
            month.monthLabel.split(' ').first,
            style: AgriTypography.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AgriColors.ink,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${month.tempMean.toStringAsFixed(0)}°C',
            style: AgriTypography.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AgriColors.ink,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop_rounded,
                size: 10,
                color: isWet ? const Color(0xFF1565C0) : AgriColors.inkMuted,
              ),
              SizedBox(width: 2.w),
              Text(
                '${month.precipitationSum.toStringAsFixed(0)}',
                style: AgriTypography.textTheme.bodySmall?.copyWith(
                  color: isWet ? const Color(0xFF1565C0) : AgriColors.inkMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Parameter explanation card ───────────────────────────────────────────────

class _ParameterCard extends StatelessWidget {
  const _ParameterCard({
    required this.icon,
    required this.label,
    required this.valueWidget,
    required this.narration,
  });

  final IconData icon;
  final String label;
  final Widget valueWidget;
  final String narration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AgriColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Icon(icon, size: 15, color: AgriColors.inkSoft),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AgriTypography.textTheme.bodySmall?.copyWith(
                  color: AgriColors.inkSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // Value
          valueWidget,
          SizedBox(height: 8.h),
          // Divider
          Container(height: 1, color: AgriColors.borderStrong),
          SizedBox(height: 8.h),
          // Narration
          Text(
            narration,
            style: AgriTypography.textTheme.bodySmall?.copyWith(
              color: AgriColors.inkSoft,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
