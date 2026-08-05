import 'package:get/get.dart';
import '../controllers/global_controller.dart';
import 'app_routes.dart';
import 'calendar_permission_middleware.dart';
import 'permission_middleware.dart';
import '../bindings/index.dart';
import '../ui/index.dart';

abstract class AppPages {
  static final pages = [
    GetPage(name: Routes.splash, page: () => const SplashPage()),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.chat,
      page: () => const ChatPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.chatDetails,
      page: () => const ChatDetailsPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.alarm,
      page: () => const AlarmPage(),
      binding: AlarmBinding(),
      middlewares: [
        PermissionMiddleware(GlobalController.globalConfigurationPermission),
      ],
    ),
    GetPage(
      name: Routes.calendar,
      page: () => const CalendarPage(),
      binding: CalendarBinding(),
      middlewares: [CalendarPermissionMiddleware()],
    ),
    GetPage(
      name: Routes.activities,
      page: () => const ActivitiesPage(),
      binding: ActivitiesBinding(),
      middlewares: [
        PermissionMiddleware(GlobalController.activityManagementPermission),
      ],
    ),
    GetPage(
      name: Routes.user,
      page: () => const UserPage(),
      binding: UserBinding(),
    ),
    GetPage(name: Routes.apiSettings, page: () => const ApiSettingsPage()),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      middlewares: [
        PermissionMiddleware(GlobalController.dashboardViewPermission),
      ],
    ),
  ];
}
