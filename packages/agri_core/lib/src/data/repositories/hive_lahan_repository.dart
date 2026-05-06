// Hive-backed Lahan repository implementation.

import 'package:hive/hive.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures/failures.dart';
import '../../domain/repositories/repositories.dart';
import '../models/lahan_model.dart';

const _lahanBoxName = 'lahan_box';

class HiveLahanRepository implements LahanRepository {
  HiveLahanRepository(this._box);

  final Box<LahanModel> _box;

  static Future<HiveLahanRepository> open({
    bool enableDemoSeed = true,
  }) async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ScanRecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LahanModelAdapter());
    }
    final box = await Hive.openBox<LahanModel>(_lahanBoxName);

    // Seed initial data if empty
    if (box.isEmpty && enableDemoSeed) {
      await _seedInitialData(box);
    }

    return HiveLahanRepository(box);
  }

  Future<List<LahanModel>> getAllLocalModels({
    bool includeDeleted = false,
  }) async {
    return _box.values
        .where((model) => includeDeleted || model.deletedAt == null)
        .toList();
  }

  Future<LahanModel?> getLocalModelById(int id) async => _box.get(id);

  Future<void> putLocalModel(LahanModel model) async {
    await _box.put(model.id, model);
  }

  Future<void> overwriteLocalCache(List<LahanModel> models) async {
    final entries = <int, LahanModel>{
      for (final model in models) model.id: model,
    };
    await _box.clear();
    if (entries.isNotEmpty) {
      await _box.putAll(entries);
    }
  }

  static Future<void> _seedInitialData(Box<LahanModel> box) async {
    final entries = [
      Lahan(
        id: 1,
        owner: 'Pak Budi',
        area: 'Lahan A – 2.4 ha',
        location: '-7.5461, 110.2178',
        status: LahanStatus.aktif,
        scanHistory: [
          ScanRecord(
            id: 101,
            recordedAt: DateTime.utc(2026, 4, 28),
            ph: 6.2,
            moisture: 40,
            recommendation: 'Jagung',
          ),
          ScanRecord(
            id: 102,
            recordedAt: DateTime.utc(2026, 3, 15),
            ph: 6.5,
            moisture: 55,
            recommendation: 'Jagung',
          ),
          ScanRecord(
            id: 103,
            recordedAt: DateTime.utc(2026, 2, 2),
            ph: 6.0,
            moisture: 48,
            recommendation: 'Jagung',
          ),
        ],
      ),
      Lahan(
        id: 2,
        owner: 'Bu Sari',
        area: 'Lahan B – 1.8 ha',
        location: '-6.9175, 107.6191',
        status: LahanStatus.aktif,
        scanHistory: [
          ScanRecord(
            id: 201,
            recordedAt: DateTime.utc(2026, 4, 25),
            ph: 7.1,
            moisture: 72,
            recommendation: 'Padi',
          ),
          ScanRecord(
            id: 202,
            recordedAt: DateTime.utc(2026, 3, 10),
            ph: 6.9,
            moisture: 68,
            recommendation: 'Jagung',
          ),
        ],
      ),
      Lahan(
        id: 3,
        owner: 'Pak Joko',
        area: 'Lahan C – 1.2 ha',
        location: '-8.1653, 113.7160',
        status: LahanStatus.perencanaan,
        scanHistory: [
          ScanRecord(
            id: 301,
            recordedAt: DateTime.utc(2026, 4, 21),
            ph: 5.8,
            moisture: 52,
            recommendation: 'Singkong',
          ),
        ],
      ),
    ];

    for (final entry in entries) {
      await box.put(
        entry.id,
        LahanModel.fromDomain(
          entry,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: entry.latestScan?.recordedAt ?? DateTime.utc(2026, 1, 1),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Lahan>>> getAllLahan() async {
    try {
      final list = _box.values
          .where((model) => model.deletedAt == null)
          .map((model) => model.toDomain())
          .toList();
      return Right(list);
    } catch (e) {
      return Left(CacheFailure('Gagal memuat daftar lahan: $e'));
    }
  }

  @override
  Future<Either<Failure, Lahan>> getLahanById(int id) async {
    try {
      final model = _box.get(id);
      if (model == null || model.deletedAt != null) {
        return const Left(CacheFailure('Lahan tidak ditemukan.'));
      }
      return Right(model.toDomain());
    } catch (e) {
      return Left(CacheFailure('Gagal memuat lahan: $e'));
    }
  }

  @override
  Future<Either<Failure, Lahan>> addLahan(Lahan lahan) async {
    try {
      final model = LahanModel.fromDomain(
        lahan,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      await _box.put(lahan.id, model);
      return Right(lahan);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan lahan: $e'));
    }
  }

  @override
  Future<Either<Failure, Lahan>> updateLahan(Lahan lahan) async {
    try {
      final existing = _box.get(lahan.id);
      final model = LahanModel.fromDomain(
        lahan,
        createdAt: existing?.effectiveCreatedAt ?? DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        deletedAt: existing?.deletedAt,
      );
      await _box.put(lahan.id, model);
      return Right(lahan);
    } catch (e) {
      return Left(CacheFailure('Gagal memperbarui lahan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLahan(int id) async {
    try {
      final existing = _box.get(id);
      if (existing == null) {
        return const Right(null);
      }
      existing
        ..updatedAt = DateTime.now().toUtc()
        ..deletedAt = existing.updatedAt;
      await _box.put(id, existing);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menghapus lahan: $e'));
    }
  }
}

// ─── Hive Scan Repository ─────────────────────────────────────────────────────

class HiveScanRepository implements ScanRepository {
  HiveScanRepository(this._lahanRepository);

  final LahanRepository _lahanRepository;

  @override
  Future<Either<Failure, Lahan>> saveScanResult({
    required int lahanId,
    required ScanRecord record,
  }) async {
    final result = await _lahanRepository.getLahanById(lahanId);
    if (result.isLeft) return result;

    final updated = result.right.copyWith(
      status: LahanStatus.aktif,
      scanHistory: [record, ...result.right.scanHistory],
    );
    return _lahanRepository.updateLahan(updated);
  }
}
