
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import '../bloc/detail_bloc.dart';
import '../widgets/detail_hero_card.dart';
import '../widgets/scan_history_timeline.dart';

class LahanDetailPage extends StatefulWidget {
  const LahanDetailPage({
    super.key,
    required this.lahanId,
    required this.onBack,
    required this.onRescan,
    required this.onOpenHistoryRecord,
  });

  final int lahanId;
  final VoidCallback onBack;
  final ValueChanged<Lahan> onRescan;
  final ValueChanged<ScanRecord> onOpenHistoryRecord;

  @override
  State<LahanDetailPage> createState() => _LahanDetailPageState();
}

class _LahanDetailPageState extends State<LahanDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<DetailBloc>().add(DetailLoadRequested(widget.lahanId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AgriColors.background,
          appBar: AgriAppBar(backLabel: 'Lahan', onBack: widget.onBack),
          body: switch (state) {
            DetailLoading() || DetailInitial() => _buildSkeleton(),
            DetailLoaded(:final lahan) => _buildContent(context, lahan),
            DetailError(:final message) => _buildError(context, message),
          },
          bottomNavigationBar: state is DetailLoaded
              ? StickyCtaWrapper(
                  child: AgriPrimaryButton(
                    label: 'Scan Ulang Lahan Ini',
                    icon: Icons.document_scanner_rounded,
                    onPressed: () => widget.onRescan(state.lahan),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    Lahan lahan,
  ) {
    final latest = lahan.latestScan;
    final rec = latest != null
        ? CropRecommendation(
            main: latest.recommendation,
            alternatives: const [],
            insight: '',
            phLabel: phLabelFor(latest.ph),
            moistureLabel: moistureLabelFor(latest.moisture),
          )
        : null;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            child: Column(
              children: [
                if (latest != null && rec != null)
                  DetailHeroCard(
                    lahan: lahan,
                    latest: latest,
                    rec: rec,
                    onStatusSelected: (status) =>
                        context.read<DetailBloc>().add(DetailStatusChanged(
                              lahanId: lahan.id,
                              status: status,
                            )),
                  ),
                if (latest != null && rec != null) ...[
                  SizedBox(height: 12.h),
                  _QuickMetrics(latest: latest, rec: rec),
                ],
                SizedBox(height: 20.h),
                ScanHistoryTimeline(
                  scanHistory: lahan.scanHistory,
                  onRecordTap: widget.onOpenHistoryRecord,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      child: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Colors.grey,
              )),
          SizedBox(height: 12.h),
          Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey,
              )),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AgriColors.error),
          SizedBox(height: 16.h),
          Text(message, style: AgriTypography.textTheme.bodyMedium),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context
                .read<DetailBloc>()
                .add(DetailLoadRequested(widget.lahanId)),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _QuickMetrics extends StatelessWidget {
  const _QuickMetrics({required this.latest, required this.rec});

  final ScanRecord latest;
  final CropRecommendation rec;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SmallMetricCard(
            label: 'pH',
            value: latest.ph.toStringAsFixed(1),
            badge: rec.phLabel,
            badgeBg: _phBg(rec.phLabel),
            badgeText: _phText(rec.phLabel),
            icon: Icons.science_rounded,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SmallMetricCard(
            label: 'Lembap',
            value: '${latest.moisture}%',
            badge: rec.moistureLabel,
            badgeBg: _mBg(rec.moistureLabel),
            badgeText: _mText(rec.moistureLabel),
            icon: Icons.water_drop_rounded,
          ),
        ),
      ],
    );
  }

  static Color _phBg(String l) => switch (l) {
        'Sangat Asam' => AgriColors.phSangatAsamBg,
        'Asam' => AgriColors.phAsamBg,
        'Netral' => AgriColors.phNetralBg,
        'Basa Ringan' => AgriColors.phBasaRinganBg,
        _ => AgriColors.phBasaBg,
      };

  static Color _phText(String l) => switch (l) {
        'Sangat Asam' => AgriColors.phSangatAsamText,
        'Asam' => AgriColors.phAsamText,
        'Netral' => AgriColors.phNetralText,
        'Basa Ringan' => AgriColors.phBasaRinganText,
        _ => AgriColors.phBasaText,
      };

  static Color _mBg(String l) => switch (l) {
        'Rendah' => AgriColors.moistureRendahBg,
        'Sedang' => AgriColors.moistureSedangBg,
        'Cukup' => AgriColors.moistureCukupBg,
        _ => AgriColors.moistureTinggiBg,
      };

  static Color _mText(String l) => switch (l) {
        'Rendah' => AgriColors.moistureRendahText,
        'Sedang' => AgriColors.moistureSedangText,
        'Cukup' => AgriColors.moistureCukupText,
        _ => AgriColors.moistureTinggiText,
      };
}

class _SmallMetricCard extends StatelessWidget {
  const _SmallMetricCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeBg,
    required this.badgeText,
    required this.icon,
  });

  final String label;
  final String value;
  final String badge;
  final Color badgeBg;
  final Color badgeText;
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
              Text(label.toUpperCase(), style: AgriTypography.sectionLabel),
              Icon(icon, size: 16, color: AgriColors.inkMuted),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AgriTypography.textTheme.headlineLarge!.copyWith(
              fontSize: 36,
              letterSpacing: -0.8,
            ),
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
        ],
      ),
    );
  }
}
