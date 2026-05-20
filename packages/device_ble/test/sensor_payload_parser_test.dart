import 'package:agri_core/agri_core.dart';
import 'package:device_ble/device_ble.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SensorPayloadParser', () {
    test('parses legacy PH-only payload with zero moisture', () {
      final result = SensorPayloadParser.parse('PH:6.5');
      expect(result.isRight, isTrue);
      expect(result.right.ph, 6.5);
      expect(result.right.moisture, 0);
    });

    test('parses PH and MOISTURE segments', () {
      final result = SensorPayloadParser.parse('PH:6.5;MOISTURE:45');
      expect(result.isRight, isTrue);
      expect(result.right.ph, 6.5);
      expect(result.right.moisture, 45);
    });

    test('rejects invalid pH values', () {
      final result = SensorPayloadParser.parse('PH:99');
      expect(result.isLeft, isTrue);
    });
  });
}
