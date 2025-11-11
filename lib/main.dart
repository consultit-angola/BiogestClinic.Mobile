import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'app/controllers/index.dart';
import 'app/routes/index.dart';
import 'app/data/shared/index.dart';
import 'app/ui/index.dart';

void main() async {
  final prefs = Preferences();
  WidgetsFlutterBinding.ensureInitialized();
  await prefs.initPrefs();
  await dotenv.load(fileName: ".env");
  configLoading();

  Get.put(GlobalController());
  Get.put(SplashController());
  Get.put(LoginController());
  Get.put(CustomMenuController());

  configLoading();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final prefs = Preferences();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return SafeArea(
      child: ScreenUtilInit(
        designSize: const Size(390, 844), // Tamaño base (ejemplo: iPhone 12)
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyBio',
          getPages: AppPages.pages,
          initialRoute: prefs.skipSplash ? Routes.login : Routes.splash,
          builder: EasyLoading.init(),
          theme: ThemeData(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: CustomColors.primaryLightColor,
              selectionColor: CustomColors.primaryLightColor.withValues(
                alpha: 0.3,
              ),
              selectionHandleColor: CustomColors.primaryLightColor,
            ),
          ),
        ),
      ),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withValues(alpha: 0.5)
    ..userInteractions = false
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

class CustomAnimation extends EasyLoadingAnimation {
  CustomAnimation();

  @override
  Widget buildWidget(
    Widget child,
    AnimationController controller,
    AlignmentGeometry alignment,
  ) {
    return Opacity(
      opacity: controller.value,
      child: RotationTransition(turns: controller, child: child),
    );
  }
}
