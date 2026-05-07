
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import '../bloc/scan_bloc.dart';

enum _SheetPhase { scanning, connecting, error }

class BleDevicePickerSheet extends StatefulWidget {
  const BleDevicePickerSheet._();

  static Future<void> show(
    BuildContext context, {
    ScanBloc Function()? createBloc,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        if (createBloc != null) {
          return BlocProvider(
            create: (_) => createBloc()..add(const ScanInitialized()),
            child: const BleDevicePickerSheet._(),
          );
        }

        return BlocProvider.value(
          value: context.read<ScanBloc>(),
          child: const BleDevicePickerSheet._(),
        );
      },
    );
  }

  @override
  State<BleDevicePickerSheet> createState() => _BleDevicePickerSheetState();
}

class _BleDevicePickerSheetState extends State<BleDevicePickerSheet> {
  late final ScanBloc _bloc;
  _SheetPhase _phase = _SheetPhase.scanning;
  BleDevice? _selectedDevice;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ScanBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _bloc.currentBleConnectedDevice != null) return;
      _bloc.add(const ScanBleStartScanRequested());
    });
  }

  @override
  void dispose() {
    if (!_bloc.isClosed && _bloc.state.bleStatus == ScanBleStatus.scanning) {
      _bloc.add(const ScanBleStopScanRequested());
    }
    super.dispose();
  }

  void _onDeviceTapped(BleDevice device) {
    _bloc.add(const ScanBleStopScanRequested());
    _bloc.add(ScanBleDeviceSelected(device));
    setState(() {
      _phase = _SheetPhase.connecting;
      _selectedDevice = device;
      _errorMessage = null;
    });
  }

  void _onCancelConnecting() {
    _bloc.add(const ScanDisconnectRequested());
    _bloc.add(const ScanBleStartScanRequested());
    setState(() {
      _phase = _SheetPhase.scanning;
      _selectedDevice = null;
      _errorMessage = null;
    });
  }

  void _onRetry() {
    final device = _selectedDevice;
    if (device == null) return;
    _bloc.add(ScanBleDeviceSelected(device));
    setState(() {
      _phase = _SheetPhase.connecting;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanBloc, ScanState>(
      listener: (context, state) {
        if (_phase != _SheetPhase.connecting) return;
        if (state.bleStatus == ScanBleStatus.connected) {
          Navigator.of(context).pop();
        } else if (state.bleStatus == ScanBleStatus.error) {
          setState(() {
            _phase = _SheetPhase.error;
            _errorMessage = state.bleError;
          });
        }
      },
      child: DraggableScrollableSheet(
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: switch (_phase) {
                _SheetPhase.scanning => _ScanningBody(
                    key: const ValueKey('scanning'),
                    scrollController: scrollController,
                    onDeviceTapped: _onDeviceTapped,
                  ),
                _SheetPhase.connecting => _ConnectingBody(
                    key: const ValueKey('connecting'),
                    device: _selectedDevice,
                    onCancel: _onCancelConnecting,
                  ),
                _SheetPhase.error => _ErrorBody(
                    key: const ValueKey('error'),
                    device: _selectedDevice,
                    message: _errorMessage,
                    onRetry: _onRetry,
                    onClose: () => Navigator.of(context).pop(),
                  ),
              },
            ),
          );
        },
      ),
    );
  }
}

class _ScanningBody extends StatelessWidget {
  const _ScanningBody({
    super.key,
    required this.scrollController,
    required this.onDeviceTapped,
  });

  final ScrollController scrollController;
  final ValueChanged<BleDevice> onDeviceTapped;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanBloc, ScanState>(
      builder: (context, state) {
        final isScanning = state.bleStatus == ScanBleStatus.scanning;
        final devices = state.discoveredDevices;
        final connectedDevice = state.connectedDevice;

        return CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AgriColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Perangkat',
                            style: AgriTypography.textTheme.headlineSmall,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            isScanning
                                ? 'Mencari perangkat Bluetooth di sekitar...'
                                : connectedDevice != null
                                    ? 'Kelola perangkat yang sedang tersambung atau pilih sensor lain.'
                                    : 'Ketuk "Scan Ulang" untuk memperbarui daftar.',
                            style: AgriTypography.textTheme.bodySmall!
                                .copyWith(color: AgriColors.inkSoft),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
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
            ),
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
                color: AgriColors.border,
                indent: 20.w,
                endIndent: 20.w,
              ),
            ),
            if (connectedDevice != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: _ConnectedDevicePanel(
                    device: connectedDevice,
                    isScanning: isScanning,
                    onSwitchDevice: () => context
                        .read<ScanBloc>()
                        .add(const ScanBleStartScanRequested()),
                    onDisconnect: () => context
                        .read<ScanBloc>()
                        .add(const ScanDisconnectRequested()),
                  ),
                ),
              ),
            if (devices.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyScanState(isScanning: isScanning),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final device = devices[index ~/ 2];
                      if (index.isOdd) {
                        return SizedBox(height: 8.h);
                      }

                      return _DeviceListTile(
                        device: device,
                        onTap: () => onDeviceTapped(device),
                      );
                    },
                    childCount: devices.length * 2 - 1,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ConnectedDevicePanel extends StatelessWidget {
  const _ConnectedDevicePanel({
    required this.device,
    required this.isScanning,
    required this.onSwitchDevice,
    required this.onDisconnect,
  });

  final BleDevice device;
  final bool isScanning;
  final VoidCallback onSwitchDevice;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final rssiPercent = ((device.rssi + 100).clamp(0, 70) / 70.0);
    final signalIcon = rssiPercent > 0.6
        ? Icons.signal_cellular_alt_rounded
        : rssiPercent > 0.3
            ? Icons.signal_cellular_alt_2_bar_rounded
            : Icons.signal_cellular_alt_1_bar_rounded;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E2D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AgriColors.forest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bluetooth_connected_rounded,
                  size: 20,
                  color: AgriColors.lime,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perangkat Saat Ini',
                      style: AgriTypography.textTheme.labelMedium!.copyWith(
                        color: AgriColors.inkSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      device.displayName,
                      style: AgriTypography.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'TERHUBUNG',
                  style: AgriTypography.textTheme.labelSmall!.copyWith(
                    color: const Color(0xFF1F5B2B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            device.id,
            style: AgriTypography.textTheme.bodySmall!
                .copyWith(color: AgriColors.inkSoft),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(signalIcon, size: 16, color: AgriColors.forest),
              SizedBox(width: 6.w),
              Text(
                '${device.rssi} dBm',
                style: AgriTypography.textTheme.bodySmall!
                    .copyWith(color: AgriColors.inkSoft),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  isScanning
                      ? 'Sedang memindai perangkat lain di sekitar.'
                      : 'Pilih sensor lain bila ingin mengganti perangkat.',
                  style: AgriTypography.textTheme.bodySmall!
                      .copyWith(color: AgriColors.inkSoft),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSwitchDevice,
                  icon: Icon(
                    isScanning
                        ? Icons.bluetooth_searching_rounded
                        : Icons.sync_alt_rounded,
                    size: 18,
                  ),
                  label: Text(isScanning ? 'Memindai...' : 'Ganti'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AgriColors.border),
                    foregroundColor: AgriColors.forest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDisconnect,
                  icon: const Icon(Icons.bluetooth_disabled_rounded, size: 18),
                  label: const Text('Putuskan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    backgroundColor: AgriColors.forest,
                    foregroundColor: AgriColors.lime,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectingBody extends StatelessWidget {
  const _ConnectingBody({
    super.key,
    this.device,
    required this.onCancel,
  });

  final BleDevice? device;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AgriColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AgriColors.forest),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0x1A1E2823),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bluetooth_searching_rounded,
                  size: 28,
                  color: AgriColors.forest,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'Menghubungkan...',
            style: AgriTypography.textTheme.headlineSmall,
          ),
          if (device != null) ...[
            SizedBox(height: 6.h),
            Text(
              device!.displayName,
              style: AgriTypography.textTheme.bodyMedium!.copyWith(
                color: AgriColors.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            'Harap tunggu, sedang mencoba terhubung ke perangkat.',
            style: AgriTypography.textTheme.bodySmall!
                .copyWith(color: AgriColors.inkMuted),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AgriColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Batal',
                style: AgriTypography.textTheme.titleMedium!.copyWith(
                  color: AgriColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h + bottomPad),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    super.key,
    this.device,
    this.message,
    required this.onRetry,
    required this.onClose,
  });

  final BleDevice? device;
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AgriColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bluetooth_disabled_rounded,
              size: 32,
              color: AgriColors.error,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Gagal Menghubungkan',
            style: AgriTypography.textTheme.headlineSmall,
          ),
          if (device != null) ...[
            SizedBox(height: 4.h),
            Text(
              device!.displayName,
              style: AgriTypography.textTheme.bodyMedium!.copyWith(
                color: AgriColors.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (message != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x14F47878),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message!,
                style: AgriTypography.textTheme.bodySmall!
                    .copyWith(color: AgriColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AgriColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Tutup',
                    style: AgriTypography.textTheme.titleMedium!.copyWith(
                      color: AgriColors.inkSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgriColors.forest,
                    foregroundColor: AgriColors.lime,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Coba Lagi',
                    style: AgriTypography.textTheme.titleMedium!.copyWith(
                      color: AgriColors.lime,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h + bottomPad),
        ],
      ),
    );
  }
}

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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isScanning ? const Color(0x141E2823) : AgriColors.forest,
          borderRadius: BorderRadius.circular(20),
          border:
              isScanning ? Border.all(color: const Color(0x331E2823)) : null,
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
              const Icon(Icons.refresh_rounded,
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AgriColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AgriColors.border),
          ),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.displayName,
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
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: AgriColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
