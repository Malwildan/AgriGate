
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:agri_core/agri_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
const _kServiceUuid = '12345678-1234-1234-1234-1234567890ab';
const _kSensorCharUuid = 'abcd1234-5678-1234-5678-abcdef123456';
const _kScanDuration = Duration(seconds: 10);

const _kLastDeviceIdKey = 'ble.last_device_id';
const _kLastDeviceNameKey = 'ble.last_device_name';
const _kLastDeviceRssiKey = 'ble.last_device_rssi';

class BleServiceImpl implements BleService {
  BleServiceImpl()
      : _connectionStateController =
            StreamController<BleConnectionState>.broadcast(),
        _scanResultsController = StreamController<List<BleDevice>>.broadcast();

  BluetoothDevice? _device;
  final StreamController<BleConnectionState> _connectionStateController;
  final StreamController<List<BleDevice>> _scanResultsController;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _devConnSub;
  BleConnectionState _currentConnectionState = BleConnectionState.disconnected;
  BleDevice? _connectedDevice;
  BleDevice? _rememberedDevice;
  Future<void>? _initializeFuture;
  final Map<String, BleDevice> _foundDevices = {};

  void _emitConnection(BleConnectionState state) {
    _currentConnectionState = state;
    _connectionStateController.add(state);
  }

  @override
  Stream<BleConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Stream<List<BleDevice>> get scanResults => _scanResultsController.stream;

  @override
  BleConnectionState get currentConnectionState => _currentConnectionState;

  @override
  BleDevice? get currentConnectedDevice => _connectedDevice;

  @override
  BleDevice? get lastKnownConnectedDevice => _connectedDevice ?? _rememberedDevice;

  @override
  Future<void> initialize() {
    return _initializeFuture ??= _initializeStoredConnection();
  }

  Future<void> _initializeStoredConnection() async {
    _rememberedDevice = await _loadRememberedDevice();
    final rememberedDevice = _rememberedDevice;
    if (rememberedDevice == null) return;

    await connectToDevice(rememberedDevice.id);
  }

  Future<BleDevice?> _loadRememberedDevice() async {
    final preferences = await SharedPreferences.getInstance();
    final deviceId = preferences.getString(_kLastDeviceIdKey);
    if (deviceId == null || deviceId.isEmpty) return null;

    final rememberedName =
        _sanitizeDeviceName(preferences.getString(_kLastDeviceNameKey), deviceId);

    return BleDevice(
      id: deviceId,
      name: rememberedName,
      rssi: preferences.getInt(_kLastDeviceRssiKey) ?? 0,
    );
  }

  Future<void> _rememberDevice(BleDevice device) async {
    final rememberedDevice = BleDevice(
      id: device.id,
      name: _sanitizeDeviceName(device.name, device.id),
      rssi: device.rssi,
    );
    _rememberedDevice = rememberedDevice;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_kLastDeviceIdKey, rememberedDevice.id);
    await preferences.setString(
      _kLastDeviceNameKey,
      rememberedDevice.name,
    );
    await preferences.setInt(_kLastDeviceRssiKey, rememberedDevice.rssi);
  }

  Future<void> _clearRememberedDevice() async {
    _rememberedDevice = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_kLastDeviceIdKey);
    await preferences.remove(_kLastDeviceNameKey);
    await preferences.remove(_kLastDeviceRssiKey);
  }

  String _sanitizeDeviceName(String? deviceName, String deviceId) {
    final trimmedName = deviceName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }

    return deviceId;
  }

  BleDevice _resolveDeviceSnapshot(String deviceId, BluetoothDevice device) {
    final scannedDevice = _foundDevices[deviceId];
    if (scannedDevice != null) return scannedDevice;

    final rememberedDevice = _rememberedDevice;
    if (rememberedDevice != null && rememberedDevice.id == deviceId) {
      return rememberedDevice;
    }

    final deviceName = _sanitizeDeviceName(device.platformName, deviceId);
    return BleDevice(
      id: deviceId,
      name: deviceName,
      rssi: 0,
    );
  }

  void _bindConnectionSubscription() {
    final currentDevice = _device;
    if (currentDevice == null) return;

    _devConnSub?.cancel();
    _devConnSub = currentDevice.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _device = null;
        _connectedDevice = null;
        _emitConnection(BleConnectionState.disconnected);
      }
    });
  }

  bool _isAlreadyConnectedError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('already') && message.contains('connected');
  }

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

  @override
  Future<Either<BleFailure, void>> connectToDevice(String deviceId) async {
    if (_currentConnectionState == BleConnectionState.connected &&
        _connectedDevice?.id == deviceId) {
      await stopScan();
      _emitConnection(BleConnectionState.connected);
      final connectedDevice = _connectedDevice;
      if (connectedDevice != null) {
        await _rememberDevice(connectedDevice);
      }
      return const Right(null);
    }

    _emitConnection(BleConnectionState.connecting);
    try {
      await stopScan();

      final fbpDevice = BluetoothDevice.fromId(deviceId);
      _device = fbpDevice;
      _connectedDevice = _resolveDeviceSnapshot(deviceId, fbpDevice);

      await _device!.connect(autoConnect: false);

      _bindConnectionSubscription();

      await _rememberDevice(_connectedDevice!);
      _emitConnection(BleConnectionState.connected);
      return const Right(null);
    } catch (e) {
      if (_isAlreadyConnectedError(e)) {
        _bindConnectionSubscription();
        final connectedDevice = _connectedDevice;
        if (connectedDevice != null) {
          await _rememberDevice(connectedDevice);
        }
        _emitConnection(BleConnectionState.connected);
        return const Right(null);
      }

      _device = null;
      _connectedDevice = null;
      _emitConnection(BleConnectionState.disconnected);
      return Left(BleFailure(e.toString()));
    }
  }

  @override
  Future<void> disconnect() async {
    _emitConnection(BleConnectionState.disconnecting);
    await _clearRememberedDevice();
    await _devConnSub?.cancel();
    _devConnSub = null;
    await _device?.disconnect();
    _device = null;
    _connectedDevice = null;
    _emitConnection(BleConnectionState.disconnected);
  }

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
