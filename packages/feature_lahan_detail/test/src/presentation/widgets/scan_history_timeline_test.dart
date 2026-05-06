import 'package:agri_core/agri_core.dart';
import 'package:feature_lahan_detail/feature_lahan_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required List<ScanRecord> records,
    ValueChanged<ScanRecord>? onRecordTap,
  }) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          body: ScanHistoryTimeline(
            scanHistory: records,
            onRecordTap: onRecordTap,
          ),
        ),
      ),
    );
  }

  final oldest = ScanRecord(
    id: 1,
    recordedAt: DateTime(2026, 5, 1),
    ph: 5.4,
    moisture: 38,
    recommendation: 'Padi',
  );
  final middle = ScanRecord(
    id: 2,
    recordedAt: DateTime(2026, 5, 3),
    ph: 6.3,
    moisture: 48,
    recommendation: 'Jagung',
  );
  final newest = ScanRecord(
    id: 3,
    recordedAt: DateTime(2026, 5, 6),
    ph: 6.8,
    moisture: 62,
    recommendation: 'Cabai',
  );

  testWidgets('renders newest records above older ones', (tester) async {
    await tester.pumpWidget(
      buildSubject(records: [middle, oldest, newest]),
    );

    final newestLabel = find.text('06 Mei 2026');
    final oldestLabel = find.text('01 Mei 2026');

    expect(newestLabel, findsOneWidget);
    expect(oldestLabel, findsOneWidget);
    expect(
      tester.getTopLeft(newestLabel).dy,
      lessThan(tester.getTopLeft(oldestLabel).dy),
    );
  });

  testWidgets('emits tapped record through callback', (tester) async {
    ScanRecord? tappedRecord;

    await tester.pumpWidget(
      buildSubject(
        records: [oldest, middle, newest],
        onRecordTap: (record) => tappedRecord = record,
      ),
    );

    await tester.tap(find.text('03 Mei 2026'));
    await tester.pump();

    expect(tappedRecord, middle);
  });
}
