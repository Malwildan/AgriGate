
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agri_core/agri_core.dart';

sealed class ResultEvent extends Equatable {
  const ResultEvent();
  @override
  List<Object?> get props => [];
}

class ResultInitialized extends ResultEvent {
  const ResultInitialized({
    required this.scanData,
    required this.lahanId,
    required this.ownerName,
    required this.lahanArea,
    this.location = '',
  });

  final ScanData scanData;
  final int lahanId;
  final String ownerName;
  final String lahanArea;
  final String location;

  @override
  List<Object?> get props => [scanData, lahanId, ownerName, lahanArea, location];
}

class ResultSaveRequested extends ResultEvent {
  const ResultSaveRequested();
}

class ResultScanAgainRequested extends ResultEvent {
  const ResultScanAgainRequested();
}

sealed class ResultState extends Equatable {
  const ResultState();
  @override
  List<Object?> get props => [];
}

class ResultInitial extends ResultState {
  const ResultInitial();
}

class ResultLoadingWeather extends ResultState {
  const ResultLoadingWeather();
}

class ResultReady extends ResultState {
  const ResultReady({
    required this.scanData,
    required this.recommendation,
    required this.lahanId,
    required this.ownerName,
    required this.lahanArea,
    required this.location,
    required this.dateLabel,
  });

  final ScanData scanData;
  final CropRecommendation recommendation;
  final int lahanId;
  final String ownerName;
  final String lahanArea;
    final String location;
  final String dateLabel;

  @override
  List<Object?> get props =>
      [scanData, recommendation, lahanId, ownerName, lahanArea, location, dateLabel];
}

class ResultSaving extends ResultState {
  const ResultSaving(this.ready);
  final ResultReady ready;
  @override
  List<Object?> get props => [ready];
}

class ResultSaved extends ResultState {
  const ResultSaved(this.lahanId);
  final int lahanId;
  @override
  List<Object?> get props => [lahanId];
}

class ResultError extends ResultState {
  const ResultError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ResultBloc extends Bloc<ResultEvent, ResultState> {
  ResultBloc(this._saveScanResult, this._getCropRecommendation, this._syncLahanData)
      : super(const ResultInitial()) {
    on<ResultInitialized>(_onInitialized);
    on<ResultSaveRequested>(_onSaveRequested);
  }

  final SaveScanResultUseCase _saveScanResult;
  final GetCropRecommendationUseCase _getCropRecommendation;
  final SyncLahanDataUseCase _syncLahanData;

  Future<void> _onInitialized(
    ResultInitialized event,
    Emitter<ResultState> emit,
  ) async {
    emit(const ResultLoadingWeather());

    final coords = _parseLatLon(event.location);
    final result = await _getCropRecommendation(
      GetCropRecommendationParams(
        ph: event.scanData.ph,
        moisture: event.scanData.moisture,
        latitude: coords?.$1,
        longitude: coords?.$2,
      ),
    );

    if (result.isLeft) {
      emit(ResultError(result.left.message));
      return;
    }

    emit(ResultReady(
      scanData: event.scanData,
      recommendation: result.right,
      lahanId: event.lahanId,
      ownerName: event.ownerName,
      lahanArea: event.lahanArea,
      location: event.location,
      dateLabel: _formatDate(DateTime.now()),
    ));
  }

  Future<void> _onSaveRequested(
    ResultSaveRequested event,
    Emitter<ResultState> emit,
  ) async {
    final ready = state;
    if (ready is! ResultReady) return;

    emit(ResultSaving(ready));

    final effectiveMoisture =
        ready.recommendation.soilMoisturePercent ?? ready.scanData.moisture;

    final result = await _saveScanResult(SaveScanResultParams(
      lahanId: ready.lahanId,
      ph: ready.scanData.ph,
      moisture: effectiveMoisture,
      recommendation: ready.recommendation.main,
      owner: ready.ownerName,
      area: ready.lahanArea,
      location: ready.location,
    ));

    if (result.isLeft) {
      emit(ResultError(result.left.message));
      return;
    }

    await _syncLahanData(const NoParams());
    emit(ResultSaved(result.right.id));
  }
  static (double, double)? _parseLatLon(String location) {
    if (location.isEmpty) return null;
    final parts = location.split(',');
    if (parts.length < 2) return null;
    final lat = _parseCoordinate(parts[0], isLatitude: true);
    final lon = _parseCoordinate(parts[1], isLatitude: false);
    if (lat == null || lon == null) return null;
    return (lat, lon);
  }

  static double? _parseCoordinate(
    String raw, {
    required bool isLatitude,
  }) {
    final match = RegExp(r'^([+-]?\d+(?:\.\d+)?)\s*(?:°)?\s*([NSEW])?$')
        .firstMatch(raw.trim().toUpperCase());
    if (match == null) return null;

    final value = double.tryParse(match.group(1)!);
    if (value == null) return null;

    final hemisphere = match.group(2);
    final normalized = switch (hemisphere) {
      'S' || 'W' => -value.abs(),
      'N' || 'E' => value.abs(),
      _ => value,
    };

    final maxAbs = isLatitude ? 90.0 : 180.0;
    if (normalized.abs() > maxAbs) return null;
    return normalized;
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
