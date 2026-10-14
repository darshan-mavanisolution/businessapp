import 'package:get/get.dart';
import '../../data/repositories/business_repository.dart';
import '../themes/app_theme.dart';
import '../../features/authentication/auth_controller.dart';
import '../../features/home/home_controller.dart';
import '../../features/favorites/favorites_controller.dart';
import '../../features/filters/filter_controller.dart';
import '../../features/business_listing/business_controller.dart';
import '../../features/splash/splash_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Theme
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // Repository
    final IBusinessRepository repository = BusinessRepository();
    Get.put<IBusinessRepository>(repository, permanent: true);

    // Global Controllers
    Get.put<FilterController>(FilterController(), permanent: true);
    Get.put<BusinessController>(
      BusinessController(repository: repository),
      permanent: true,
    );
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<FavoritesController>(FavoritesController(), permanent: true);
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
