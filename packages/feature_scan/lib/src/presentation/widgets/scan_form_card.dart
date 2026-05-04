// ScanFormCard — owner, area, and GPS location inputs.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_design_system/agri_design_system.dart';

class ScanFormCard extends StatelessWidget {
  const ScanFormCard({
    super.key,
    required this.owner,
    required this.area,
    required this.location,
    required this.isCapturingGps,
    required this.onOwnerChanged,
    required this.onAreaChanged,
    required this.onLocationChanged,
    required this.onGpsRequested,
    required this.onGpsReset,
    this.gpsError,
  });

  final String owner;
  final String area;
  final String location;
  final bool isCapturingGps;
  final String? gpsError;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onAreaChanged;
  final ValueChanged<String> onLocationChanged;
  final VoidCallback onGpsRequested;
  final VoidCallback onGpsReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Info Lahan'),
        SizedBox(height: 12.h),
        AgriCard(
          borderRadius: 24,
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _AgriTextField(
                id: 'owner',
                label: 'Nama Pemilik Lahan',
                placeholder: 'cth. Pak Budi',
                value: owner,
                onChanged: onOwnerChanged,
              ),
              SizedBox(height: 20.h),
              _AgriTextField(
                id: 'area',
                label: 'Luas Lahan',
                placeholder: 'cth. Lahan A – 2.4 ha',
                value: area,
                onChanged: onAreaChanged,
              ),
              SizedBox(height: 20.h),
              _GpsField(
                location: location,
                isCapturing: isCapturingGps,
                error: gpsError,
                onChanged: onLocationChanged,
                onGpsRequested: onGpsRequested,
                onGpsReset: onGpsReset,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AgriTextField extends StatefulWidget {
  const _AgriTextField({
    required this.id,
    required this.label,
    required this.placeholder,
    required this.value,
    required this.onChanged,
  });

  final String id;
  final String label;
  final String placeholder;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_AgriTextField> createState() => _AgriTextFieldState();
}

class _AgriTextFieldState extends State<_AgriTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_AgriTextField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
      _controller.selection =
          TextSelection.collapsed(offset: widget.value.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AgriTypography.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w600,
            color: AgriColors.inkSoft,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          style: AgriTypography.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: AgriTypography.textTheme.bodyLarge!.copyWith(
              color: AgriColors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _GpsField extends StatefulWidget {
  const _GpsField({
    required this.location,
    required this.isCapturing,
    required this.onChanged,
    required this.onGpsRequested,
    required this.onGpsReset,
    this.error,
  });

  final String location;
  final bool isCapturing;
  final String? error;
  final ValueChanged<String> onChanged;
  final VoidCallback onGpsRequested;
  final VoidCallback onGpsReset;

  @override
  State<_GpsField> createState() => _GpsFieldState();
}

class _GpsFieldState extends State<_GpsField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.location);
  }

  @override
  void didUpdateWidget(_GpsField old) {
    super.didUpdateWidget(old);
    if (old.location != widget.location &&
        _controller.text != widget.location) {
      _controller.text = widget.location;
      _controller.selection =
          TextSelection.collapsed(offset: widget.location.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lokasi / Koordinat GPS',
          style: AgriTypography.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w600,
            color: AgriColors.inkSoft,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                style: AgriTypography.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'cth. -7.5461°S, 110.2178°E',
                ),
              ),
            ),
            SizedBox(width: 8.w),
            _GpsIconButton(
              onTap: widget.isCapturing ? null : widget.onGpsRequested,
              child: widget.isCapturing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AgriColors.forest),
                      ),
                    )
                  : const Icon(Icons.location_on_rounded,
                      size: 20, color: AgriColors.forest),
              bgColor: AgriColors.lime,
            ),
            if (widget.location.isNotEmpty) ...[
              SizedBox(width: 8.w),
              _GpsIconButton(
                onTap: widget.onGpsReset,
                child: const Icon(Icons.refresh_rounded,
                    size: 18, color: Color(0xFFDC2626)),
                bgColor: const Color(0xFFFFF2F2),
                borderColor: const Color(0x4CDC2626),
              ),
            ],
          ],
        ),
        if (widget.error != null) ...[
          SizedBox(height: 6.h),
          Text(
            widget.error!,
            style: AgriTypography.textTheme.bodySmall!.copyWith(
              color: AgriColors.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _GpsIconButton extends StatelessWidget {
  const _GpsIconButton({
    required this.child,
    required this.bgColor,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final Color bgColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
        ),
        child: Center(child: child),
      ),
    );
  }
}
