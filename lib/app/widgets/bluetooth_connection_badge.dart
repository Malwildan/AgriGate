import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import 'package:feature_scan/feature_scan.dart';
import 'package:flutter/material.dart';

import '../di/injection.dart';

class BluetoothConnectionBadge extends StatelessWidget {
  const BluetoothConnectionBadge({
    super.key,
    this.dark = false,
  });

  final bool dark;

  void _openDevicePicker(BuildContext context, BleService bleService) {
    BleDevicePickerSheet.show(
      context,
      createBloc: () => ScanBloc(
        bleService: bleService,
        locationService: getIt<LocationService>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bleService = getIt<BleService>();

    return StreamBuilder<BleConnectionState>(
      stream: bleService.connectionState,
      initialData: bleService.currentConnectionState,
      builder: (context, snapshot) {
        final connectionState =
            snapshot.data ?? BleConnectionState.disconnected;
        final appearance = _BadgeAppearance.fromState(connectionState);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _openDevicePicker(context, bleService),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: dark ? appearance.darkBackground : appearance.background,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: dark ? appearance.darkBorder : appearance.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: appearance.dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appearance.label,
                    style: AgriTypography.liveIndicator.copyWith(
                      color: dark ? appearance.darkText : appearance.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BadgeAppearance {
  const _BadgeAppearance({
    required this.label,
    required this.dot,
    required this.background,
    required this.border,
    required this.text,
    required this.darkBackground,
    required this.darkBorder,
    required this.darkText,
  });

  final String label;
  final Color dot;
  final Color background;
  final Color border;
  final Color text;
  final Color darkBackground;
  final Color darkBorder;
  final Color darkText;

  factory _BadgeAppearance.fromState(BleConnectionState state) {
    return switch (state) {
      BleConnectionState.connected => const _BadgeAppearance(
          label: 'CONNECTED',
          dot: Color(0xFF2F9E44),
          background: Color(0xFFEAF6ED),
          border: Color(0xFFB9DDBF),
          text: Color(0xFF1F5B2B),
          darkBackground: Color(0x1439C16C),
          darkBorder: Color(0x2B7ACF95),
          darkText: Color(0xFFF0EDE1),
        ),
      BleConnectionState.connecting => const _BadgeAppearance(
          label: 'CONNECTING',
          dot: Color(0xFFF08C00),
          background: Color(0xFFFFF4E5),
          border: Color(0xFFF3CD84),
          text: Color(0xFF8A4B00),
          darkBackground: Color(0x14F0A202),
          darkBorder: Color(0x2BF5C36A),
          darkText: Color(0xFFF0EDE1),
        ),
      BleConnectionState.disconnected ||
      BleConnectionState.disconnecting =>
        const _BadgeAppearance(
          label: 'NOT CONNECTED',
          dot: Color(0xFFC92A2A),
          background: Color(0xFFFBECEC),
          border: Color(0xFFF0C7C7),
          text: Color(0xFF8A2C2C),
          darkBackground: Color(0x14F87171),
          darkBorder: Color(0x2BFAA2A2),
          darkText: Color(0xFFF0EDE1),
        ),
    };
  }
}
