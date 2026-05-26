import 'dart:async';

import 'package:agri_core/agri_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:feature_scan/feature_scan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBleService extends Mock implements BleService {}

class _MockLocationService extends Mock implements LocationService {}

void main() {
  group('ScanBloc', () {
    late _MockBleService bleService;
    late _MockLocationService locationService;
    late StreamController<BleConnectionState> connectionStateController;
    late StreamController<List<BleDevice>> scanResultsController;

    const connectedDevice = BleDevice(
      id: 'device-1',
      name: 'AgriSensor',
      rssi: -48,
    );

    setUp(() {
      bleService = _MockBleService();
      locationService = _MockLocationService();
      connectionStateController =
          StreamController<BleConnectionState>.broadcast();
      scanResultsController = StreamController<List<BleDevice>>.broadcast();

      when(() => bleService.connectionState)
          .thenAnswer((_) => connectionStateController.stream);
      when(() => bleService.scanResults)
          .thenAnswer((_) => scanResultsController.stream);
      when(() => bleService.currentConnectionState)
          .thenReturn(BleConnectionState.disconnected);
      when(() => bleService.currentConnectedDevice).thenReturn(null);
        when(() => bleService.lastKnownConnectedDevice).thenReturn(null);
    });

    tearDown(() async {
      await connectionStateController.close();
      await scanResultsController.close();
    });

    blocTest<ScanBloc, ScanState>(
      'restores the existing BLE connection during initialization',
      setUp: () {
        when(() => bleService.currentConnectionState)
            .thenReturn(BleConnectionState.connected);
        when(() => bleService.currentConnectedDevice)
            .thenReturn(connectedDevice);
        when(() => bleService.lastKnownConnectedDevice)
            .thenReturn(connectedDevice);
      },
      build: () => ScanBloc(
        bleService: bleService,
        locationService: locationService,
      ),
      act: (bloc) => bloc.add(const ScanInitialized(
        prefilledLahanId: 7,
        prefilledOwner: 'Pak Budi',
        prefilledArea: '2 Ha',
        prefilledLocation: 'Subang',
      )),
      expect: () => const [
        ScanState(
          lahanId: 7,
          owner: 'Pak Budi',
          area: '2 Ha',
          location: 'Subang',
          bleStatus: ScanBleStatus.connected,
          isRescan: true,
          connectedDevice: connectedDevice,
        ),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'restores the last known device when BLE reports connected before the snapshot is hydrated',
      setUp: () {
        when(() => bleService.currentConnectionState)
            .thenReturn(BleConnectionState.connected);
        when(() => bleService.currentConnectedDevice).thenReturn(null);
        when(() => bleService.lastKnownConnectedDevice)
            .thenReturn(connectedDevice);
      },
      build: () => ScanBloc(
        bleService: bleService,
        locationService: locationService,
      ),
      act: (bloc) => bloc.add(const ScanInitialized()),
      expect: () => const [
        ScanState(
          bleStatus: ScanBleStatus.connected,
          connectedDevice: connectedDevice,
        ),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'clears the remembered device when the hardware disconnects',
      setUp: () {
        when(() => bleService.currentConnectionState)
            .thenReturn(BleConnectionState.connected);
        when(() => bleService.currentConnectedDevice)
            .thenReturn(connectedDevice);
        when(() => bleService.lastKnownConnectedDevice)
            .thenReturn(connectedDevice);
      },
      build: () => ScanBloc(
        bleService: bleService,
        locationService: locationService,
      ),
      act: (bloc) async {
        bloc.add(const ScanInitialized());
        await Future<void>.delayed(Duration.zero);
        connectionStateController.add(BleConnectionState.disconnected);
      },
      expect: () => const [
        ScanState(
          bleStatus: ScanBleStatus.connected,
          connectedDevice: connectedDevice,
        ),
        ScanState(
          bleStatus: ScanBleStatus.disconnected,
        ),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'hydrates the device when BLE reconnects after the page is open',
      setUp: () {
        when(() => bleService.currentConnectedDevice)
            .thenReturn(connectedDevice);
        when(() => bleService.lastKnownConnectedDevice)
            .thenReturn(connectedDevice);
      },
      build: () => ScanBloc(
        bleService: bleService,
        locationService: locationService,
      ),
      act: (bloc) =>
          connectionStateController.add(BleConnectionState.connected),
      expect: () => const [
        ScanState(
          bleStatus: ScanBleStatus.connected,
          connectedDevice: connectedDevice,
        ),
      ],
    );
  });
}
