// Result Page — recommendation hero, insight, soil metrics, and save CTA.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import '../bloc/result_bloc.dart';
import '../widgets/recommendation_hero_card.dart';
import '../widgets/soil_metrics_row.dart';
import '../widgets/weather_context_card.dart';
import '../mappers/ph_moisture_config_mapper.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.scanData,
    required this.lahanId,
    required this.ownerName,
    required this.lahanArea,
    required this.onScanAgain,
    required this.onSaved,
    required this.onBack,
    this.location = '',
  });

  final ScanData scanData;
  final int lahanId;
  final String ownerName;
  final String lahanArea;
  final VoidCallback onScanAgain;
  final ValueChanged<int> onSaved;
  final VoidCallback onBack;

  /// GPS "lat, lon" string used to enrich the recommendation with weather data.
  final String location;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
    context.read<ResultBloc>().add(ResultInitialized(
          scanData: widget.scanData,
          lahanId: widget.lahanId,
          ownerName: widget.ownerName,
          lahanArea: widget.lahanArea,
          location: widget.location,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResultBloc, ResultState>(
      listenWhen: (prev, curr) =>
          curr is ResultSaved || curr is ResultError,
      listener: (context, state) {
        if (state is ResultSaved) {
          widget.onSaved(state.lahanId);
        } else if (state is ResultError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AgriColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final ready = switch (state) {
          ResultReady() => state,
          ResultSaving(:final ready) => ready,
          _ => null,
        };
        final isSaving = state is ResultSaving;
        final isLoadingWeather = state is ResultLoadingWeather;

        return Scaffold(
          backgroundColor: AgriColors.background,
          appBar: AgriAppBar(backLabel: 'Scan', onBack: widget.onBack),
          body: (ready != null)
              ? _buildContent(context, ready, isSaving: isSaving)
              : isLoadingWeather
                  ? Center(child: _buildWeatherLoading())
                  : const Center(child: CircularProgressIndicator.adaptive()),
          bottomNavigationBar: ready != null
              ? StickyCtaWrapper(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Secondary: Scan Ulang
                      GestureDetector(
                        onTap: isSaving ? null : widget.onScanAgain,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 52,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSaving
                                  ? AgriColors.borderStrong
                                  : AgriColors.ink,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 20,
                                color: isSaving
                                    ? AgriColors.inkMuted
                                    : AgriColors.ink,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Scan Ulang',
                                style: AgriTypography.ctaButton.copyWith(
                                  color: isSaving
                                      ? AgriColors.inkMuted
                                      : AgriColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Primary: Simpan Riwayat
                      AgriPrimaryButton(
                        label: 'Simpan Riwayat',
                        icon: Icons.save_rounded,
                        loading: isSaving,
                        onPressed: isSaving
                            ? null
                            : () => context
                                .read<ResultBloc>()
                                .add(const ResultSaveRequested()),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildWeatherLoading() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          SizedBox(height: 16.h),
          Text(
            'Mengambil prakiraan musiman 6 bulan\nuntuk rekomendasi yang lebih akurat…',
            textAlign: TextAlign.center,
            style: AgriTypography.textTheme.bodyMedium?.copyWith(
              color: AgriColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ResultReady state, {
    required bool isSaving,
  }) {
    final rec = state.recommendation;
    final phCfg = PhMoistureConfigMapper.phConfig(rec.phLabel);
    final mCfg = PhMoistureConfigMapper.moistureConfig(rec.moistureLabel);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
            child: Column(
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil Analisis',
                            style: AgriTypography.textTheme.displaySmall,
                          ),
                          if (state.ownerName.isNotEmpty ||
                              state.lahanArea.isNotEmpty)
                            Text(
                              [state.ownerName, state.lahanArea]
                                  .where((s) => s.isNotEmpty)
                                  .join(' · '),
                              style: AgriTypography.textTheme.bodyMedium!
                                  .copyWith(
                                color: AgriColors.inkSoft,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      state.dateLabel,
                      style: AgriTypography.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AgriColors.inkSoft,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Hero
                RecommendationHeroCard(recommendation: rec),
                SizedBox(height: 12.h),
                // Insight
                _InsightCard(insight: rec.insight),
                SizedBox(height: 16.h),
                // Section divider — Soil
                _SectionDivider(label: 'Kondisi Tanah'),
                SizedBox(height: 12.h),
                // Metrics
                SoilMetricsRow(
                  ph: state.scanData.ph,
                  moisture: state.scanData.moisture,
                  phLabel: rec.phLabel,
                  moistureLabel: rec.moistureLabel,
                  phCfg: phCfg,
                  mCfg: mCfg,
                ),
                // Weather section (only when data was fetched)
                if (rec.weatherData != null) ...[
                  SizedBox(height: 16.h),
                  _SectionDivider(label: 'Iklim & Cuaca'),
                  SizedBox(height: 12.h),
                  WeatherContextCard(
                    weather: rec.weatherData!,
                    climateInsight: rec.climateInsight,
                  ),
                ],
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final String insight;

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AgriColors.lime,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.biotech_rounded,
                size: 18, color: AgriColors.forest),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              insight,
              style: AgriTypography.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SectionLabel(label),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            height: 1,
            color: AgriColors.borderStrong,
          ),
        ),
      ],
    );
  }
}
