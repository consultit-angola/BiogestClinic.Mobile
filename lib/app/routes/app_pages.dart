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
      name: Routes.alarme,
      page: () => const AlarmePage(),
      binding: AlarmeBinding(),
    ),
    // GetPage(
    //     name: Routes.driverMap,
    //     page: () => const DriverMapPage(),
    //     binding: DriverMapBinding()),
    // GetPage(
    //     name: Routes.driverTravelRequest,
    //     page: () => const DriverTravelRequestPage(),
    //     binding: DriverTravelRequestBinding()),
    // GetPage(
    //     name: Routes.driverTravelMap,
    //     page: () => const DriverTravelMapPage(),
    //     binding: DriverTravelMapBinding()),
    // GetPage(
    //     name: Routes.driverTravelCalification,
    //     page: () => const DriverTravelCalificationPage(),
    //     binding: DriverTravelCalificationBinding()),
    // GetPage(
    //     name: Routes.driverInfoRequired,
    //     page: () => const DriverInfoRequiredPage(),
    //     binding: DriverInfoRequiredBinding()),
    // GetPage(
    //     name: Routes.driverEdit,
    //     page: () => const DriverEditPage(),
    //     binding: DriverEditBinding()),
    // GetPage(
    //     name: Routes.driverVehicles,
    //     page: () => const DriverVehiclesPage(),
    //     binding: DriverVehiclesBinding()),
    // GetPage(
    //     name: Routes.driverAddVehicle,
    //     page: () => const DriverAddVehiclePage(),
    //     binding: DriverVehiclesBinding()),
    // GetPage(
    //     name: Routes.clientMap,
    //     page: () => const ClientMapPage(),
    //     binding: ClientMapBinding()),
    // GetPage(
    //     name: Routes.clientTravelInfo,
    //     page: () => const ClientTravelInfoPage(),
    //     binding: ClientTravelInfoBinding()),
    // GetPage(
    //     name: Routes.clientTravelRequest,
    //     page: () => const ClientTravelRequestPage(),
    //     binding: ClientTravelRequestBinding()),
    // GetPage(
    //     name: Routes.clientTravelMap,
    //     page: () => const ClientTravelMapPage(),
    //     binding: ClientTravelMapBinding()),
    // GetPage(
    //     name: Routes.clientTravelCalification,
    //     page: () => const ClientTravelCalificationPage(),
    //     binding: ClientTravelCalificationBinding()),
    // GetPage(
    //     name: Routes.clientEdit,
    //     page: () => const ClientEditPage(),
    //     binding: ClientEditBinding()),
    // GetPage(
    //     name: Routes.clientHistory,
    //     page: () => const ClientHistoryPage(),
    //     binding: ClientHistoryBinding()),
    // GetPage(
    //     name: Routes.clientHistoryDetail,
    //     page: () => const ClientHistoryDetailPage(),
    //     binding: ClientHistoryDetailBinding()),
    // GetPage(name: Routes.offlinePage, page: () => const OfflinePage()),
    // GetPage(name: Routes.chat, page: () => const ChatScreen()),
    // GetPage(
    //     name: Routes.wallet,
    //     page: () => const WalletPage(),
    //     binding: WalletBinding()),
  ];
}
