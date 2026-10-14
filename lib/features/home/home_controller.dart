import 'package:get/get.dart';
import '../../data/models/business_model.dart';
import '../../core/services/remote_service.dart';

class HomeController extends GetxController {
  final RxString currentLocation = 'Surat, Gujarat'.obs;
  final RxInt unreadNotificationsCount = 3.obs;
  final RxList<BusinessModel> topRatedBusinesses = <BusinessModel>[].obs;
  final RxBool isLoading = false.obs;

  final List<String> availableCities = [
    'Surat, Gujarat',
    'Ahmedabad, Gujarat',
    'Rajkot, Gujarat',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTopRatedBusinesses();
    fetchNotificationsCount();
  }

  Future fetchTopRatedBusinesses({Map<String, dynamic>? map}) async {
    isLoading.value = true;
    final city = currentLocation.value.split(',').first.trim();
    final payload = map ?? {"city": city, "limit": 10};
    var res = await RemoteService.getTopRatedBusinesses(map: payload);
    print("fetchTopRatedBusinesses Res--------->>>> $res");
    isLoading.value = false;

    if (res != null && (res['success'] == true || res['status'] == 200)) {
      final list = (res['data'] ?? res['businesses'] ?? res) as List?;
      if (list != null && list.isNotEmpty) {
        topRatedBusinesses.assignAll(
          list.map((b) => BusinessModel.fromJson(Map<String, dynamic>.from(b))).toList(),
        );
      } else {
        topRatedBusinesses.clear();
      }
    } else {
      topRatedBusinesses.clear();
    }
    return res;
  }

  Future fetchNotificationsCount() async {
    var res = await RemoteService.getNotifications();
    print("fetchNotificationsCount Res--------->>>> $res");
    if (res != null && (res['success'] == true || res['status'] == 200)) {
      final list = (res['data'] ?? res['notifications'] ?? res) as List?;
      if (list != null) {
        final unread = list.where((n) => n['isRead'] != true && n['unread'] != false).length;
        unreadNotificationsCount.value = unread;
      }
    }
    return res;
  }

  void changeLocation(String newLocation) {
    currentLocation.value = newLocation;
    fetchTopRatedBusinesses();
  }

  Future markNotificationsAsRead({Map<String, dynamic>? map}) async {
    unreadNotificationsCount.value = 0;
    var res = await RemoteService.markNotificationsRead(map: map);
    print("markNotificationsAsRead Res--------->>>> $res");
    return res;
  }
}
