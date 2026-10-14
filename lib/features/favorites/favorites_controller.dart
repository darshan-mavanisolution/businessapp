import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/business_model.dart';
import '../../core/services/remote_service.dart';

class FavoritesController extends GetxController {
  final _storage = GetStorage();
  final String _key = 'favorite_business_ids';

  final RxSet<String> favoriteIds = <String>{}.obs;
  final RxList<BusinessModel> apiFavorites = <BusinessModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final List<dynamic>? stored = _storage.read<List<dynamic>>(_key);
    if (stored != null && stored.isNotEmpty) {
      favoriteIds.addAll(stored.map((e) => e.toString()));
    }

    fetchUserFavorites();
  }

  Future fetchUserFavorites({Map<String, dynamic>? map, bool showLoading = false}) async {
    if (showLoading || apiFavorites.isEmpty) {
      isLoading.value = true;
    }
    final query = map ?? {'page': 1, 'limit': 50};
    var res = await RemoteService.getUserFavorites(map: query);
    log("fetchUserFavorites Res--------->>>> $res");
    isLoading.value = false;

    if (res != null && (res['success'] == true || res['status'] == 200 || res['data'] != null)) {
      final rawData = res['data'] ?? res['favorites'] ?? res['result'] ?? res['items'];
      List? list;
      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map && rawData['favorites'] is List) {
        list = rawData['favorites'];
      } else if (rawData is Map && rawData['list'] is List) {
        list = rawData['list'];
      } else if (rawData is Map && rawData['data'] is List) {
        list = rawData['data'];
      } else if (res is List) {
        list = res;
      }

      if (list != null) {
        final List<BusinessModel> parsed = [];
        for (final item in list) {
          if (item is Map) {
            final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item);
            final targetObj = itemMap['person'] ?? itemMap['business'] ?? itemMap;
            if (targetObj is Map) {
              final Map<String, dynamic> merged = Map<String, dynamic>.from(targetObj);
              if (itemMap['personId'] != null && merged['personId'] == null) {
                merged['personId'] = itemMap['personId'];
              }
              parsed.add(BusinessModel.fromJson(merged));
            } else {
              parsed.add(BusinessModel.fromJson(itemMap));
            }
          }
        }

        apiFavorites.assignAll(parsed);
        for (final b in apiFavorites) {
          if (b.id.isNotEmpty) favoriteIds.add(b.id);
        }
        _storage.write(_key, favoriteIds.toList());
      }
    }
    return res;
  }

  bool isFavorite(String id) {
    return favoriteIds.contains(id);
  }

  Future toggleFavorite(
    String id, {
    String? businessName,
    String? personId,
    BusinessModel? business,
  }) async {
    final effectiveId = personId ?? id;
    if (favoriteIds.contains(effectiveId) || favoriteIds.contains(id)) {
      favoriteIds.remove(effectiveId);
      favoriteIds.remove(id);
      apiFavorites.removeWhere((b) =>
          b.id == effectiveId ||
          b.id == id ||
          (business != null && b.id == business.id));
      _storage.write(_key, favoriteIds.toList());

      Get.snackbar(
        'Removed from Favorites',
        '${businessName ?? "Business"} removed from your saved list',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );

      var res = await RemoteService.removeFavorite(personId: effectiveId);
      print("removeFavorite Res--------->>>> $res");

      fetchUserFavorites();
      return res;
    } else {
      favoriteIds.add(effectiveId);
      if (id.isNotEmpty) favoriteIds.add(id);

      if (business != null) {
        final alreadyInList = apiFavorites.any((b) =>
            b.id == business.id ||
            b.id == effectiveId ||
            (business.id.isNotEmpty && b.id == business.id));
        if (!alreadyInList) {
          apiFavorites.insert(0, business);
        }
      }
      _storage.write(_key, favoriteIds.toList());

      Get.snackbar(
        'Added to Favorites',
        '${businessName ?? "Business"} saved to your favorites',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );

      var res = await RemoteService.addFavorite(personId: effectiveId);
      print("addFavorite Res--------->>>> $res");

      fetchUserFavorites();
      return res;
    }
  }

  // Future addFavorite(String personId, {String? businessName}) async {
  //   favoriteIds.add(personId);
  //   _storage.write(_key, favoriteIds.toList());
  //   final res = await RemoteService.addFavorite(personId: personId);
  //   print("addFavorite Res--------->>>> $res");
  //   return res;
  // }
  //
  // Future removeFavorite(String personId, {String? businessName}) async {
  //   favoriteIds.remove(personId);
  //   apiFavorites.removeWhere((b) => b.id == personId);
  //   _storage.write(_key, favoriteIds.toList());
  //   final res = await RemoteService.removeFavorite(personId: personId);
  //   print("removeFavorite Res--------->>>> $res");
  //   return res;
  // }

  List<BusinessModel> get favoriteBusinesses => apiFavorites;
}
