// BLE service implementation using flutter_blue_plus.
// Scans for BLE devices (AgriGate_BLE ESP32), connects by device ID,
// and subscribes to pH notifications.

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:agri_core/agri_core.dart';

/// Custom service UUID for sensor data (replace with actual ESP32 UUID).
const _kServiceUuid = '12345678-1234-1234-1234-1234567890ab';

/// Characteristic UUID for the pH notify characteristic.
const _kSensorCharUuid = 'abcd1234-5678-1234-5678-abcdef123456';

/// Scan duration for each scan session.
const _kScanDuration = Duration(seconds: 10);

class BleServiceImpl implements BleService {
  BleServiceImpl()
      : _connectionStateController =
            StreamController<BleConnectionState>.broadcast(),
        _scanResultsController =
            StreamController<List<BleDevice>>.broadcast();

  BluetoothDevice? _device;
  final StreamController<BleConnectionState> _connectionStateController;
  final StreamController<List<BleDevice>> _scanResultsController;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _devConnSub;
  final Map<String, BleDevice> _foundDevices = {};

  void _emitConnection(BleConnectionState state) =>
      _connectionStateController.add(state);

  // ── Public streams ─────────────────────────────────────────────────────────

  @override
  Stream<BleConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Stream<List<BleDevice>> get scanResults => _scanResultsController.stream;

  // ── Scanning ───────────────────────────────────────────────────────────────

  @override
  Future<void> startScan() async {
    _foundDevices.clear();
    _scanResultsController.add([]);

    await FlutterBluePlus.stopScan();

    _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final name = r.device.platformName;
        if (name.isEmpty) continue;
        _foundDevices[r.device.remoteId.str] = BleDevice(
          id: r.device.remoteId.str,
          name: name,
          rssi: r.rssi,
        );
      }
      _scanResultsController.add(List.unmodifiable(_foundDevices.values));
    });

    await FlutterBluePlus.startScan(timeout: _kScanDuration);
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSub?.cancel();
    _scanSub = null;
  }

  // ── Connection ─────────────────────────────────────────────────────────────

  @override
  Future<Either<BleFailure, void>> connectToDevice(String deviceId) async {
    _emitConnection(BleConnectionState.connecting);
    try {
      await stopScan();

      final fbpDevice = BluetoothDevice.fromId(deviceId);
      _device = fbpDevice;

      await _device!.connect(autoConnect: false);

      _devConnSub?.cancel();
      _devConnSub = _device!.connectionState.listen((s) {
        if (s == BluetoothConnectionState.disconnected) {
          _emitConnection(BleConnectionState.disconnected);
        }
      });

      _emitConnection(BleConnectionState.connected);
      return const Right(null);
    } catch (e) {
      _emitConnection(BleConnectionState.disconnected);
      return Left(BleFailure(e.toString()));
    }
  }

  @override
  Future<void> disconnect() async {
    _emitConnection(BleConnectionState.disconnecting);
    await _devConnSub?.cancel();
    _devConnSub = null;
    await _device?.disconnect();
    _device = null;
    _emitConnection(BleConnectionState.disconnected);
  }

  // ── Sensor reading ─────────────────────────────────────────────────────────

  @override
  Future<Either<BleFailure, ScanData>> readSensorData() async {
    if (_device == null) {
      return const Left(BleFailure('Tidak terhubung ke perangkat'));
    }
    try {
      final services = await _device!.discoverServices();
      final service = services.firstWhere(
        (s) => s.serviceUuid.toString().toLowerCase() == _kServiceUuid,
        orElse: () => throw BleException('Layanan sensor tidak ditemukan'),
      );

      final characteristic = service.characteristics.firstWhere(
        (c) =>
            c.characteristicUuid.toString().toLowerCase() == _kSensorCharUuid,
        orElse: () =>
            throw BleException('Karakteristik sensor tidak ditemukan'),
      );

      await characteristic.setNotifyValue(true);
      final bytes = await characteristic.onValueReceived.first;
      final payload = String.fromCharCodes(bytes);

      // Protocol: "PH:6.78" — UTF-8 string sent every 2 s via NOTIFY.
      if (!payload.startsWith('PH:')) {
        throw BleException('Format data tidak valid: $payload');
      }

      final ph = double.tryParse(payload.substring(3));
      if (ph == null || ph < 0 || ph > 14) {
        throw BleException('Nilai pH tidak valid: $payload');
      }

      return Right(ScanData(ph: ph, moisture: 0));
    } catch (e) {
      return Left(BleFailure(e.toString()));
    }
  }

}

class BleException implements Exception {
  BleException(this.message);
  final String message;
  @override
  String toString() => message;
}
