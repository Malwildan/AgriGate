
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_design_system/agri_design_system.dart';
import '../mappers/ph_moisture_config_mapper.dart';

class SoilMetricsRow extends StatelessWidget {
  const SoilMetricsRow({
    super.key,
    required this.ph,
    required this.moisture,
    required this.phLabel,
    required this.moistureLabel,
    required this.phCfg,
    required this.mCfg,
  });

  final double ph;
  final int moisture;
  final String phLabel;
  final String moistureLabel;
  final LabelConfig phCfg;
  final LabelConfig mCfg;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MetricCard(
              label: 'pH',
              value: ph.toStringAsFixed(1),
              suffix: '',
              badge: phLabel,
              badgeBg: phCfg.bg,
              badgeText: phCfg.text,
              description: phCfg.desc,
              icon: Icons.science_rounded,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: MetricCard(
              label: 'Kelembapan',
              value: '$moisture',
              suffix: '%',
              badge: moistureLabel,
              badgeBg: mCfg.bg,
              badgeText: mCfg.text,
              description: mCfg.desc,
              icon: Icons.water_drop_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
