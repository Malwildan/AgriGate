// Lahan List BLoC — events, states, and bloc.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agri_core/agri_core.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

sealed class LahanListEvent extends Equatable {
  const LahanListEvent();
  @override
  List<Object?> get props => [];
}

class LahanListLoadRequested extends LahanListEvent {
  const LahanListLoadRequested();
}

class LahanListRefreshRequested extends LahanListEvent {
  const LahanListRefreshRequested();
}

// ─── States ───────────────────────────────────────────────────────────────────

sealed class LahanListState extends Equatable {
  const LahanListState();
  @override
  List<Object?> get props => [];
}

class LahanListInitial extends LahanListState {
  const LahanListInitial();
}

class LahanListLoading extends LahanListState {
  const LahanListLoading();
}

class LahanListLoaded extends LahanListState {
  const LahanListLoaded(this.lahanList, {this.syncError});

  final List<Lahan> lahanList;

  /// Non-null when the last sync attempt failed. The list is still shown
  /// using local data; the UI should surface this as a dismissible banner.
  final String? syncError;

  int get totalScans =>
      lahanList.fold(0, (sum, e) => sum + e.scanHistory.length);
  int get activeCount =>
      lahanList.where((e) => e.status == LahanStatus.aktif).length;

  @override
  List<Object?> get props => [lahanList, syncError];
}

class LahanListRefreshing extends LahanListState {
  const LahanListRefreshing();
}

class LahanListError extends LahanListState {
  const LahanListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class LahanListBloc extends Bloc<LahanListEvent, LahanListState> {
  LahanListBloc(this._getAllLahan, this._syncLahanData)
      : super(const LahanListInitial()) {
    on<LahanListLoadRequested>(_onLoad);
    on<LahanListRefreshRequested>(_onRefresh);
  }

  final GetAllLahanUseCase _getAllLahan;
  final SyncLahanDataUseCase _syncLahanData;

  Future<void> _onLoad(
    LahanListLoadRequested event,
    Emitter<LahanListState> emit,
  ) async {
    emit(const LahanListLoading());
    await _syncAndFetch(emit);
  }

  Future<void> _onRefresh(
    LahanListRefreshRequested event,
    Emitter<LahanListState> emit,
  ) async {
    emit(const LahanListRefreshing());
    await _syncAndFetch(emit);
  }

  Future<void> _syncAndFetch(Emitter<LahanListState> emit) async {
    final syncResult = await _syncLahanData(const NoParams());
    final syncError = syncResult.isLeft ? syncResult.left.message : null;
    await _fetchAndEmit(emit, syncError: syncError);
  }

  Future<void> _fetchAndEmit(
    Emitter<LahanListState> emit, {
    String? syncError,
  }) async {
    final result = await _getAllLahan(const NoParams());
    result.fold(
      (failure) => emit(LahanListError(failure.message)),
      (list) => emit(LahanListLoaded(list, syncError: syncError)),
    );
  }
}
