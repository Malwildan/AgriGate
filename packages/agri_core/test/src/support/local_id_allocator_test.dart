import 'package:agri_core/agri_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalIdAllocator', () {
    test('avoids collisions for lahan IDs', () {
      final timestamp = DateTime.utc(2026, 5, 5);
      final maskedSeed = timestamp.millisecondsSinceEpoch & maxHiveIntKey;
      final first = LocalIdAllocator.allocateLahanId(const [], timestamp);
      final second =
          LocalIdAllocator.allocateLahanId([first], timestamp);

      expect(first, maskedSeed);
      expect(second, isNot(first));
      expect(second, first + 1);
    });

    test('allocates unique scan record IDs', () {
      final used = <int>[100, 101];
      final next = LocalIdAllocator.allocateScanRecordId(
        used,
        DateTime.utc(2026, 5, 5, 12, 0, 0, 100),
      );
      expect(used, isNot(contains(next)));
    });
  });
}
