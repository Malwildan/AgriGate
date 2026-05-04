// App widget — MaterialApp.router with AgriTheme and ScreenUtilInit.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import 'router/app_router.dart';

class AgriGateApp extends StatelessWidget {
  const AgriGateApp({super.key});

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
