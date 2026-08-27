import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'app/controllers/index.dart';
import 'app/data/services/push_notification_service.dart';
import 'app/routes/index.dart';
import 'app/data/shared/index.dart';
import 'app/ui/index.dart';

void main() async {
  final prefs = Preferences();
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await ApiConfig.initialize();
  await prefs.initPrefs();
  await PushNotificationService.instance.initialize();

  Get.put(GlobalController());
  Get.put(AppUpdateController());
  Get.put(SplashController());
  Get.put(LoginController());
  Get.put(CustomMenuController());

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? _activeRoute;

  @override
  Widget build(BuildContext context) {
    configLoading();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return SafeArea(
      child: ScreenUtilInit(
        designSize: const Size(390, 844), // Base size (example: iPhone 12)
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyBio',
          getPages: AppPages.pages,
          initialRoute: Routes.appUpdate,
          routingCallback: (routing) {
            final route = routing?.current;
            if (route == null ||
                routing?.isBottomSheet == true ||
                routing?.isDialog == true ||
                route == _activeRoute) {
              return;
            }
            _activeRoute = route;
            if (route != Routes.chat &&
                route != Routes.chatDetails &&
                Get.isRegistered<ChatController>()) {
              ChatController.to.clearConversationSearch();
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              GlobalController.to.refreshPage(route);
            });
          },
          scrollBehavior: const AppScrollBehavior(),
          builder: (context, child) {
            final content = EasyLoading.init()(context, child);
            return Obx(
              () => Stack(
                children: [
                  content,
                  if (GlobalController.to.pageRefreshing.value)
                    Positioned(
                      top: 105,
                      left: 0,
                      right: 0,
                      child: Center(child: RefreshProgressIndicator()),
                    ),
                ],
              ),
            );
          },
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

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    final primaryController = PrimaryScrollController.maybeOf(context);
    final hasExclusiveController = !identical(
      details.controller,
      primaryController,
    );

    return Scrollbar(
      controller: details.controller,
      thumbVisibility: hasExclusiveController,
      child: child,
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..maskType = EasyLoadingMaskType.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = CustomColors.primaryColor
    ..backgroundColor = CustomColors.secundaryDarkerColor
    ..indicatorColor = CustomColors.primaryColor
    ..textColor = CustomColors.witheColor
    ..textStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: CustomColors.witheColor,
    )
    ..maskColor = Colors.transparent
    ..boxShadow = const [
      BoxShadow(color: Colors.black12, offset: Offset(0, 3), blurRadius: 5.0),
    ]
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
