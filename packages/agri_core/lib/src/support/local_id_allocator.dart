const maxHiveIntKey = 0xFFFFFFFF;

/// Allocates positive Hive-compatible integer keys without collisions.
class LocalIdAllocator {
  const LocalIdAllocator._();

  static int allocateLahanId(Iterable<int> existingIds, DateTime timestamp) {
    return _allocate(existingIds, timestamp.millisecondsSinceEpoch);
  }

  static int allocateScanRecordId(
    Iterable<int> existingIds,
    DateTime timestamp,
  ) {
    return _allocate(existingIds, timestamp.microsecondsSinceEpoch);
  }

  static int _allocate(Iterable<int> existingIds, int seed) {
    final used = existingIds.toSet();
    var candidate = seed & maxHiveIntKey;
    if (candidate == 0) {
      candidate = 1;
    }

    var guard = 0;
    while (used.contains(candidate)) {
      candidate++;
      if (candidate > maxHiveIntKey) {
        candidate = 1;
      }
      guard++;
      if (guard > maxHiveIntKey) {
        throw StateError('Tidak ada ID lokal yang tersedia.');
      }
    }

    return candidate;
  }
}
