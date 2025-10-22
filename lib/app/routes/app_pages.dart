import 'package:get/get.dart';
import 'app_routes.dart';
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
    ),
    GetPage(
      name: Routes.calendar,
      page: () => const CalendarPage(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: Routes.activities,
      page: () => const ActivitiesPage(),
      binding: ActivitiesBinding(),
    ),
  ];
}
