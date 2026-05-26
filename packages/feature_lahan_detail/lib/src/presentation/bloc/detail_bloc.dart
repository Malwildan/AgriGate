
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agri_core/agri_core.dart';

sealed class DetailEvent extends Equatable {
  const DetailEvent();
  @override
  List<Object?> get props => [];
}

class DetailLoadRequested extends DetailEvent {
  const DetailLoadRequested(this.lahanId);

  final int lahanId;

  @override
  List<Object?> get props => [lahanId];
}

class DetailStatusChanged extends DetailEvent {
  const DetailStatusChanged({required this.lahanId, required this.status});

  final int lahanId;
  final LahanStatus status;

  @override
  List<Object?> get props => [lahanId, status];
}

class DetailDeleteRequested extends DetailEvent {
  const DetailDeleteRequested(this.lahanId);

  final int lahanId;

  @override
  List<Object?> get props => [lahanId];
}

sealed class DetailState extends Equatable {
  const DetailState();
  @override
  List<Object?> get props => [];
}

class DetailInitial extends DetailState {
  const DetailInitial();
}

class DetailLoading extends DetailState {
  const DetailLoading();
}

class DetailLoaded extends DetailState {
  const DetailLoaded({required this.lahan});

  final Lahan lahan;

  DetailLoaded copyWith({Lahan? lahan}) {
    return DetailLoaded(lahan: lahan ?? this.lahan);
  }

  @override
  List<Object?> get props => [lahan];
}

class DetailDeleting extends DetailState {
  const DetailDeleting();
}

class DetailDeleted extends DetailState {
  const DetailDeleted();
}

class DetailError extends DetailState {
  const DetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc({
    required GetLahanByIdUseCase getLahanById,
    required UpdateLahanStatusUseCase updateLahanStatus,
    required DeleteLahanUseCase deleteLahan,
    required SyncLahanDataUseCase syncLahanData,
  })  : _getLahanById = getLahanById,
        _updateLahanStatus = updateLahanStatus,
        _deleteLahan = deleteLahan,
        _syncLahanData = syncLahanData,
        super(const DetailInitial()) {
    on<DetailLoadRequested>(_onLoad);
    on<DetailStatusChanged>(_onStatusChanged);
    on<DetailDeleteRequested>(_onDelete);
  }

  final GetLahanByIdUseCase _getLahanById;
  final UpdateLahanStatusUseCase _updateLahanStatus;
  final DeleteLahanUseCase _deleteLahan;
  final SyncLahanDataUseCase _syncLahanData;

  Future<void> _onLoad(
    DetailLoadRequested event,
    Emitter<DetailState> emit,
  ) async {
    emit(const DetailLoading());
    final result = await _getLahanById(event.lahanId);
    result.fold(
      (failure) => emit(DetailError(failure.message)),
      (lahan) => emit(DetailLoaded(lahan: lahan)),
    );
  }

  Future<void> _onStatusChanged(
    DetailStatusChanged event,
    Emitter<DetailState> emit,
  ) async {
    final current = state;
    if (current is! DetailLoaded) return;

    final result = await _updateLahanStatus(
      UpdateLahanStatusParams(
        lahanId: event.lahanId,
        status: event.status,
      ),
    );

    result.fold(
      (failure) => emit(DetailError(failure.message)),
      (lahan) => emit(current.copyWith(lahan: lahan)),
    );
  }

  Future<void> _onDelete(
    DetailDeleteRequested event,
    Emitter<DetailState> emit,
  ) async {
    emit(const DetailDeleting());
    final deleteResult = await _deleteLahan(event.lahanId);
    if (deleteResult.isLeft) {
      emit(DetailError(deleteResult.left.message));
      return;
    }

    final syncResult = await _syncLahanData(const NoParams());
    if (syncResult.isLeft) {
      emit(DetailError(syncResult.left.message));
      return;
    }

    emit(const DetailDeleted());
  }
}
