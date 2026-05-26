
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agri_design_system/agri_design_system.dart';
import 'router/app_router.dart';

class AgriGateApp extends StatefulWidget {
  const AgriGateApp({super.key});

  @override
  State<AgriGateApp> createState() => _AgriGateAppState();
}

class _AgriGateAppState extends State<AgriGateApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFullscreenMode();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applyFullscreenMode();
    }
  }

  Future<void> _applyFullscreenMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp.router(
        title: 'AgriGate',
        debugShowCheckedModeBanner: false,
        theme: AgriTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
