import 'package:agri_core/agri_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:feature_lahan_list/feature_lahan_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetAllLahanUseCase extends Mock implements GetAllLahanUseCase {}

class _MockSyncLahanDataUseCase extends Mock implements SyncLahanDataUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  group('LahanListBloc', () {
    late _MockGetAllLahanUseCase getAllLahanUseCase;
    late _MockSyncLahanDataUseCase syncLahanDataUseCase;
    late List<String> calls;
    late Lahan lahan;

    setUp(() {
      getAllLahanUseCase = _MockGetAllLahanUseCase();
      syncLahanDataUseCase = _MockSyncLahanDataUseCase();
      calls = [];
      lahan = Lahan(
        id: 1,
        owner: 'Pak Budi',
        area: 'Lahan A',
        location: '-7.54, 110.21',
        status: LahanStatus.aktif,
        scanHistory: const [],
      );
    });

    blocTest<LahanListBloc, LahanListState>(
      'syncs remote changes before loading local lahan data on first load',
      setUp: () {
        when(() => syncLahanDataUseCase(any())).thenAnswer((_) async {
          calls.add('sync');
          return const Right(null);
        });
        when(() => getAllLahanUseCase(any())).thenAnswer((_) async {
          calls.add('load');
          return Right([lahan]);
        });
      },
      build: () => LahanListBloc(getAllLahanUseCase, syncLahanDataUseCase),
      act: (bloc) => bloc.add(const LahanListLoadRequested()),
      expect: () => [
        const LahanListLoading(),
        isA<LahanListLoaded>().having(
          (state) => state.lahanList,
          'lahanList',
          [lahan],
        ),
      ],
      verify: (_) {
        expect(calls, ['sync', 'load']);
      },
    );

    blocTest<LahanListBloc, LahanListState>(
      'syncs remote changes before reloading local lahan data on refresh',
      setUp: () {
        when(() => syncLahanDataUseCase(any())).thenAnswer((_) async {
          calls.add('sync');
          return const Right(null);
        });
        when(() => getAllLahanUseCase(any())).thenAnswer((_) async {
          calls.add('load');
          return Right([lahan]);
        });
      },
      build: () => LahanListBloc(getAllLahanUseCase, syncLahanDataUseCase),
      act: (bloc) => bloc.add(const LahanListRefreshRequested()),
      expect: () => [
        isA<LahanListLoaded>().having(
          (state) => state.lahanList,
          'lahanList',
          [lahan],
        ),
      ],
      verify: (_) {
        expect(calls, ['sync', 'load']);
      },
    );
  });
}