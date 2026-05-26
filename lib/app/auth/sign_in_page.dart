import 'package:agri_core/agri_core.dart';
import 'package:agri_design_system/agri_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../di/injection.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result =
        await getIt<SupabaseAuthService>().sendEmailOtp(_emailController.text);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _errorMessage = failure.message;
      }),
      (_) => setState(() {
        _isLoading = false;
        _otpSent = true;
      }),
    );
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await getIt<SupabaseAuthService>().verifyEmailOtp(
      email: _emailController.text,
      token: _otpController.text,
    );
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _errorMessage = failure.message;
      }),
      (_) {
        setState(() => _isLoading = false);
        widget.onSignedIn();
      },
    );
  }

  Future<void> _signOut() async {
    await getIt<SupabaseAuthService>().signOut();
    if (!mounted) return;
    setState(() {
      _otpSent = false;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Masuk AgriGate',
                style: AgriTypography.textTheme.headlineMedium,
              ),
              SizedBox(height: 8.h),
              Text(
                'Gunakan email untuk menyimpan dan menyinkronkan data lahan Anda.',
                style: AgriTypography.textTheme.bodyMedium?.copyWith(
                  color: AgriColors.inkMuted,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                enabled: !_otpSent && !_isLoading,
              ),
              if (_otpSent) ...[
                SizedBox(height: 16.h),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kode OTP (6 digit)',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
              ],
              if (_errorMessage != null) ...[
                SizedBox(height: 12.h),
                Text(
                  _errorMessage!,
                  style: AgriTypography.textTheme.bodySmall?.copyWith(
                    color: AgriColors.error,
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              AgriPrimaryButton(
                label: _otpSent ? 'Verifikasi & Masuk' : 'Kirim Kode OTP',
                icon: Icons.login_rounded,
                onPressed: _isLoading
                    ? null
                    : (_otpSent ? _verifyOtp : _sendOtp),
              ),
              if (_otpSent) ...[
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: _isLoading ? null : _signOut,
                  child: const Text('Ganti email'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
