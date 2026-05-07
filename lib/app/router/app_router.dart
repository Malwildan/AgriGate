
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:agri_core/agri_core.dart';
import 'package:feature_lahan_list/feature_lahan_list.dart';
import 'package:feature_scan/feature_scan.dart';
import 'package:feature_result/feature_result.dart';
import 'package:feature_lahan_detail/feature_lahan_detail.dart';
import '../di/injection.dart';
import '../widgets/bluetooth_connection_badge.dart';
class ResultRouteExtra {
  const ResultRouteExtra({
    required this.scanData,
    required this.lahanId,
    required this.ownerName,
    required this.lahanArea,
    this.lahanLocation = '',
  });

  final ScanData scanData;
  final int lahanId;
  final String ownerName;
  final String lahanArea;
  final String lahanLocation;
}
class RescanRouteExtra {
  const RescanRouteExtra({
    required this.owner,
    required this.area,
    required this.location,
  });

  final String owner;
  final String area;
  final String location;
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider<LahanListBloc>(
        create: (_) => LahanListBloc(
          getIt<GetAllLahanUseCase>(),
          getIt<SyncLahanDataUseCase>(),
        )..add(const LahanListLoadRequested()),
        child: LahanListPage(
          onSelectLahan: (id) => context.push('/detail/$id'),
          onAddLahan: () => context.push('/scan'),
          appBarStatusIndicator: const BluetoothConnectionBadge(),
        ),
      ),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => BlocProvider<ScanBloc>(
        create: (_) => ScanBloc(
          bleService: getIt<BleService>(),
          locationService: getIt<LocationService>(),
        )..add(const ScanInitialized()),
        child: ScanPage(
          onBack: () => context.pop(),
          onScanComplete: (
            scanData, {
            required ownerName,
            required lahanArea,
            required location,
          }) =>
              context.pushReplacement(
            '/result',
            extra: ResultRouteExtra(
              scanData: scanData,
              lahanId: 0,
              ownerName: ownerName,
              lahanArea: lahanArea,
              lahanLocation: location,
            ),
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/scan/:lahanId',
      builder: (context, state) {
        final lahanId = int.parse(state.pathParameters['lahanId']!);
        final extra = state.extra as RescanRouteExtra?;
        return BlocProvider<ScanBloc>(
          create: (_) => ScanBloc(
            bleService: getIt<BleService>(),
            locationService: getIt<LocationService>(),
          )..add(ScanInitialized(
              prefilledLahanId: lahanId,
              prefilledOwner: extra?.owner ?? '',
              prefilledArea: extra?.area ?? '',
              prefilledLocation: extra?.location ?? '',
            )),
          child: ScanPage(
            prefilledLahanId: lahanId,
            prefilledOwner: extra?.owner ?? '',
            prefilledArea: extra?.area ?? '',
            prefilledLocation: extra?.location ?? '',
            onBack: () => context.pop(),
            onScanComplete: (
              scanData, {
              required ownerName,
              required lahanArea,
              required location,
            }) =>
                context.pushReplacement(
              '/result',
              extra: ResultRouteExtra(
                scanData: scanData,
                lahanId: lahanId,
                ownerName: ownerName,
                lahanArea: lahanArea,
                lahanLocation: location,
              ),
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final extra = state.extra! as ResultRouteExtra;
        return BlocProvider<ResultBloc>(
          create: (_) => ResultBloc(
            getIt<SaveScanResultUseCase>(),
            getIt<GetCropRecommendationUseCase>(),
            getIt<SyncLahanDataUseCase>(),
          ),
          child: ResultPage(
            scanData: extra.scanData,
            lahanId: extra.lahanId,
            ownerName: extra.ownerName,
            lahanArea: extra.lahanArea,
            location: extra.lahanLocation,
            onBack: () => context.go('/'),
            onScanAgain: extra.lahanId > 0
                ? () => context.pushReplacement(
                      '/scan/${extra.lahanId}',
                      extra: RescanRouteExtra(
                        owner: extra.ownerName,
                        area: extra.lahanArea,
                        location: extra.lahanLocation,
                      ),
                    )
                : () => context.go('/'),
            onSaved: (lahanId) => context.go('/detail/$lahanId'),
          ),
        );
      },
    ),
    GoRoute(
      path: '/detail/:lahanId/history/:recordId',
      builder: (context, state) {
        final lahanId = int.parse(state.pathParameters['lahanId']!);
        final recordId = int.parse(state.pathParameters['recordId']!);
        return BlocProvider<DetailBloc>(
          create: (_) => DetailBloc(
            getLahanById: getIt<GetLahanByIdUseCase>(),
            updateLahanStatus: getIt<UpdateLahanStatusUseCase>(),
          ),
          child: ScanHistoryDetailPage(
            lahanId: lahanId,
            recordId: recordId,
            onBack: () => context.canPop()
                ? context.pop()
                : context.go('/detail/$lahanId'),
          ),
        );
      },
    ),
    GoRoute(
      path: '/detail/:lahanId',
      builder: (context, state) {
        final lahanId = int.parse(state.pathParameters['lahanId']!);
        return BlocProvider<DetailBloc>(
          create: (_) => DetailBloc(
            getLahanById: getIt<GetLahanByIdUseCase>(),
            updateLahanStatus: getIt<UpdateLahanStatusUseCase>(),
          ),
          child: LahanDetailPage(
            lahanId: lahanId,
            onBack: () => context.canPop() ? context.pop() : context.go('/'),
            onRescan: (lahan) => context.push(
              '/scan/${lahan.id}',
              extra: RescanRouteExtra(
                owner: lahan.owner,
                area: lahan.area,
                location: lahan.location,
              ),
            ),
            onOpenHistoryRecord: (record) => context.push(
              '/detail/$lahanId/history/${record.id}',
            ),
          ),
        );
      },
    ),
  ],
);
