import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/otp_screen.dart';
import '../../features/home/main_nav_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/business_listing/business_listing_screen.dart';
import '../../features/business_detail/business_detail_screen.dart';
import '../../features/location/location_screen.dart';
import '../../features/search/business_search_screen.dart';
import '../../features/filters/filter_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/user_profile_detail_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/my_listings_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/terms_privacy_screen.dart';
import '../../features/profile/help_support_screen.dart';
import '../../features/profile/create_business_screen.dart';
import '../../features/city_sector/city_selection_screen.dart';
import '../../features/city_sector/sector_selection_screen.dart';
import '../../features/city_sector/sector_listing_screen.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessListing,
      page: () => const BusinessListingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessDetail,
      page: () => const BusinessDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.location,
      page: () => const LocationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const BusinessSearchScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.filter,
      page: () => const FilterScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesScreen(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.profileDetail,
      page: () => const UserProfileDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.myListings,
      page: () => const MyListingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.termsPrivacy,
      page: () => const TermsPrivacyScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.helpSupport,
      page: () => const HelpSupportScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.citySelection,
      page: () => const CitySelectionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.sectorSelection,
      page: () => const SectorSelectionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.sectorListing,
      page: () => const SectorListingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.createBusiness,
      page: () => const CreateBusinessScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
