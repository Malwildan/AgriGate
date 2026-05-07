
import '../entities/entities.dart';
import '../failures/failures.dart';
import '../repositories/repositories.dart';

const _maxHiveIntKey = 0xFFFFFFFF;

DateTime _utcNow() => DateTime.now().toUtc();

int _generateHiveCompatibleId(DateTime timestamp) {
  final id = timestamp.millisecondsSinceEpoch & _maxHiveIntKey;
  return id == 0 ? 1 : id;
}

abstract class UseCase<ResultType, Params> {
  Future<Either<Failure, ResultType>> call(Params params);
}

class NoParams {
  const NoParams();
}

class GetAllLahanUseCase implements UseCase<List<Lahan>, NoParams> {
  const GetAllLahanUseCase(this._repository);

  final LahanRepository _repository;

  @override
  Future<Either<Failure, List<Lahan>>> call(NoParams params) =>
      _repository.getAllLahan();
}

class GetLahanByIdUseCase implements UseCase<Lahan, int> {
  const GetLahanByIdUseCase(this._repository);

  final LahanRepository _repository;

  @override
  Future<Either<Failure, Lahan>> call(int id) => _repository.getLahanById(id);
}

class AddLahanParams {
  const AddLahanParams({
    required this.owner,
    required this.area,
    required this.location,
  });

  final String owner;
  final String area;
  final String location;
}

class AddLahanUseCase implements UseCase<Lahan, AddLahanParams> {
  AddLahanUseCase(this._repository, {DateTime Function()? now})
      : _now = now ?? _utcNow;

  final LahanRepository _repository;
  final DateTime Function() _now;

  @override
  Future<Either<Failure, Lahan>> call(AddLahanParams params) {
    final now = _now();
    final lahan = Lahan(
      id: _generateHiveCompatibleId(now),
      owner: params.owner.trim().isEmpty ? 'Pemilik Baru' : params.owner.trim(),
      area: params.area.trim().isEmpty ? 'Lahan Baru' : params.area.trim(),
      location: params.location.trim(),
      status: LahanStatus.aktif,
      scanHistory: const [],
    );
    return _repository.addLahan(lahan);
  }
}

class UpdateLahanStatusParams {
  const UpdateLahanStatusParams({required this.lahanId, required this.status});

  final int lahanId;
  final LahanStatus status;
}

class UpdateLahanStatusUseCase
    implements UseCase<Lahan, UpdateLahanStatusParams> {
  const UpdateLahanStatusUseCase(this._repository);

  final LahanRepository _repository;

  @override
  Future<Either<Failure, Lahan>> call(UpdateLahanStatusParams params) async {
    final result = await _repository.getLahanById(params.lahanId);
    if (result.isLeft) return result;
    final updated = result.right.copyWith(status: params.status);
    return _repository.updateLahan(updated);
  }
}

class SaveScanResultParams {
  const SaveScanResultParams({
    required this.lahanId,
    required this.ph,
    required this.moisture,
    required this.recommendation,
    this.owner = '',
    this.area = '',
    this.location = '',
  });

  final int lahanId;
  final double ph;
  final int moisture;
  final String recommendation;

  final String owner;
  final String area;
  final String location;
}

class SaveScanResultUseCase implements UseCase<Lahan, SaveScanResultParams> {
  SaveScanResultUseCase(
    this._scanRepository,
    this._lahanRepository, {
    DateTime Function()? now,
  }) : _now = now ?? _utcNow;

  final ScanRepository _scanRepository;
  final LahanRepository _lahanRepository;
  final DateTime Function() _now;

  @override
  Future<Either<Failure, Lahan>> call(SaveScanResultParams params) async {
    final now = _now();
    final record = ScanRecord(
      id: now.microsecondsSinceEpoch,
      recordedAt: now,
      ph: params.ph,
      moisture: params.moisture,
      recommendation: params.recommendation,
    );

    final lahanIdResult = params.lahanId > 0
        ? Right<Failure, int>(params.lahanId)
        : await _createLahan(
            owner: params.owner,
            area: params.area,
            location: params.location,
          );

    if (lahanIdResult.isLeft) {
      return Left(lahanIdResult.left);
    }

    return _scanRepository.saveScanResult(
      lahanId: lahanIdResult.right,
      record: record,
    );
  }

  Future<Either<Failure, int>> _createLahan({
    required String owner,
    required String area,
    required String location,
  }) async {
    final now = _now();
    final lahan = Lahan(
      id: _generateHiveCompatibleId(now),
      owner: owner.trim().isEmpty ? 'Pemilik Baru' : owner.trim(),
      area: area.trim().isEmpty ? 'Lahan Baru' : area.trim(),
      location: location.trim(),
      status: LahanStatus.aktif,
      scanHistory: const [],
    );

    final result = await _lahanRepository.addLahan(lahan);
    return result.fold(
      Left.new,
      (value) => Right(value.id),
    );
  }
}

class SyncLahanDataUseCase implements UseCase<void, NoParams> {
  const SyncLahanDataUseCase(this._repository);

  final SyncRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) => _repository.sync();
}

class GetCropRecommendationParams {
  const GetCropRecommendationParams({
    required this.ph,
    required this.moisture,
    this.latitude,
    this.longitude,
  });

  final double ph;
  final int moisture;
  final double? latitude;
  final double? longitude;
}

class GetCropRecommendationUseCase
    implements UseCase<CropRecommendation, GetCropRecommendationParams> {
  const GetCropRecommendationUseCase(this._repository);

  final CropRecommendationRepository _repository;

  @override
  Future<Either<Failure, CropRecommendation>> call(
    GetCropRecommendationParams params,
  ) =>
      _repository.getRecommendation(
        ph: params.ph,
        moisture: params.moisture,
        latitude: params.latitude,
        longitude: params.longitude,
      );
}
