import 'dart:io';

import 'package:agri_core/agri_core.dart';
import 'package:agri_core/src/data/models/supabase_lahan_dto.dart';
import 'package:agri_core/src/data/models/supabase_scan_record_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _FakeUserSessionGate implements UserSessionGate {
  const _FakeUserSessionGate(this.userId);

  final String userId;

  @override
  Future<Either<Failure, String>> requireUserId() async => Right(userId);
}

class _FakeRemoteDataSource implements SupabaseLahanRemoteDataSource {
  SupabaseRemoteSnapshot snapshot =
      const SupabaseRemoteSnapshot(lahan: [], scanRecords: []);
  final List<SupabaseLahanDto> upsertedLahan = [];
  final List<SupabaseScanRecordDto> upsertedScanRecords = [];

  @override
  Future<SupabaseRemoteSnapshot> pullAll({required String userId}) async {
    return snapshot;
  }

  @override
  Future<void> upsertLahan(SupabaseLahanDto lahan) async {
    upsertedLahan.add(lahan);
    snapshot = SupabaseRemoteSnapshot(
      lahan: [
        ...snapshot.lahan.where((entry) => entry.id != lahan.id),
        lahan,
      ],
      scanRecords: snapshot.scanRecords,
    );
  }

  @override
  Future<void> upsertScanRecord(SupabaseScanRecordDto record) async {
    upsertedScanRecords.add(record);
    snapshot = SupabaseRemoteSnapshot(
      lahan: snapshot.lahan,
      scanRecords: [
        ...snapshot.scanRecords.where((entry) => entry.id != record.id),
        record,
      ],
    );
  }
}

void main() {
  group('OfflineFirstLahanRepository', () {
    late Directory tempDirectory;
    late _FakeRemoteDataSource remoteDataSource;
    late OfflineFirstLahanRepository repository;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('agri_core_test');
      Hive.init(tempDirectory.path);
      remoteDataSource = _FakeRemoteDataSource();
      repository = await OfflineFirstLahanRepository.open(
        enableDemoSeed: false,
        remoteDataSource: remoteDataSource,
        authService: const _FakeUserSessionGate('user-1'),
      );
    });

    tearDown(() async {
      await Hive.close();
      await tempDirectory.delete(recursive: true);
    });

    test('replays queued operations and merges remote rows into local cache', () async {
      remoteDataSource.snapshot = SupabaseRemoteSnapshot(
        lahan: [
          SupabaseLahanDto(
            id: 999,
            owner: 'Bu Sari',
            area: 'Lahan B',
            location: '-6.91, 107.61',
            status: LahanStatus.aktif.label,
            userId: 'user-1',
            createdAt: DateTime.utc(2026, 5, 1),
            updatedAt: DateTime.utc(2026, 5, 2),
          ),
        ],
        scanRecords: const [],
      );

      final localLahan = Lahan(
        id: 100,
        owner: 'Pak Budi',
        area: 'Lahan A',
        location: '-7.54, 110.21',
        status: LahanStatus.aktif,
        scanHistory: const [],
      );
      final addResult = await repository.addLahan(localLahan);
      expect(addResult.isRight, isTrue);

      final saveResult = await repository.saveScanResult(
        lahanId: localLahan.id,
        record: ScanRecord(
          id: 12345,
          recordedAt: DateTime.utc(2026, 5, 5, 10),
          ph: 6.4,
          moisture: 58,
          recommendation: 'Jagung',
        ),
      );
      expect(saveResult.isRight, isTrue);

      final syncResult = await repository.sync();
      expect(syncResult.isRight, isTrue);
      expect(remoteDataSource.upsertedLahan.map((entry) => entry.id), contains(100));
      expect(remoteDataSource.upsertedScanRecords.map((entry) => entry.id), contains(12345));

      final allLahan = await repository.getAllLahan();
      expect(allLahan.isRight, isTrue);
      expect(allLahan.right, hasLength(2));

      final syncedLocalLahan = allLahan.right.firstWhere((entry) => entry.id == 100);
      expect(syncedLocalLahan.scanHistory, hasLength(1));
      expect(syncedLocalLahan.latestScan?.recommendation, 'Jagung');
      expect(allLahan.right.any((entry) => entry.id == 999), isTrue);
    });

    test('marks deleted lahan as tombstones and syncs the deletion marker', () async {
      final lahan = Lahan(
        id: 77,
        owner: 'Pak Joko',
        area: 'Lahan C',
        location: '-8.16, 113.71',
        status: LahanStatus.perencanaan,
        scanHistory: const [],
      );

      final addResult = await repository.addLahan(lahan);
      expect(addResult.isRight, isTrue);

      final deleteResult = await repository.deleteLahan(lahan.id);
      expect(deleteResult.isRight, isTrue);

      final allLahan = await repository.getAllLahan();
      expect(allLahan.isRight, isTrue);
      expect(allLahan.right, isEmpty);

      final syncResult = await repository.sync();
      expect(syncResult.isRight, isTrue);

      final deletedPayload = remoteDataSource.upsertedLahan
          .where((entry) => entry.id == lahan.id)
          .last;
      expect(deletedPayload.deletedAt, isNotNull);
    });
  });
}
