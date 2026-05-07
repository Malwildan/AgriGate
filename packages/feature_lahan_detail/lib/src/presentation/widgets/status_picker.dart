
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';

class StatusPicker extends StatelessWidget {
  const StatusPicker({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  final LahanStatus currentStatus;
  final ValueChanged<LahanStatus> onStatusSelected;

  static const _items = [
    (LahanStatus.aktif, Icons.check_circle_outline_rounded),
    (LahanStatus.perencanaan, Icons.schedule_rounded),
    (LahanStatus.tidakAktif, Icons.do_not_disturb_on_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return AgriCard(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
      child: Column(
        children: _items.map((item) {
          final (status, icon) = item;
          final isSelected = status == currentStatus;
          return ListTile(
            onTap: () => onStatusSelected(status),
            leading: Icon(
              icon,
              size: 22,
              color: isSelected ? AgriColors.forest : AgriColors.inkMuted,
            ),
            title: Text(
              status.label,
              style: AgriTypography.textTheme.bodyMedium!.copyWith(
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AgriColors.ink : AgriColors.inkSoft,
              ),
            ),
            trailing: isSelected
                ? Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AgriColors.lime,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 13, color: AgriColors.forest),
                  )
                : null,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
          );
        }).toList(),
      ),
    );
  }
}
