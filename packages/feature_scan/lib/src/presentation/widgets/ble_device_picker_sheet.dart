// BleDevicePickerSheet — modal bottom sheet for scanning & selecting a BLE device.
// Opens via BleDevicePickerSheet.show(). Immediately starts a scan when opened,
// streams discovered devices into the list in real-time, and closes itself
// with the chosen [BleDevice] when the user taps a row.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import '../bloc/scan_bloc.dart';

class BleDevicePickerSheet extends StatefulWidget {
  const BleDevicePickerSheet._();

  /// Opens the sheet and returns the device selected by the user,
  /// or null if the sheet was dismissed without selecting.
  static Future<BleDevice?> show(BuildContext context) {
    return showModalBottomSheet<BleDevice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ScanBloc>(),
        child: const BleDevicePickerSheet._(),
      ),
    );
  }

  @override
  State<BleDevicePickerSheet> createState() => _BleDevicePickerSheetState();
}

class _BleDevicePickerSheetState extends State<BleDevicePickerSheet> {
  late final ScanBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ScanBloc>();
    // Auto-start scan when the sheet opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bloc.add(const ScanBleStartScanRequested());
      }
    });
  }

  @override
  void dispose() {
    // Stop scan if the sheet is closed without selecting a device.
    // Use the cached _bloc reference — context is unsafe here.
    if (!_bloc.isClosed &&
        _bloc.state.bleStatus == ScanBleStatus.scanning) {
      _bloc.add(const ScanBleStopScanRequested());
    }
    super.dispose();
  }

  void _selectDevice(BleDevice device) {
    // Stop scan then return the chosen device.
    _bloc.add(const ScanBleStopScanRequested());
    Navigator.of(context).pop(device);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AgriColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: BlocBuilder<ScanBloc, ScanState>(
            builder: (context, state) {
              final isScanning = state.bleStatus == ScanBleStatus.scanning;
              final devices = state.discoveredDevices;

              return Column(
                children: [
                  // ── Handle ──────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AgriColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // ── Header ──────────────────────────────────────────
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pilih Perangkat',
                                style:
                                    AgriTypography.textTheme.headlineSmall,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                isScanning
                                    ? 'Mencari perangkat Bluetooth di sekitar...'
                                    : 'Ketuk "Scan Ulang" untuk memperbarui daftar.',
                                style: AgriTypography.textTheme.bodySmall!
                                    .copyWith(color: AgriColors.inkSoft),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Scan / Refresh button
                        _ScanButton(
                          isScanning: isScanning,
                          onTap: () {
                            if (isScanning) {
                              context
                                  .read<ScanBloc>()
                                  .add(const ScanBleStopScanRequested());
                            } else {
                              context
                                  .read<ScanBloc>()
                                  .add(const ScanBleStartScanRequested());
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    color: AgriColors.border,
                    indent: 20.w,
                    endIndent: 20.w,
                  ),

                  // ── Device list ──────────────────────────────────────
                  Expanded(
                    child: isScanning && devices.isEmpty
                        ? _EmptyScanState(isScanning: isScanning)
                        : devices.isEmpty
                            ? _EmptyScanState(isScanning: false)
                            : ListView.separated(
                                controller: scrollController,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                                itemCount: devices.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 8.h),
                                itemBuilder: (_, i) {
                                  final d = devices[i];
                                  return _DeviceListTile(
                                    device: d,
                                    onTap: () => _selectDevice(d),
                                  );
                                },
                              ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Scan button ──────────────────────────────────────────────────────────────

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.isScanning, required this.onTap});

  final bool isScanning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isScanning
              ? const Color(0x141E2823)
              : AgriColors.forest,
          borderRadius: BorderRadius.circular(20),
          border: isScanning
              ? Border.all(color: const Color(0x331E2823))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isScanning)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AgriColors.forest),
                ),
              )
            else
              Icon(Icons.refresh_rounded,
                  size: 16, color: AgriColors.lime),
            SizedBox(width: 6.w),
            Text(
              isScanning ? 'Berhenti' : 'Scan Ulang',
              style: AgriTypography.textTheme.labelMedium!.copyWith(
                color: isScanning ? AgriColors.forest : AgriColors.lime,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty / loading state ────────────────────────────────────────────────────

class _EmptyScanState extends StatelessWidget {
  const _EmptyScanState({required this.isScanning});

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isScanning
                  ? Icons.bluetooth_searching_rounded
                  : Icons.bluetooth_disabled_rounded,
              size: 56,
              color: AgriColors.inkSoft,
            ),
            SizedBox(height: 16.h),
            Text(
              isScanning
                  ? 'Mencari perangkat...'
                  : 'Tidak ada perangkat ditemukan',
              style: AgriTypography.textTheme.titleMedium!
                  .copyWith(color: AgriColors.inkSoft),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              isScanning
                  ? 'Pastikan ESP32 menyala dan Bluetooth aktif.'
                  : 'Ketuk "Scan Ulang" untuk mencoba lagi.',
              style: AgriTypography.textTheme.bodySmall!
                  .copyWith(color: AgriColors.inkSoft),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Device list tile ─────────────────────────────────────────────────────────

class _DeviceListTile extends StatelessWidget {
  const _DeviceListTile({required this.device, required this.onTap});

  final BleDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rssiPercent = ((device.rssi + 100).clamp(0, 70) / 70.0);
    final signalIcon = rssiPercent > 0.6
        ? Icons.signal_cellular_alt_rounded
        : rssiPercent > 0.3
            ? Icons.signal_cellular_alt_2_bar_rounded
            : Icons.signal_cellular_alt_1_bar_rounded;
    final signalColor = rssiPercent > 0.6
        ? AgriColors.lime
        : rssiPercent > 0.3
            ? AgriColors.statusPerencanaanText
            : AgriColors.error;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AgriColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AgriColors.border),
          ),
          child: Row(
            children: [
              // Bluetooth icon badge
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0x1A1E2823),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bluetooth_rounded,
                  size: 22,
                  color: AgriColors.forest,
                ),
              ),
              SizedBox(width: 14.w),

              // Device info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: AgriTypography.textTheme.titleSmall!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      device.id,
                      style: AgriTypography.textTheme.bodySmall!
                          .copyWith(color: AgriColors.inkSoft),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),

              // Signal strength
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(signalIcon, size: 20, color: signalColor),
                  SizedBox(height: 2.h),
                  Text(
                    '${device.rssi} dBm',
                    style: AgriTypography.textTheme.labelSmall!
                        .copyWith(color: AgriColors.inkSoft),
                  ),
                ],
              ),
              SizedBox(width: 8.w),

              Icon(Icons.chevron_right_rounded,
                  size: 20, color: AgriColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
