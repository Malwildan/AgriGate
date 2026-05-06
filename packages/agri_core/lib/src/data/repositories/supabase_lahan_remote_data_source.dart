import 'package:supabase/supabase.dart';

import '../models/supabase_lahan_dto.dart';
import '../models/supabase_scan_record_dto.dart';

class SupabaseRemoteSnapshot {
  const SupabaseRemoteSnapshot({
    required this.lahan,
    required this.scanRecords,
  });

  final List<SupabaseLahanDto> lahan;
  final List<SupabaseScanRecordDto> scanRecords;
}

class SupabaseLahanRemoteDataSource {
  const SupabaseLahanRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<void> upsertLahan(SupabaseLahanDto lahan) async {
    await _client.from('lahan').upsert(lahan.toJson(), onConflict: 'id');
  }

  Future<void> upsertScanRecord(SupabaseScanRecordDto record) async {
    await _client
        .from('scan_records')
        .upsert(record.toJson(), onConflict: 'id');
  }

  Future<SupabaseRemoteSnapshot> pullAll({required String userId}) async {
    final lahanRows = await _client.from('lahan').select().eq('user_id', userId);
    final scanRows =
        await _client.from('scan_records').select().eq('user_id', userId);

    return SupabaseRemoteSnapshot(
      lahan: (lahanRows as List<dynamic>)
          .map((row) => SupabaseLahanDto.fromJson(
                Map<String, dynamic>.from(row as Map),
              ))
          .toList(),
      scanRecords: (scanRows as List<dynamic>)
          .map((row) => SupabaseScanRecordDto.fromJson(
                Map<String, dynamic>.from(row as Map),
              ))
          .toList(),
    );
  }
}