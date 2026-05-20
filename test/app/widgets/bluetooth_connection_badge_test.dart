import 'dart:async';

import 'package:agri_core/agri_core.dart';
import 'package:agri_gate_app/app/di/injection.dart';
import 'package:agri_gate_app/app/widgets/bluetooth_connection_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBleService extends Mock implements BleService {}

class _MockLocationService extends Mock implements LocationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BluetoothConnectionBadge', () {
    late _MockBleService bleService;
    late _MockLocationService locationService;
    late StreamController<BleConnectionState> connectionStateController;
    late StreamController<List<BleDevice>> scanResultsController;

    const connectedDevice = BleDevice(
      id: 'device-1',
      name: 'AgriSensor',
      rssi: -48,
    );

    const unnamedConnectedDevice = BleDevice(
      id: 'device-blank',
      name: '   ',
      rssi: -52,
    );

    setUp(() async {
      await getIt.reset();

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
      when(() => bleService.initialize()).thenAnswer((_) async {});
      when(() => bleService.startScan()).thenAnswer((_) async {});
      when(() => bleService.stopScan()).thenAnswer((_) async {});
      when(() => bleService.connectToDevice(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => bleService.disconnect()).thenAnswer((_) async {});
      when(() => bleService.readSensorData())
          .thenAnswer((_) async => const Left(BleFailure('unused')));
      when(() => bleService.dispose()).thenAnswer((_) async {});

      getIt
        ..registerSingleton<BleService>(bleService)
        ..registerSingleton<LocationService>(locationService);
    });

    tearDown(() async {
      await connectionStateController.close();
      await scanResultsController.close();
      await getIt.reset();
    });

    testWidgets('opens the BLE picker sheet when tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: BluetoothConnectionBadge(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('NOT CONNECTED'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Pilih Perangkat'), findsOneWidget);
      verify(() => bleService.startScan()).called(1);
    });

    testWidgets('shows connected device actions and handles switch/disconnect',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => bleService.currentConnectionState)
          .thenReturn(BleConnectionState.connected);
      when(() => bleService.currentConnectedDevice).thenReturn(connectedDevice);
        when(() => bleService.lastKnownConnectedDevice)
          .thenReturn(connectedDevice);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: BluetoothConnectionBadge(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('CONNECTED'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Perangkat Saat Ini'), findsOneWidget);
      expect(find.text('Ganti'), findsOneWidget);
      expect(find.text('Putuskan'), findsOneWidget);
      expect(find.text('AgriSensor'), findsOneWidget);
      verifyNever(() => bleService.startScan());

      await tester.tap(find.text('Ganti'));
      await tester.pump();
      verify(() => bleService.startScan()).called(1);

      await tester.tap(find.text('Putuskan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      verify(() => bleService.disconnect()).called(1);
    });

    testWidgets('does not overflow on compact height when no devices are found',
        (tester) async {
      tester.view.physicalSize = const Size(393, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => bleService.currentConnectionState)
          .thenReturn(BleConnectionState.connected);
      when(() => bleService.currentConnectedDevice).thenReturn(connectedDevice);
        when(() => bleService.lastKnownConnectedDevice)
          .thenReturn(connectedDevice);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: BluetoothConnectionBadge(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('CONNECTED'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Perangkat Saat Ini'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('falls back to the device id when the connected name is blank',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => bleService.currentConnectionState)
          .thenReturn(BleConnectionState.connected);
      when(() => bleService.currentConnectedDevice)
          .thenReturn(unnamedConnectedDevice);
        when(() => bleService.lastKnownConnectedDevice)
          .thenReturn(unnamedConnectedDevice);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: BluetoothConnectionBadge(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('CONNECTED'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Perangkat Saat Ini'), findsOneWidget);
      expect(find.text('device-blank'), findsNWidgets(2));
    });

    testWidgets(
        'shows the last known device when the badge is connected before the live snapshot is hydrated',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => bleService.currentConnectionState)
          .thenReturn(BleConnectionState.connected);
      when(() => bleService.currentConnectedDevice).thenReturn(null);
      when(() => bleService.lastKnownConnectedDevice)
          .thenReturn(connectedDevice);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: BluetoothConnectionBadge(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('CONNECTED'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Perangkat Saat Ini'), findsOneWidget);
      expect(find.text('AgriSensor'), findsOneWidget);
      verifyNever(() => bleService.startScan());
    });
  });
}
