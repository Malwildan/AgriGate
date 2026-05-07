
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
                      'Prakiraan Cuaca Setempat',
                      style: AgriTypography.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AgriColors.ink,
                      ),
                    ),
                    Text(
                      'Sumber: Railway AI API',
                      style: AgriTypography.textTheme.bodySmall?.copyWith(
                        color: AgriColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          if (weather.humidityMean > 0)
            _ParameterCard(
              icon: Icons.water_outlined,
              label: 'Kelembapan Udara',
              valueWidget: Text(
                '${weather.humidityMean.toStringAsFixed(1)} %',
                style: AgriTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AgriColors.ink,
                ),
              ),
              narration: _humidityNarration(weather.humidityMean),
            ),

          SizedBox(height: 10.h),
          _ParameterCard(
            icon: Icons.water_drop_outlined,
            label: 'Curah Hujan',
            valueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total 90 hari: ${weather.precipitationTotal.toStringAsFixed(0)} mm',
                  style: AgriTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AgriColors.ink,
                  ),
                ),
                Text(
                  'Rata-rata: ${(weather.precipitationTotal / 3).toStringAsFixed(0)} mm/bulan',
                  style: AgriTypography.textTheme.bodySmall?.copyWith(
                    color: AgriColors.inkMuted,
                  ),
                ),
              ],
            ),
            narration: _rainNarration(weather.precipitationTotal),
          ),

          SizedBox(height: 10.h),
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

  static String _humidityNarration(double humidity) {
    if (humidity < 40) {
      return 'Kelembapan udara sangat rendah (${humidity.toStringAsFixed(0)}%). '
          'Tanaman rentan mengalami stres kekeringan — pastikan irigasi cukup.';
    }
    if (humidity < 60) {
      return 'Kelembapan udara rendah–sedang (${humidity.toStringAsFixed(0)}%). '
          'Cocok untuk tanaman seperti jagung, kacang tanah, dan singkong.';
    }
    if (humidity < 80) {
      return 'Kelembapan udara sedang–baik (${humidity.toStringAsFixed(0)}%). '
          'Kondisi optimal untuk sebagian besar tanaman pangan.';
    }
    return 'Kelembapan udara tinggi (${humidity.toStringAsFixed(0)}%). '
        'Perhatikan sirkulasi udara dan risiko penyakit jamur pada tanaman.';
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

}

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
                Icons.opacity_rounded,
                size: 10,
                color: AgriColors.inkMuted,
              ),
              SizedBox(width: 2.w),
              Text(
                '${month.humidityMean.toStringAsFixed(0)}%',
                style: AgriTypography.textTheme.bodySmall?.copyWith(
                  color: AgriColors.inkMuted,
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
          valueWidget,
          SizedBox(height: 8.h),
          Container(height: 1, color: AgriColors.borderStrong),
          SizedBox(height: 8.h),
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
