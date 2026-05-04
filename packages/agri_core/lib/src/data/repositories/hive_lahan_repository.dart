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

  static Future<HiveLahanRepository> open() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ScanRecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LahanModelAdapter());
    }
    final box = await Hive.openBox<LahanModel>(_lahanBoxName);

    // Seed initial data if empty
    if (box.isEmpty) {
      await _seedInitialData(box);
    }

    return HiveLahanRepository(box);
  }

  static Future<void> _seedInitialData(Box<LahanModel> box) async {
    final entries = [
      Lahan(
        id: 1,
        owner: 'Pak Budi',
        area: 'Lahan A – 2.4 ha',
        location: '-7.5461, 110.2178',
        status: LahanStatus.aktif,
        scanHistory: const [
          ScanRecord(id: 101, date: '28 Apr 2026', ph: 6.2, moisture: 40, recommendation: 'Jagung'),
          ScanRecord(id: 102, date: '15 Mar 2026', ph: 6.5, moisture: 55, recommendation: 'Jagung'),
          ScanRecord(id: 103, date: '02 Feb 2026', ph: 6.0, moisture: 48, recommendation: 'Jagung'),
        ],
      ),
      Lahan(
        id: 2,
        owner: 'Bu Sari',
        area: 'Lahan B – 1.8 ha',
        location: '-6.9175, 107.6191',
        status: LahanStatus.aktif,
        scanHistory: const [
          ScanRecord(id: 201, date: '25 Apr 2026', ph: 7.1, moisture: 72, recommendation: 'Padi'),
          ScanRecord(id: 202, date: '10 Mar 2026', ph: 6.9, moisture: 68, recommendation: 'Jagung'),
        ],
      ),
      Lahan(
        id: 3,
        owner: 'Pak Joko',
        area: 'Lahan C – 1.2 ha',
        location: '-8.1653, 113.7160',
        status: LahanStatus.perencanaan,
        scanHistory: const [
          ScanRecord(id: 301, date: '21 Apr 2026', ph: 5.8, moisture: 52, recommendation: 'Singkong'),
        ],
      ),
    ];

    for (final entry in entries) {
      await box.put(entry.id, LahanModel.fromDomain(entry));
    }
  }

  @override
  Future<Either<Failure, List<Lahan>>> getAllLahan() async {
    try {
      final list = _box.values.map((m) => m.toDomain()).toList();
      return Right(list);
    } catch (e) {
      return Left(CacheFailure('Gagal memuat daftar lahan: $e'));
    }
  }

  @override
  Future<Either<Failure, Lahan>> getLahanById(int id) async {
    try {
      final model = _box.get(id);
      if (model == null) return const Left(CacheFailure('Lahan tidak ditemukan.'));
      return Right(model.toDomain());
    } catch (e) {
      return Left(CacheFailure('Gagal memuat lahan: $e'));
    }
  }

  @override
  Future<Either<Failure, Lahan>> addLahan(Lahan lahan) async {
    try {
      final model = LahanModel.fromDomain(lahan);
      await _box.put(lahan.id, model);
      return Right(lahan);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan lahan: $e'));
    }
  }

  @override
  Future<Either<Failure, Lahan>> updateLahan(Lahan lahan) async {
    try {
      final model = LahanModel.fromDomain(lahan);
      await _box.put(lahan.id, model);
      return Right(lahan);
    } catch (e) {
      return Left(CacheFailure('Gagal memperbarui lahan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLahan(int id) async {
    try {
      await _box.delete(id);
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
