
import 'package:flutter/material.dart';
import 'package:agri_design_system/agri_design_system.dart';

class LabelConfig {
  const LabelConfig({required this.bg, required this.text, required this.desc});

  final Color bg;
  final Color text;
  final String desc;
}

abstract final class PhMoistureConfigMapper {
  static LabelConfig phConfig(String label) {
    return switch (label) {
      'Sangat Asam' => const LabelConfig(
          bg: AgriColors.phSangatAsamBg,
          text: AgriColors.phSangatAsamText,
          desc: 'Perlu pengapuran segera',
        ),
      'Asam' => const LabelConfig(
          bg: AgriColors.phAsamBg,
          text: AgriColors.phAsamText,
          desc: 'Cocok tanaman toleran asam',
        ),
      'Netral' => const LabelConfig(
          bg: AgriColors.phNetralBg,
          text: AgriColors.phNetralText,
          desc: 'Ideal untuk sebagian besar tanaman',
        ),
      'Basa Ringan' => const LabelConfig(
          bg: AgriColors.phBasaRinganBg,
          text: AgriColors.phBasaRinganText,
          desc: 'Perlu penyesuaian minor',
        ),
      _ => const LabelConfig(
          bg: AgriColors.phBasaBg,
          text: AgriColors.phBasaText,
          desc: 'Kurang cocok, perlu perlakuan',
        ),
    };
  }

  static LabelConfig moistureConfig(String label) {
    return switch (label) {
      'Rendah' => const LabelConfig(
          bg: AgriColors.moistureRendahBg,
          text: AgriColors.moistureRendahText,
          desc: 'Tanah terlalu kering',
        ),
      'Sedang' => const LabelConfig(
          bg: AgriColors.moistureSedangBg,
          text: AgriColors.moistureSedangText,
          desc: 'Perlu irigasi teratur',
        ),
      'Cukup' => const LabelConfig(
          bg: AgriColors.moistureCukupBg,
          text: AgriColors.moistureCukupText,
          desc: 'Kondisi baik untuk pertumbuhan',
        ),
      _ => const LabelConfig(
          bg: AgriColors.moistureTinggiBg,
          text: AgriColors.moistureTinggiText,
          desc: 'Waspadai genangan air',
        ),
    };
  }
}
