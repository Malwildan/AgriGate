
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import '../bloc/lahan_list_bloc.dart';
import '../widgets/hero_greeting_card.dart';
import '../widgets/lahan_card.dart';

class LahanListPage extends StatefulWidget {
  const LahanListPage({
    super.key,
    required this.onAddLahan,
    required this.onSelectLahan,
    this.appBarStatusIndicator,
  });

  final VoidCallback onAddLahan;
  final ValueChanged<int> onSelectLahan;
  final Widget? appBarStatusIndicator;

  @override
  State<LahanListPage> createState() => _LahanListPageState();
}

class _LahanListPageState extends State<LahanListPage> {
  LahanListLoaded? _lastLoaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AgriAppBar(statusBadge: widget.appBarStatusIndicator),
      body: BlocConsumer<LahanListBloc, LahanListState>(
        listenWhen: (prev, curr) =>
            curr is LahanListLoaded && curr.syncError != null,
        listener: (context, state) {
          if (state is LahanListLoaded && state.syncError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Data belum tersinkron. Pastikan internet aktif lalu tarik untuk refresh.',
                ),
                action: SnackBarAction(
                  label: 'Refresh',
                  onPressed: () => context
                      .read<LahanListBloc>()
                      .add(const LahanListRefreshRequested()),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LahanListLoaded) _lastLoaded = state;
          return switch (state) {
            LahanListInitial() || LahanListLoading() => _buildSkeleton(),
            LahanListRefreshing() when _lastLoaded != null =>
              _buildContent(
                _lastLoaded!.lahanList,
                _lastLoaded!.totalScans,
                _lastLoaded!.activeCount,
              ),
            LahanListRefreshing() => _buildSkeleton(),
            LahanListLoaded(
              lahanList: final list,
              totalScans: final totalScans,
              activeCount: final activeCount
            ) =>
              _buildContent(list, totalScans, activeCount),
            LahanListError(message: final msg) => _buildError(msg),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAddLahan,
        backgroundColor: AgriColors.lime,
        foregroundColor: AgriColors.forest,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text('Tambah Lahan'),
      ),
    );
  }

  Widget _buildContent(
    List<Lahan> list,
    int totalScans,
    int activeCount,
  ) {
    return RefreshIndicator.adaptive(
      onRefresh: () {
        final completer = Completer<void>();
        final bloc = context.read<LahanListBloc>();
        bool seenRefreshing = false;
        final sub = bloc.stream.listen((s) {
          if (s is LahanListRefreshing) {
            seenRefreshing = true;
          } else if (seenRefreshing &&
              (s is LahanListLoaded || s is LahanListError)) {
            if (!completer.isCompleted) completer.complete();
          }
        });
        bloc.add(const LahanListRefreshRequested());
        return completer.future.whenComplete(sub.cancel);
      },
      color: AgriColors.forest,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: HeroGreetingCard(
                lahanCount: list.length,
                totalScans: totalScans,
                activeCount: activeCount,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionLabel('Lahan Anda'),
                  Text(
                    '${list.length} lahan',
                    style: AgriTypography.textTheme.bodySmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          if (list.isEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                fillOverscroll: true,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _EmptyState(onAdd: widget.onAddLahan),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final lahan = list[index];
                  return LahanCard(
                    lahan: lahan,
                    onTap: () => widget.onSelectLahan(lahan.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    final fakeLahan = Lahan(
      id: 0,
      owner: 'Nama Pemilik Lahan',
      area: 'Lahan X – 2.4 ha',
      location: '-7.5461, 110.2178',
      status: LahanStatus.aktif,
      scanHistory: [
        ScanRecord(
          id: 0,
          recordedAt: DateTime(2026, 1, 1),
          ph: 6.5,
          moisture: 60,
          recommendation: 'Jagung',
        ),
      ],
    );

    return Skeletonizer(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: const HeroGreetingCard(
                lahanCount: 3,
                totalScans: 12,
                activeCount: 2,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionLabel('Lahan Anda'),
                  Text(
                    '3 lahan',
                    style: AgriTypography.textTheme.bodySmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
            sliver: SliverList.separated(
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, __) => LahanCard(
                lahan: fakeLahan,
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AgriColors.error),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AgriTypography.textTheme.bodyMedium,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context
                  .read<LahanListBloc>()
                  .add(const LahanListLoadRequested()),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AgriColors.lime,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded,
                size: 28, color: AgriColors.forest),
          ),
          SizedBox(height: 16.h),
          Text(
            'Belum ada lahan',
            style: AgriTypography.textTheme.headlineSmall,
          ),
          SizedBox(height: 8.h),
          Text(
            'Tekan tombol "+" untuk menambah lahan pertama.',
            textAlign: TextAlign.center,
            style: AgriTypography.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
