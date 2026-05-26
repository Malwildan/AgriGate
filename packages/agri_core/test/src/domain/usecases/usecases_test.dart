import 'package:agri_core/agri_core.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLahanRepository implements LahanRepository {
  final Map<int, Lahan> _stored = <int, Lahan>{};

  Lahan? addedLahan;

  @override
  Future<Either<Failure, Lahan>> addLahan(Lahan lahan) async {
    addedLahan = lahan;
    _stored[lahan.id] = lahan;
    return Right(lahan);
  }

  @override
  Future<Either<Failure, void>> deleteLahan(int id) async {
    _stored.remove(id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, int>> reserveLahanId() async {
    if (_stored.isEmpty) {
      return const Right(42);
    }
    final nextId = _stored.keys.reduce((a, b) => a > b ? a : b) + 1;
    return Right(nextId);
  }

  @override
  Future<Either<Failure, int>> reserveScanRecordId() async => const Right(9001);

  @override
  Future<Either<Failure, List<Lahan>>> getAllLahan() async {
    return Right(_stored.values.toList());
  }

  @override
  Future<Either<Failure, Lahan>> getLahanById(int id) async {
    final lahan = _stored[id];
    if (lahan == null) {
      return const Left(CacheFailure('Lahan tidak ditemukan.'));
    }
    return Right(lahan);
  }

  @override
  Future<Either<Failure, Lahan>> updateLahan(Lahan lahan) async {
    _stored[lahan.id] = lahan;
    return Right(lahan);
  }
}

class _FakeScanRepository implements ScanRepository {
  _FakeScanRepository(this._lahanRepository);

  final LahanRepository _lahanRepository;

  int? savedLahanId;
  ScanRecord? savedRecord;

  @override
  Future<Either<Failure, Lahan>> saveScanResult({
    required int lahanId,
    required ScanRecord record,
  }) async {
    savedLahanId = lahanId;
    savedRecord = record;
    return _lahanRepository.getLahanById(lahanId);
  }
}

void main() {
  group('Hive-safe lahan IDs', () {
    final fixedNow = DateTime.utc(2026, 5, 5, 12, 34, 56, 789);

    test('AddLahanUseCase generates IDs within the Hive key range', () async {
      final repository = _FakeLahanRepository();
      final useCase = AddLahanUseCase(repository);

      final result = await useCase(const AddLahanParams(
        owner: 'Pak Budi',
        area: 'Lahan A',
        location: '-7.54, 110.21',
      ));

      expect(result.isRight, isTrue);
      expect(repository.addedLahan, isNotNull);
      expect(repository.addedLahan!.id, inInclusiveRange(1, 0xFFFFFFFF));
      expect(repository.addedLahan!.id, 42);
    });

    test(
      'SaveScanResultUseCase creates a brand-new lahan with a Hive-safe ID',
      () async {
        final lahanRepository = _FakeLahanRepository();
        final scanRepository = _FakeScanRepository(lahanRepository);
        final useCase = SaveScanResultUseCase(
          scanRepository,
          lahanRepository,
          now: () => fixedNow,
        );

        final result = await useCase(const SaveScanResultParams(
          lahanId: 0,
          ph: 6.5,
          moisture: 55,
          recommendation: 'Jagung',
          owner: 'Pak Budi',
          area: 'Lahan A',
          location: '-7.54, 110.21',
        ));

        expect(result.isRight, isTrue);
        expect(lahanRepository.addedLahan, isNotNull);
        expect(lahanRepository.addedLahan!.id, inInclusiveRange(1, 0xFFFFFFFF));
        expect(scanRepository.savedLahanId, lahanRepository.addedLahan!.id);
        expect(scanRepository.savedRecord?.recordedAt, fixedNow);
      },
    );
  });
}
