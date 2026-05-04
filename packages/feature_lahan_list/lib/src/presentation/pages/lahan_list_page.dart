// Lahan List Page — renders the hero greeting card and the list of lahan.

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
  @override
  void initState() {
    super.initState();
    context.read<LahanListBloc>().add(const LahanListLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AgriAppBar(statusBadge: widget.appBarStatusIndicator),
      body: BlocBuilder<LahanListBloc, LahanListState>(
        builder: (context, state) {
          return switch (state) {
            LahanListInitial() || LahanListLoading() => _buildSkeleton(),
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
      onRefresh: () async {
        context.read<LahanListBloc>().add(const LahanListRefreshRequested());
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
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _EmptyState(onAdd: widget.onAddLahan),
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
    return Skeletonizer(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, __) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: AgriColors.card,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
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
