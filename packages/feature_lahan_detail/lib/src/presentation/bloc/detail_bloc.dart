// Detail BLoC — loads lahan detail and handles status changes.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agri_core/agri_core.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

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

class DetailStatusPickerToggled extends DetailEvent {
  const DetailStatusPickerToggled();
}

// ─── States ───────────────────────────────────────────────────────────────────

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
  const DetailLoaded({
    required this.lahan,
    this.isPickerOpen = false,
  });

  final Lahan lahan;
  final bool isPickerOpen;

  DetailLoaded copyWith({Lahan? lahan, bool? isPickerOpen}) {
    return DetailLoaded(
      lahan: lahan ?? this.lahan,
      isPickerOpen: isPickerOpen ?? this.isPickerOpen,
    );
  }

  @override
  List<Object?> get props => [lahan, isPickerOpen];
}

class DetailError extends DetailState {
  const DetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc({
    required GetLahanByIdUseCase getLahanById,
    required UpdateLahanStatusUseCase updateLahanStatus,
  })  : _getLahanById = getLahanById,
        _updateLahanStatus = updateLahanStatus,
        super(const DetailInitial()) {
    on<DetailLoadRequested>(_onLoad);
    on<DetailStatusChanged>(_onStatusChanged);
    on<DetailStatusPickerToggled>(_onPickerToggled);
  }

  final GetLahanByIdUseCase _getLahanById;
  final UpdateLahanStatusUseCase _updateLahanStatus;

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
      (lahan) => emit(current.copyWith(lahan: lahan, isPickerOpen: false)),
    );
  }

  void _onPickerToggled(
    DetailStatusPickerToggled event,
    Emitter<DetailState> emit,
  ) {
    final current = state;
    if (current is DetailLoaded) {
      emit(current.copyWith(isPickerOpen: !current.isPickerOpen));
    }
  }
}
