import 'package:agri_core/agri_core.dart';
import 'package:feature_lahan_detail/feature_lahan_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetLahanByIdUseCase extends Mock implements GetLahanByIdUseCase {}

class _MockUpdateLahanStatusUseCase extends Mock
    implements UpdateLahanStatusUseCase {}

void main() {
  late _MockGetLahanByIdUseCase getLahanById;
  late _MockUpdateLahanStatusUseCase updateLahanStatus;

  final targetRecord = ScanRecord(
    id: 22,
    recordedAt: DateTime(2026, 5, 6),
    ph: 6.8,
    moisture: 62,
    recommendation: 'Cabai',
  );

  final lahan = Lahan(
    id: 7,
    owner: 'Pak Budi',
    area: '2 Hektar',
    location: '-6.2, 106.8',
    status: LahanStatus.aktif,
    scanHistory: [
      targetRecord,
      ScanRecord(
        id: 21,
        recordedAt: DateTime(2026, 5, 3),
        ph: 6.1,
        moisture: 48,
        recommendation: 'Jagung',
      ),
    ],
  );

  Widget buildSubject() {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        home: BlocProvider(
          create: (_) => DetailBloc(
            getLahanById: getLahanById,
            updateLahanStatus: updateLahanStatus,
          ),
          child: const ScanHistoryDetailPage(
            lahanId: 7,
            recordId: 22,
            onBack: _noop,
          ),
        ),
      ),
    );
  }

  setUp(() {
    getLahanById = _MockGetLahanByIdUseCase();
    updateLahanStatus = _MockUpdateLahanStatusUseCase();

    when(() => getLahanById(7)).thenAnswer((_) async => Right(lahan));
  });

  testWidgets('renders the selected scan history details', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Detail Riwayat'), findsOneWidget);
    expect(find.text('06 Mei 2026'), findsOneWidget);
    expect(find.text('Cabai'), findsNWidgets(2));
    expect(find.text('62%'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    verify(() => getLahanById(7)).called(1);
  });
}

void _noop() {}
