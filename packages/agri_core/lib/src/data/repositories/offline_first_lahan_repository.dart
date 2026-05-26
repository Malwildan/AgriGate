import 'dart:async';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:supabase/supabase.dart';

import '../../domain/entities/entities.dart';
import '../../domain/failures/failures.dart';
import '../../domain/repositories/repositories.dart';
import '../models/lahan_model.dart';
import '../models/pending_sync_operation.dart';
import '../models/supabase_lahan_dto.dart';
import '../models/supabase_scan_record_dto.dart';
import 'hive_lahan_repository.dart';
import 'supabase_lahan_remote_data_source.dart';

const _syncQueueBoxName = 'sync_queue_box';

class OfflineFirstLahanRepository
    implements LahanRepository, ScanRepository, SyncRepository {
  OfflineFirstLahanRepository._({
    required HiveLahanRepository localRepository,
    required Box<String> queueBox,
    this.remoteDataSource,
    this.authService,
  })  : _localRepository = localRepository,
        _queueBox = queueBox;

  static Future<OfflineFirstLahanRepository> open({
    required bool enableDemoSeed,
    SupabaseLahanRemoteDataSource? remoteDataSource,
    UserSessionGate? authService,
  }) async {
    final localRepository = await HiveLahanRepository.open(
      enableDemoSeed: enableDemoSeed,
    );
    final queueBox = await Hive.openBox<String>(_syncQueueBoxName);

    return OfflineFirstLahanRepository._(
      localRepository: localRepository,
      queueBox: queueBox,
      remoteDataSource: remoteDataSource,
      authService: authService,
    );
  }

  final HiveLahanRepository _localRepository;
  final Box<String> _queueBox;
  final SupabaseLahanRemoteDataSource? remoteDataSource;
  final UserSessionGate? authService;

  bool get _isSyncEnabled => remoteDataSource != null && authService != null;

  @override
  Future<Either<Failure, List<Lahan>>> getAllLahan() {
    return _localRepository.getAllLahan();
  }

  @override
  Future<Either<Failure, Lahan>> getLahanById(int id) {
    return _localRepository.getLahanById(id);
  }

  @override
  Future<Either<Failure, int>> reserveLahanId() {
    return _localRepository.reserveLahanId();
  }

  @override
  Future<Either<Failure, int>> reserveScanRecordId() {
    return _localRepository.reserveScanRecordId();
  }

  @override
  Future<Either<Failure, Lahan>> addLahan(Lahan lahan) async {
    final result = await _localRepository.addLahan(lahan);
    if (result.isLeft) {
      return Left(result.left);
    }

    final snapshot = await _localRepository.getLocalModelById(lahan.id);
    if (snapshot != null) {
      await _enqueueLahanSnapshot(snapshot);
    }

    return result;
  }

  @override
  Future<Either<Failure, Lahan>> updateLahan(Lahan lahan) async {
    final result = await _localRepository.updateLahan(lahan);
    if (result.isLeft) {
      return Left(result.left);
    }

    final snapshot = await _localRepository.getLocalModelById(lahan.id);
    if (snapshot != null) {
      await _enqueueLahanSnapshot(snapshot);
    }

    return result;
  }

  @override
  Future<Either<Failure, void>> deleteLahan(int id) async {
    final result = await _localRepository.deleteLahan(id);
    if (result.isLeft) {
      return Left(result.left);
    }

    final snapshot = await _localRepository.getLocalModelById(id);
    if (snapshot != null) {
      await _enqueueLahanSnapshot(snapshot);
    }

    return result;
  }

  @override
  Future<Either<Failure, Lahan>> saveScanResult({
    required int lahanId,
    required ScanRecord record,
  }) async {
    final lahanResult = await _localRepository.getLahanById(lahanId);
    if (lahanResult.isLeft) {
      return Left(lahanResult.left);
    }

    final updatedLahan = lahanResult.right.copyWith(
      status: LahanStatus.aktif,
      scanHistory: [record, ...lahanResult.right.scanHistory],
    );

    final result = await _localRepository.updateLahan(updatedLahan);
    if (result.isLeft) {
      return Left(result.left);
    }

    final snapshot = await _localRepository.getLocalModelById(lahanId);
    if (snapshot != null) {
      await _enqueueLahanSnapshot(snapshot);
    }

    await _enqueueScanRecord(
      SupabaseScanRecordDto.fromDomain(
        lahanId: lahanId,
        userId: '',
        record: record,
        syncedAt: DateTime.now().toUtc(),
      ),
    );

    return result;
  }

  @override
  Future<Either<Failure, void>> sync() async {
    if (!_isSyncEnabled) {
      return const Right(null);
    }

    final sessionResult = await authService!.requireUserId();
    if (sessionResult.isLeft) {
      return Left(sessionResult.left);
    }

    final userId = sessionResult.right;

    try {
      final replayFailure = await _replayPendingOperations(userId);
      if (replayFailure != null) {
        return Left(replayFailure);
      }

      final remoteSnapshot =
          await remoteDataSource!.pullAll(userId: userId);
      final mergedModels = await _mergeLocalAndRemote(remoteSnapshot);
      await _localRepository.overwriteLocalCache(mergedModels);

      return const Right(null);
    } on AuthException catch (error) {
      return Left(AuthFailure(error.message));
    } on PostgrestException catch (error) {
      return Left(SyncFailure(error.message));
    } on SocketException catch (error) {
      return Left(NetworkFailure('Sinkronisasi gagal karena jaringan: $error'));
    } on TimeoutException catch (error) {
      return Left(NetworkFailure('Sinkronisasi melebihi batas waktu: $error'));
    } catch (error) {
      return Left(SyncFailure('Sinkronisasi gagal: $error'));
    }
  }

  Future<Failure?> _replayPendingOperations(String userId) async {
    final operations = _pendingOperations();
    for (final operation in operations) {
      try {
        switch (operation.type) {
          case SyncOperationType.upsertLahan:
            await remoteDataSource!.upsertLahan(
              SupabaseLahanDto.fromSyncPayload(
                operation.payload,
                userId: userId,
              ),
            );
          case SyncOperationType.upsertScanRecord:
            await remoteDataSource!.upsertScanRecord(
              SupabaseScanRecordDto.fromSyncPayload(
                operation.payload,
                userId: userId,
              ),
            );
        }

        await _queueBox.delete(operation.id);
      } on AuthException catch (error) {
        return AuthFailure(error.message);
      } on PostgrestException catch (error) {
        return SyncFailure(error.message);
      } on SocketException catch (error) {
        return NetworkFailure('Gagal mengirim antrian sinkronisasi: $error');
      } catch (error) {
        return SyncFailure('Gagal memutar ulang antrian sinkronisasi: $error');
      }
    }

    return null;
  }

  Future<List<LahanModel>> _mergeLocalAndRemote(
    SupabaseRemoteSnapshot remoteSnapshot,
  ) async {
    final localModels =
        await _localRepository.getAllLocalModels(includeDeleted: true);
    final localById = {
      for (final model in localModels) model.id: model,
    };
    final remoteById = {
      for (final lahan in remoteSnapshot.lahan) lahan.id: lahan,
    };
    final remoteScansByLahan = <int, List<SupabaseScanRecordDto>>{};
    for (final record in remoteSnapshot.scanRecords) {
      if (record.deletedAt != null) {
        continue;
      }
      remoteScansByLahan.putIfAbsent(record.lahanId, () => []).add(record);
    }

    final merged = <LahanModel>[];
    final allIds = <int>{...localById.keys, ...remoteById.keys}.toList()
      ..sort();

    for (final id in allIds) {
      final localModel = localById[id];
      final remoteModel = remoteById[id];

      if (localModel == null && remoteModel != null) {
        merged.add(
          remoteModel.toLocalModel(
            scanRecords: remoteScansByLahan[id] ?? const [],
          ),
        );
        continue;
      }

      if (localModel != null && remoteModel == null) {
        merged.add(localModel);
        continue;
      }

      if (localModel == null || remoteModel == null) {
        continue;
      }

      merged.add(
        _mergeLahanModel(
          localModel: localModel,
          remoteModel: remoteModel,
          remoteScanRecords: remoteScansByLahan[id] ?? const [],
        ),
      );
    }

    return merged;
  }

  LahanModel _mergeLahanModel({
    required LahanModel localModel,
    required SupabaseLahanDto remoteModel,
    required List<SupabaseScanRecordDto> remoteScanRecords,
  }) {
    final mergedScanHistory = _mergeScanHistory(
      localModel.toDomain().scanHistory,
      remoteScanRecords.map((record) => record.toDomain()).toList(),
    );

    final prefersRemote = remoteModel.updatedAt.isAfter(localModel.effectiveUpdatedAt);
    final preferredDomain = prefersRemote
        ? remoteModel
            .toLocalModel(scanRecords: remoteScanRecords)
            .toDomain()
        : localModel.toDomain();

    final createdAt = localModel.effectiveCreatedAt.isBefore(remoteModel.createdAt)
        ? localModel.effectiveCreatedAt
        : remoteModel.createdAt;
    final deletedAt = _latestNullable(localModel.deletedAt, remoteModel.deletedAt);
    final updatedAt = remoteModel.updatedAt.isAfter(localModel.effectiveUpdatedAt)
        ? remoteModel.updatedAt
        : localModel.effectiveUpdatedAt;

    return LahanModel.fromDomain(
      preferredDomain.copyWith(scanHistory: mergedScanHistory),
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  List<ScanRecord> _mergeScanHistory(
    List<ScanRecord> localScanHistory,
    List<ScanRecord> remoteScanHistory,
  ) {
    final merged = <int, ScanRecord>{
      for (final record in localScanHistory) record.id: record,
    };
    for (final record in remoteScanHistory) {
      merged[record.id] = record;
    }

    return merged.values.toList()
      ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));
  }

  DateTime? _latestNullable(DateTime? left, DateTime? right) {
    if (left == null) {
      return right;
    }
    if (right == null) {
      return left;
    }
    return left.isAfter(right) ? left : right;
  }

  Future<void> _enqueueLahanSnapshot(LahanModel snapshot) async {
    await _removeQueuedLahanSnapshot(snapshot.id);
    final operation = PendingSyncOperation(
      id: 'lahan-${snapshot.id}-${DateTime.now().microsecondsSinceEpoch}',
      type: SyncOperationType.upsertLahan,
      payload: SupabaseLahanDto.fromLocalModel(snapshot, userId: '')
          .toSyncPayload(),
      createdAt: DateTime.now().toUtc(),
    );
    await _queueBox.put(operation.id, operation.encode());
  }

  Future<void> _enqueueScanRecord(SupabaseScanRecordDto record) async {
    final operation = PendingSyncOperation(
      id: 'scan-${record.id}-${DateTime.now().microsecondsSinceEpoch}',
      type: SyncOperationType.upsertScanRecord,
      payload: record.toSyncPayload(),
      createdAt: DateTime.now().toUtc(),
    );
    await _queueBox.put(operation.id, operation.encode());
  }

  Future<void> _removeQueuedLahanSnapshot(int lahanId) async {
    for (final operation in _pendingOperations()) {
      if (operation.type != SyncOperationType.upsertLahan) {
        continue;
      }
      final operationLahanId = (operation.payload['id'] as num?)?.toInt();
      if (operationLahanId == lahanId) {
        await _queueBox.delete(operation.id);
      }
    }
  }

  List<PendingSyncOperation> _pendingOperations() {
    return _queueBox.values
        .whereType<String>()
        .map(PendingSyncOperation.fromEncoded)
        .toList()
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
  }
}