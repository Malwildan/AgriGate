// Scan BLoC — manages BLE scan, device selection, GPS capture, and sensor reading.

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agri_core/agri_core.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

sealed class ScanEvent extends Equatable {
  const ScanEvent();
  @override
  List<Object?> get props => [];
}

/// Initialize the scan screen, optionally pre-filling fields for a rescan.
class ScanInitialized extends ScanEvent {
  const ScanInitialized({
    this.prefilledLahanId,
    this.prefilledOwner = '',
    this.prefilledArea = '',
    this.prefilledLocation = '',
  });

  final int? prefilledLahanId;
  final String prefilledOwner;
  final String prefilledArea;
  final String prefilledLocation;

  @override
  List<Object?> get props =>
      [prefilledLahanId, prefilledOwner, prefilledArea, prefilledLocation];
}

class ScanOwnerChanged extends ScanEvent {
  const ScanOwnerChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class ScanAreaChanged extends ScanEvent {
  const ScanAreaChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class ScanLocationChanged extends ScanEvent {
  const ScanLocationChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class ScanGpsRequested extends ScanEvent {
  const ScanGpsRequested();
}

class ScanGpsReset extends ScanEvent {
  const ScanGpsReset();
}

class ScanBleStartScanRequested extends ScanEvent {
  const ScanBleStartScanRequested();
}

class ScanBleStopScanRequested extends ScanEvent {
  const ScanBleStopScanRequested();
}

class ScanBleDeviceSelected extends ScanEvent {
  const ScanBleDeviceSelected(this.device);
  final BleDevice device;
  @override
  List<Object?> get props => [device];
}

class ScanDisconnectRequested extends ScanEvent {
  const ScanDisconnectRequested();
}

class ScanTakeDataRequested extends ScanEvent {
  const ScanTakeDataRequested();
}

// ─── States ───────────────────────────────────────────────────────────────────

enum ScanBleStatus { disconnected, scanning, connecting, connected, error }

class ScanState extends Equatable {
  const ScanState({
    this.lahanId,
    this.owner = '',
    this.area = '',
    this.location = '',
    this.bleStatus = ScanBleStatus.disconnected,
    this.bleError,
    this.isRescan = false,
    this.isCapturingGps = false,
    this.gpsError,
    this.isTakingData = false,
    this.capturedData,
    this.scanError,
    this.discoveredDevices = const [],
    this.connectedDevice,
  });

  final int? lahanId;
  final String owner;
  final String area;
  final String location;
  final ScanBleStatus bleStatus;
  final String? bleError;
  final bool isRescan;
  final bool isCapturingGps;
  final String? gpsError;
  final bool isTakingData;
  final ScanData? capturedData;
  final String? scanError;
  final List<BleDevice> discoveredDevices;
  final BleDevice? connectedDevice;

  bool get isConnected => bleStatus == ScanBleStatus.connected;
  bool get isScanning => bleStatus == ScanBleStatus.scanning;
  bool get canScan => isConnected && !isTakingData;

  ScanState copyWith({
    int? lahanId,
    String? owner,
    String? area,
    String? location,
    ScanBleStatus? bleStatus,
    String? bleError,
    bool? isRescan,
    bool? isCapturingGps,
    String? gpsError,
    bool? isTakingData,
    ScanData? capturedData,
    String? scanError,
    List<BleDevice>? discoveredDevices,
    BleDevice? connectedDevice,
    bool clearBleError = false,
    bool clearGpsError = false,
    bool clearScanError = false,
    bool clearCapturedData = false,
    bool clearConnectedDevice = false,
  }) {
    return ScanState(
      lahanId: lahanId ?? this.lahanId,
      owner: owner ?? this.owner,
      area: area ?? this.area,
      location: location ?? this.location,
      bleStatus: bleStatus ?? this.bleStatus,
      bleError: clearBleError ? null : (bleError ?? this.bleError),
      isRescan: isRescan ?? this.isRescan,
      isCapturingGps: isCapturingGps ?? this.isCapturingGps,
      gpsError: clearGpsError ? null : (gpsError ?? this.gpsError),
      isTakingData: isTakingData ?? this.isTakingData,
      capturedData:
          clearCapturedData ? null : (capturedData ?? this.capturedData),
      scanError: clearScanError ? null : (scanError ?? this.scanError),
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedDevice: clearConnectedDevice
          ? null
          : (connectedDevice ?? this.connectedDevice),
    );
  }

  @override
  List<Object?> get props => [
        lahanId, owner, area, location, bleStatus, bleError,
        isRescan, isCapturingGps, gpsError,
        isTakingData, capturedData, scanError,
        discoveredDevices, connectedDevice,
      ];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  ScanBloc({
    required BleService bleService,
    required LocationService locationService,
  })  : _bleService = bleService,
        _locationService = locationService,
        super(const ScanState()) {
    on<ScanInitialized>(_onInitialized);
    on<ScanOwnerChanged>(_onOwnerChanged);
    on<ScanAreaChanged>(_onAreaChanged);
    on<ScanLocationChanged>(_onLocationChanged);
    on<ScanGpsRequested>(_onGpsRequested);
    on<ScanGpsReset>(_onGpsReset);
    on<ScanBleStartScanRequested>(_onStartScanRequested);
    on<ScanBleStopScanRequested>(_onStopScanRequested);
    on<ScanBleDeviceSelected>(_onDeviceSelected);
    on<ScanDisconnectRequested>(_onDisconnectRequested);
    on<ScanTakeDataRequested>(_onTakeDataRequested);
    on<_BleStateChanged>(_onBleStateChanged);
    on<_ScanResultsUpdated>(_onScanResultsUpdated);

    _bleSubscription = _bleService.connectionState.listen((connectionState) {
      final bleStatus = switch (connectionState) {
        BleConnectionState.connected => ScanBleStatus.connected,
        BleConnectionState.connecting => ScanBleStatus.connecting,
        BleConnectionState.disconnecting ||
        BleConnectionState.disconnected => ScanBleStatus.disconnected,
      };
      if (!isClosed) add(_BleStateChanged(bleStatus));
    });

    _scanResultsSubscription =
        _bleService.scanResults.listen((devices) {
      if (!isClosed) add(_ScanResultsUpdated(devices));
    });
  }

  final BleService _bleService;
  final LocationService _locationService;
  StreamSubscription<BleConnectionState>? _bleSubscription;
  StreamSubscription<List<BleDevice>>? _scanResultsSubscription;

  @override
  Future<void> close() {
    _bleSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    return super.close();
  }

  void _onInitialized(ScanInitialized event, Emitter<ScanState> emit) {
    emit(state.copyWith(
      lahanId: event.prefilledLahanId,
      owner: event.prefilledOwner,
      area: event.prefilledArea,
      location: event.prefilledLocation,
      isRescan: event.prefilledLahanId != null,
      bleStatus: ScanBleStatus.disconnected,
      discoveredDevices: [],
      clearBleError: true,
      clearCapturedData: true,
      clearConnectedDevice: true,
    ));
  }

  void _onOwnerChanged(ScanOwnerChanged event, Emitter<ScanState> emit) =>
      emit(state.copyWith(owner: event.value));

  void _onAreaChanged(ScanAreaChanged event, Emitter<ScanState> emit) =>
      emit(state.copyWith(area: event.value));

  void _onLocationChanged(ScanLocationChanged event, Emitter<ScanState> emit) =>
      emit(state.copyWith(location: event.value));

  Future<void> _onGpsRequested(
    ScanGpsRequested event,
    Emitter<ScanState> emit,
  ) async {
    emit(state.copyWith(isCapturingGps: true, clearGpsError: true));
    final granted = await _locationService.requestPermission();
    if (!granted) {
      emit(state.copyWith(
        isCapturingGps: false,
        gpsError: 'Izin lokasi ditolak. Aktifkan di pengaturan.',
      ));
      return;
    }
    final result = await _locationService.getCurrentLocationString();
    result.fold(
      (failure) => emit(state.copyWith(
        isCapturingGps: false,
        gpsError: failure.message,
      )),
      (location) => emit(state.copyWith(
        isCapturingGps: false,
        location: location,
        clearGpsError: true,
      )),
    );
  }

  void _onGpsReset(ScanGpsReset event, Emitter<ScanState> emit) =>
      emit(state.copyWith(location: '', clearGpsError: true));

  Future<void> _onStartScanRequested(
    ScanBleStartScanRequested event,
    Emitter<ScanState> emit,
  ) async {
    emit(state.copyWith(
      bleStatus: ScanBleStatus.scanning,
      discoveredDevices: [],
      clearBleError: true,
      clearConnectedDevice: true,
    ));
    await _bleService.startScan();
  }

  Future<void> _onStopScanRequested(
    ScanBleStopScanRequested event,
    Emitter<ScanState> emit,
  ) async {
    await _bleService.stopScan();
    emit(state.copyWith(bleStatus: ScanBleStatus.disconnected));
  }

  Future<void> _onDeviceSelected(
    ScanBleDeviceSelected event,
    Emitter<ScanState> emit,
  ) async {
    emit(state.copyWith(bleStatus: ScanBleStatus.connecting, clearBleError: true));
    final result = await _bleService.connectToDevice(event.device.id);
    result.fold(
      (failure) => emit(state.copyWith(
        bleStatus: ScanBleStatus.error,
        bleError: failure.message,
      )),
      (_) => emit(state.copyWith(
        bleStatus: ScanBleStatus.connected,
        connectedDevice: event.device,
      )),
    );
  }

  Future<void> _onDisconnectRequested(
    ScanDisconnectRequested event,
    Emitter<ScanState> emit,
  ) async {
    await _bleService.disconnect();
    emit(state.copyWith(
      bleStatus: ScanBleStatus.disconnected,
      clearConnectedDevice: true,
      discoveredDevices: [],
    ));
  }

  Future<void> _onTakeDataRequested(
    ScanTakeDataRequested event,
    Emitter<ScanState> emit,
  ) async {
    if (!state.isConnected) return;
    emit(state.copyWith(isTakingData: true, clearScanError: true));
    final result = await _bleService.readSensorData();
    result.fold(
      (failure) => emit(state.copyWith(
        isTakingData: false,
        scanError: failure.message,
      )),
      (data) => emit(state.copyWith(
        isTakingData: false,
        capturedData: data,
      )),
    );
  }

  void _onBleStateChanged(_BleStateChanged event, Emitter<ScanState> emit) {
    // Only process hardware-driven state changes when not already in scanning mode
    if (state.bleStatus == ScanBleStatus.scanning &&
        event.status == ScanBleStatus.disconnected) return;
    emit(state.copyWith(bleStatus: event.status));
  }

  void _onScanResultsUpdated(
      _ScanResultsUpdated event, Emitter<ScanState> emit) {
    emit(state.copyWith(discoveredDevices: event.devices));
  }
}

// ─── Internal events ──────────────────────────────────────────────────────────

class _BleStateChanged extends ScanEvent {
  const _BleStateChanged(this.status);
  final ScanBleStatus status;
  @override
  List<Object?> get props => [status];
}

class _ScanResultsUpdated extends ScanEvent {
  const _ScanResultsUpdated(this.devices);
  final List<BleDevice> devices;
  @override
  List<Object?> get props => [devices];
}
