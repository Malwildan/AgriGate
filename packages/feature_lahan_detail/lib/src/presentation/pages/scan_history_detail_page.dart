import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/detail_bloc.dart';
import '../widgets/scan_history_timeline.dart';

class ScanHistoryDetailPage extends StatefulWidget {
  const ScanHistoryDetailPage({
    super.key,
    required this.lahanId,
    required this.recordId,
    required this.onBack,
  });

  final int lahanId;
  final int recordId;
  final VoidCallback onBack;

  @override
  State<ScanHistoryDetailPage> createState() => _ScanHistoryDetailPageState();
}

class _ScanHistoryDetailPageState extends State<ScanHistoryDetailPage> {
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
          appBar: AgriAppBar(
            backLabel: 'Riwayat Scan',
            onBack: widget.onBack,
          ),
          body: switch (state) {
            DetailLoading() ||
            DetailInitial() ||
            DetailDeleting() =>
              const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            DetailLoaded(:final lahan) => _buildContent(context, lahan),
            DetailError(:final message) => _buildError(context, message),
            DetailDeleted() => const SizedBox.shrink(),
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, Lahan lahan) {
    final orderedHistory = [...lahan.scanHistory]
      ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));
    final recordIndex = orderedHistory.indexWhere(
      (record) => record.id == widget.recordId,
    );

    if (recordIndex < 0) {
      return _buildMissingRecord();
    }

    final record = orderedHistory[recordIndex];
    final recommendation = CropRecommendation(
      main: record.recommendation,
      alternatives: const [],
      insight: '',
      phLabel: phLabelFor(record.ph),
      moistureLabel: moistureLabelFor(record.moisture),
    );
    final headerSubtitle = [lahan.owner, lahan.area]
        .where((value) => value.trim().isNotEmpty)
        .join(' · ');
    final storedRecommendation = record.recommendation.trim().isEmpty
        ? recommendation.main
        : record.recommendation.trim();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 128.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Riwayat',
                  style: AgriTypography.textTheme.displaySmall,
                ),
                if (headerSubtitle.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    headerSubtitle,
                    style: AgriTypography.textTheme.bodyMedium!.copyWith(
                      color: AgriColors.inkSoft,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: 18.h),
                _SummaryCard(
                  dateLabel:
                      ScanHistoryTimeline.formatRecordedAt(record.recordedAt),
                  recommendationLabel: recommendation.main,
                  totalRecords: orderedHistory.length,
                  selectedIndex: recordIndex,
                ),
                SizedBox(height: 16.h),
                _SectionDivider(label: 'Metrik Tanah'),
                SizedBox(height: 12.h),
                _MetricsRow(
                  record: record,
                  recommendation: recommendation,
                ),
                SizedBox(height: 16.h),
                _SectionDivider(label: 'Rekomendasi'),
                SizedBox(height: 12.h),
                AgriCard(
                  padding: EdgeInsets.all(18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storedRecommendation,
                        style: AgriTypography.textTheme.headlineSmall!.copyWith(
                          color: AgriColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (recommendation.insight.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Text(
                          recommendation.insight,
                          style: AgriTypography.textTheme.bodyMedium!.copyWith(
                            color: AgriColors.inkSoft,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _SectionDivider(label: 'Konteks Riwayat'),
                SizedBox(height: 12.h),
                AgriCard(
                  padding: EdgeInsets.all(18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _historyContext(recordIndex, orderedHistory.length),
                        style: AgriTypography.textTheme.bodyMedium!.copyWith(
                          color: AgriColors.inkSoft,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Expanded(
                            child: _MetaTile(
                              label: 'Total Scan',
                              value: orderedHistory.length.toString(),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _MetaTile(
                              label: 'Posisi Riwayat',
                              value:
                                  '${recordIndex + 1}/${orderedHistory.length}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _historyContext(int recordIndex, int totalRecords) {
    if (totalRecords <= 1) {
      return 'Baru ada satu hasil scan yang tersimpan untuk lahan ini.';
    }

    if (recordIndex == 0) {
      return 'Catatan ini adalah hasil scan paling baru dari seluruh riwayat lahan.';
    }

    if (recordIndex == totalRecords - 1) {
      return 'Catatan ini adalah hasil scan paling lama yang masih tersimpan.';
    }

    final newerCount = recordIndex;
    final olderCount = totalRecords - recordIndex - 1;
    return 'Ada $newerCount hasil scan yang lebih baru dan '
        '$olderCount hasil scan yang lebih lama dari catatan ini.';
  }

  Widget _buildMissingRecord() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_toggle_off_rounded,
              size: 52,
              color: AgriColors.inkMuted,
            ),
            SizedBox(height: 14.h),
            Text(
              'Riwayat scan yang dipilih tidak ditemukan.',
              textAlign: TextAlign.center,
              style: AgriTypography.textTheme.titleMedium,
            ),
            SizedBox(height: 18.h),
            AgriPrimaryButton(
              label: 'Kembali ke Detail Lahan',
              onPressed: widget.onBack,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AgriColors.error,
          ),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.dateLabel,
    required this.recommendationLabel,
    required this.totalRecords,
    required this.selectedIndex,
  });

  final String dateLabel;
  final String recommendationLabel;
  final int totalRecords;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isLatest = selectedIndex == 0;

    return Container(
      decoration: BoxDecoration(
        color: AgriColors.forest,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: TopoPattern(opacity: 0.18, color: AgriColors.lime),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x14F0EDE1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isLatest
                            ? 'Scan Terbaru'
                            : 'Riwayat ${selectedIndex + 1}/$totalRecords',
                        style: AgriTypography.textTheme.bodySmall!.copyWith(
                          color: const Color(0xFFF0EDE1),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.timeline_rounded,
                      color: Color(0xFFF0EDE1),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Text(
                  dateLabel,
                  style: AgriTypography.textTheme.headlineSmall!.copyWith(
                    color: const Color(0xFFF0EDE1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  recommendationLabel,
                  style: AgriTypography.textTheme.displaySmall!.copyWith(
                    color: const Color(0xFFF0EDE1),
                    fontWeight: FontWeight.w800,
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

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.record,
    required this.recommendation,
  });

  final ScanRecord record;
  final CropRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'pH',
            value: record.ph.toStringAsFixed(1),
            badge: recommendation.phLabel,
            icon: Icons.science_rounded,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _MetricCard(
            label: 'Kelembapan',
            value: '${record.moisture}%',
            badge: recommendation.moistureLabel,
            icon: Icons.water_drop_rounded,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.icon,
  });

  final String label;
  final String value;
  final String badge;
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
              Text(
                label,
                style: AgriTypography.sectionLabel,
              ),
              Icon(icon, size: 18, color: AgriColors.inkMuted),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AgriTypography.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w800,
              color: AgriColors.ink,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AgriColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AgriColors.borderStrong),
            ),
            child: Text(
              badge,
              style: AgriTypography.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AgriColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AgriColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AgriTypography.textTheme.bodySmall!.copyWith(
              color: AgriColors.inkSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AgriTypography.textTheme.titleLarge!.copyWith(
              color: AgriColors.ink,
              fontWeight: FontWeight.w800,
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
          child: Container(height: 1, color: AgriColors.borderStrong),
        ),
      ],
    );
  }
}
