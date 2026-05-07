import 'package:agri_core/agri_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:feature_result/feature_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSaveScanResultUseCase extends Mock implements SaveScanResultUseCase {}

class _MockGetCropRecommendationUseCase extends Mock
    implements GetCropRecommendationUseCase {}

class _MockSyncLahanDataUseCase extends Mock implements SyncLahanDataUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SaveScanResultParams(
      lahanId: 0,
      ph: 0,
      moisture: 0,
      recommendation: '',
    ));
    registerFallbackValue(const GetCropRecommendationParams(ph: 0, moisture: 0));
    registerFallbackValue(const NoParams());
  });

  group('ResultBloc', () {
    late _MockSaveScanResultUseCase saveScanResultUseCase;
    late _MockGetCropRecommendationUseCase getCropRecommendationUseCase;
    late _MockSyncLahanDataUseCase syncLahanDataUseCase;
    late SaveScanResultParams capturedParams;
    late List<String> calls;

    setUp(() {
      saveScanResultUseCase = _MockSaveScanResultUseCase();
      getCropRecommendationUseCase = _MockGetCropRecommendationUseCase();
      syncLahanDataUseCase = _MockSyncLahanDataUseCase();
      calls = [];
    });

    blocTest<ResultBloc, ResultState>(
      'passes owner, area, and location then syncs after saving a brand-new lahan result',
      setUp: () {
        when(() => getCropRecommendationUseCase(any())).thenAnswer(
          (_) async => const Right(CropRecommendation(
            main: 'Jagung',
            alternatives: [],
            insight: 'Tanah cocok untuk jagung.',
            phLabel: 'Netral',
            moistureLabel: 'Sedang',
          )),
        );
        when(() => saveScanResultUseCase(any())).thenAnswer((invocation) async {
          calls.add('save');
          capturedParams = invocation.positionalArguments.first as SaveScanResultParams;
          return Right(
            Lahan(
              id: 88,
              owner: 'Pak Budi',
              area: 'Lahan A',
              location: '-7.54, 110.21',
              status: LahanStatus.aktif,
              scanHistory: const [],
            ),
          );
        });
        when(() => syncLahanDataUseCase(any())).thenAnswer((_) async {
          calls.add('sync');
          return const Right(null);
        });
      },
      build: () => ResultBloc(
        saveScanResultUseCase,
        getCropRecommendationUseCase,
        syncLahanDataUseCase,
      ),
      act: (bloc) async {
        bloc.add(const ResultInitialized(
          scanData: ScanData(ph: 6.5, moisture: 55),
          lahanId: 0,
          ownerName: 'Pak Budi',
          lahanArea: 'Lahan A',
          location: '-7.54, 110.21',
        ));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ResultSaveRequested());
      },
      expect: () => [
        const ResultLoadingWeather(),
        isA<ResultReady>(),
        isA<ResultSaving>(),
        const ResultSaved(88),
      ],
      verify: (_) {
        expect(capturedParams.lahanId, 0);
        expect(capturedParams.owner, 'Pak Budi');
        expect(capturedParams.area, 'Lahan A');
        expect(capturedParams.location, '-7.54, 110.21');
        expect(capturedParams.recommendation, 'Jagung');
        expect(calls, ['save', 'sync']);
      },
    );

    blocTest<ResultBloc, ResultState>(
      'emits an error when saving scan history fails',
      setUp: () {
        when(() => getCropRecommendationUseCase(any())).thenAnswer(
          (_) async => const Right(CropRecommendation(
            main: 'Singkong',
            alternatives: [],
            insight: 'Tanah cocok untuk singkong.',
            phLabel: 'Asam',
            moistureLabel: 'Rendah',
          )),
        );
        when(() => saveScanResultUseCase(any())).thenAnswer(
          (_) async => const Left(CacheFailure('Gagal menyimpan scan.')),
        );
      },
      build: () => ResultBloc(
        saveScanResultUseCase,
        getCropRecommendationUseCase,
        syncLahanDataUseCase,
      ),
      act: (bloc) async {
        bloc.add(const ResultInitialized(
          scanData: ScanData(ph: 6.2, moisture: 42),
          lahanId: 7,
          ownerName: 'Bu Sari',
          lahanArea: 'Lahan B',
        ));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ResultSaveRequested());
      },
      expect: () => [
        const ResultLoadingWeather(),
        isA<ResultReady>(),
        isA<ResultSaving>(),
        const ResultError('Gagal menyimpan scan.'),
      ],
    );

    blocTest<ResultBloc, ResultState>(
      'emits ResultError when the Railway API fails',
      setUp: () {
        when(() => getCropRecommendationUseCase(any())).thenAnswer(
          (_) async => const Left(
              RecommendationFailure('Tidak dapat terhubung ke server rekomendasi.')),
        );
      },
      build: () => ResultBloc(
        saveScanResultUseCase,
        getCropRecommendationUseCase,
        syncLahanDataUseCase,
      ),
      act: (bloc) => bloc.add(const ResultInitialized(
        scanData: ScanData(ph: 6.5, moisture: 55),
        lahanId: 1,
        ownerName: 'Pak Andi',
        lahanArea: 'Lahan C',
      )),
      expect: () => [
        const ResultLoadingWeather(),
        const ResultError('Tidak dapat terhubung ke server rekomendasi.'),
      ],
    );
  });
}