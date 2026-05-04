// Scan Page — form inputs, BLE device card, GPS capture, sticky scan CTA.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import '../bloc/scan_bloc.dart';
import '../widgets/device_connection_card.dart';
import '../widgets/scan_form_card.dart';

typedef OnScanComplete = void Function(
  ScanData scanData, {
  required String ownerName,
  required String lahanArea,
  required String location,
});

class ScanPage extends StatefulWidget {
  const ScanPage({
    super.key,
    this.prefilledLahanId,
    this.prefilledOwner = '',
    this.prefilledArea = '',
    this.prefilledLocation = '',
    required this.onScanComplete,
    required this.onBack,
  });

  final int? prefilledLahanId;
  final String prefilledOwner;
  final String prefilledArea;
  final String prefilledLocation;
  final OnScanComplete onScanComplete;
  final VoidCallback onBack;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  void initState() {
    super.initState();
    context.read<ScanBloc>().add(ScanInitialized(
          prefilledLahanId: widget.prefilledLahanId,
          prefilledOwner: widget.prefilledOwner,
          prefilledArea: widget.prefilledArea,
          prefilledLocation: widget.prefilledLocation,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanBloc, ScanState>(
      listenWhen: (prev, curr) =>
          prev.capturedData != curr.capturedData &&
          curr.capturedData != null,
      listener: (context, state) {
        if (state.capturedData != null) {
          widget.onScanComplete(
            state.capturedData!,
            ownerName: state.owner,
            lahanArea: state.area,
            location: state.location,
          );
        }
      },
      builder: (context, state) {
        final isRescan = state.isRescan;
        return Scaffold(
          backgroundColor: AgriColors.background,
          appBar: AgriAppBar(
            backLabel: isRescan ? (state.owner.isNotEmpty ? state.owner : 'Lahan') : 'Lahan',
            onBack: widget.onBack,
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRescan ? 'Scan Ulang Lahan' : 'Tambah Lahan Baru',
                        style: AgriTypography.textTheme.displaySmall,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        isRescan
                            ? 'Hubungkan sensor untuk mengambil data tanah terbaru.'
                            : 'Isi info lahan, lalu hubungkan sensor.',
                        style: AgriTypography.textTheme.bodyMedium!
                            .copyWith(color: AgriColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverToBoxAdapter(
                  child: ScanFormCard(
                    owner: state.owner,
                    area: state.area,
                    location: state.location,
                    isCapturingGps: state.isCapturingGps,
                    gpsError: state.gpsError,
                    onOwnerChanged: (v) =>
                        context.read<ScanBloc>().add(ScanOwnerChanged(v)),
                    onAreaChanged: (v) =>
                        context.read<ScanBloc>().add(ScanAreaChanged(v)),
                    onLocationChanged: (v) =>
                        context.read<ScanBloc>().add(ScanLocationChanged(v)),
                    onGpsRequested: () =>
                        context.read<ScanBloc>().add(const ScanGpsRequested()),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverToBoxAdapter(
                  child: DeviceConnectionCard(
                    bleStatus: state.bleStatus,
                    connectedDevice: state.connectedDevice,
                    bleError: state.bleError,
                    onDisconnect: () =>
                        context.read<ScanBloc>().add(const ScanDisconnectRequested()),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 140.h)),
            ],
          ),
          bottomNavigationBar: StickyCtaWrapper(
            child: AgriPrimaryButton(
              label: state.isConnected
                  ? 'Ambil Data Tanah'
                  : 'Hubungkan Perangkat Dulu',
              icon: state.isConnected
                  ? Icons.document_scanner_rounded
                  : Icons.bluetooth_disabled_rounded,
              enabled: state.canScan,
              loading: state.isTakingData,
              onPressed: () =>
                  context.read<ScanBloc>().add(const ScanTakeDataRequested()),
            ),
          ),
        );
      },
    );
  }
}
