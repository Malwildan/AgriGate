
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import '../bloc/scan_bloc.dart';
import 'ble_device_picker_sheet.dart';

class DeviceConnectionCard extends StatelessWidget {
  const DeviceConnectionCard({
    super.key,
    required this.bleStatus,
    required this.connectedDevice,
    required this.onDisconnect,
    this.bleError,
  });

  final ScanBleStatus bleStatus;
  final BleDevice? connectedDevice;
  final VoidCallback onDisconnect;
  final String? bleError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Perangkat Sensor'),
        SizedBox(height: 12.h),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: switch (bleStatus) {
            ScanBleStatus.connected => _ConnectedCard(
                key: const ValueKey('connected'),
                device: connectedDevice,
                onDisconnect: onDisconnect,
              ),
            ScanBleStatus.connecting => _ConnectingCard(
                key: const ValueKey('connecting'),
                device: connectedDevice,
                onCancel: onDisconnect,
              ),
            ScanBleStatus.scanning ||
            ScanBleStatus.error ||
            ScanBleStatus.disconnected =>
              _IdleCard(
                key: const ValueKey('idle'),
                device: connectedDevice,
                errorMessage:
                    bleStatus == ScanBleStatus.error ? bleError : null,
                onOpenPicker: () => BleDevicePickerSheet.show(context),
              ),
          },
        ),
      ],
    );
  }
}

class _IdleCard extends StatelessWidget {
  const _IdleCard({
    super.key,
    required this.onOpenPicker,
    this.device,
    this.errorMessage,
  });

  final VoidCallback onOpenPicker;
  final BleDevice? device;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return _ForestCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0x14F0EDE1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x28F0EDE1)),
            ),
            child: const Icon(
              Icons.bluetooth_rounded,
              size: 36,
              color: Color(0xFFF0EDE1),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Hubungkan ke AgriSensor',
            style: AgriTypography.textTheme.headlineSmall!
                .copyWith(color: const Color(0xFFF0EDE1)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Nyalakan perangkat AgriSensor, lalu ketuk tombol di bawah untuk mencari dan memilih perangkat.',
            style: AgriTypography.textTheme.bodyMedium!
                .copyWith(color: const Color(0xB3F0EDE1)),
            textAlign: TextAlign.center,
          ),
          if (errorMessage != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x2EF47878),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 16, color: Color(0xFFFFD1D1)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      errorMessage!,
                      style: AgriTypography.textTheme.bodySmall!
                          .copyWith(color: const Color(0xFFFFD1D1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 20.h),
          _ActionButton(
            label: 'Pilih Perangkat',
            icon: Icons.bluetooth_searching_rounded,
            onTap: onOpenPicker,
          ),
        ],
      ),
    );
  }
}

class _ConnectingCard extends StatelessWidget {
  const _ConnectingCard({super.key, this.device, required this.onCancel});

  final BleDevice? device;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return _ForestCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AgriColors.lime),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Menghubungkan...',
            style: AgriTypography.textTheme.headlineSmall!
                .copyWith(color: const Color(0xFFF0EDE1)),
          ),
          if (device != null) ...[
            SizedBox(height: 6.h),
            Text(
              device!.displayName,
              style: AgriTypography.textTheme.bodyMedium!
                  .copyWith(color: const Color(0xB3F0EDE1)),
            ),
          ],
          SizedBox(height: 20.h),
          _ActionButton(
            label: 'Batal',
            icon: Icons.close_rounded,
            outlined: true,
            onTap: onCancel,
          ),
        ],
      ),
    );
  }
}

class _ConnectedCard extends StatelessWidget {
  const _ConnectedCard({super.key, this.device, required this.onDisconnect});

  final BleDevice? device;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final rssiPercent =
        device != null ? ((device!.rssi + 100).clamp(0, 70) / 70.0) : 0.0;
    final signalIcon = rssiPercent > 0.6
        ? Icons.signal_cellular_alt_rounded
        : rssiPercent > 0.3
            ? Icons.signal_cellular_alt_2_bar_rounded
            : Icons.signal_cellular_alt_1_bar_rounded;

    return _ForestCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AgriColors.lime,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bluetooth_connected_rounded,
              size: 36,
              color: AgriColors.forest,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            device?.displayName ?? 'AgriSensor',
            style: AgriTypography.textTheme.headlineSmall!
                .copyWith(color: const Color(0xFFF0EDE1)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          _StatusBadge(label: 'TERHUBUNG', color: AgriColors.lime),
          if (device != null) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(signalIcon, size: 16, color: const Color(0xB3F0EDE1)),
                SizedBox(width: 4.w),
                Text(
                  '${device!.rssi} dBm',
                  style: AgriTypography.textTheme.bodySmall!
                      .copyWith(color: const Color(0x80F0EDE1)),
                ),
              ],
            ),
          ],
          SizedBox(height: 14.h),
          Text(
            'Perangkat siap mengambil data tanah.',
            style: AgriTypography.textTheme.bodyMedium!
                .copyWith(color: const Color(0xB3F0EDE1)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          _ActionButton(
            label: 'Putuskan',
            icon: Icons.bluetooth_disabled_rounded,
            outlined: true,
            onTap: onDisconnect,
          ),
        ],
      ),
    );
  }
}

class _ForestCard extends StatelessWidget {
  const _ForestCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AgriColors.forest,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: TopoPattern(opacity: 0.14, color: AgriColors.lime),
          ),
          Padding(
            padding: EdgeInsets.all(28.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 300.h),
              child: Center(child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: outlined ? const Color(0x14F0EDE1) : AgriColors.lime,
          borderRadius: BorderRadius.circular(24),
          border: outlined ? Border.all(color: const Color(0x28F0EDE1)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: outlined ? const Color(0xFFF0EDE1) : AgriColors.forest),
            const SizedBox(width: 8),
            Text(
              label,
              style: AgriTypography.textTheme.titleMedium!.copyWith(
                color: outlined ? const Color(0xFFF0EDE1) : AgriColors.forest,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AgriTypography.badgeText
                .copyWith(color: color, letterSpacing: 0.4),
          ),
        ],
      ),
    );
  }
}
