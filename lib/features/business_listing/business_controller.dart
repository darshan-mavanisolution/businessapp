import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/business_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/business_repository.dart';
import '../filters/filter_controller.dart';

import '../../core/services/remote_service.dart';

class BusinessController extends GetxController {
  final IBusinessRepository repository;
  BusinessController({required this.repository});

  final FilterController filterController = Get.find<FilterController>();

  // Search input
  final TextEditingController searchInputController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Selected Category on Listing Screen
  final RxString selectedCategory = 'Doctor'.obs;
  // Selected State and City on Listing Screen
  final RxString selectedState = 'All'.obs;
  final RxString selectedCity = 'All'.obs;

  // Live State & City options from API
  final RxList<String> apiStates = <String>[].obs;
  final RxList<String> apiCitiesForState = <String>[].obs;
  final RxBool isLoadingStates = false.obs;
  final RxBool isLoadingCities = false.obs;

  // Selected Business for Detail/Location Screen
  final Rx<BusinessModel?> selectedBusiness = Rx<BusinessModel?>(null);

  // Live API States
  final RxBool isLoading = false.obs;
  final RxList<CategoryModel> apiCategories = <CategoryModel>[].obs;
  final RxList<BusinessModel> apiBusinesses = <BusinessModel>[].obs;

  // People Listing (via /people API)
  final RxList<BusinessModel> peopleList = <BusinessModel>[].obs;
  final RxBool isLoadingPeople = false.obs;
  final RxInt peopleCurrentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    searchInputController.addListener(() {
      searchQuery.value = searchInputController.text;
    });

    fetchCategories();
    fetchBusinesses();
    fetchAvailableStates();
  }

  Future fetchCategories({Map<String, dynamic>? map}) async {
    isLoading.value = true;
    var res = await RemoteService.getCategories(map: map);
    print("fetchCategories Res--------->>>> $res");
    isLoading.value = false;
    if (res != null && (res['success'] == true || res['status'] == 200)) {
      final list = (res['data'] ?? res['categories'] ?? res) as List?;
      if (list != null && list.isNotEmpty) {
        apiCategories.assignAll(list.map((c) => CategoryModel.fromJson(Map<String, dynamic>.from(c))).toList());
      }
    }
    return res;
  }

  Future fetchBusinesses({Map<String, dynamic>? map}) async {
    isLoading.value = true;
    var res = await RemoteService.getBusinesses(map: map);
    log("fetchBusinesses Res--------->>>> $res");
    isLoading.value = false;
    if (res != null && (res['success'] == true || res['status'] == 200)) {
      final list = (res['data'] ?? res['businesses'] ?? res) as List?;
      if (list != null) {
        final incoming = list
            .map((b) => BusinessModel.fromJson(Map<String, dynamic>.from(b)))
            .toList();
        final existingMap = {for (var b in apiBusinesses) b.id: b};
        for (var b in incoming) {
          existingMap[b.id] = b;
        }
        apiBusinesses.assignAll(existingMap.values.toList());
        if (apiBusinesses.isNotEmpty) {
          if (selectedBusiness.value == null || !apiBusinesses.any((b) => b.id == selectedBusiness.value?.id)) {
            selectedBusiness.value = apiBusinesses.first;
          }
        }
      }
    }
    return res;
  }

  Future fetchPeople({
    String? query,
    int page = 1,
    int limit = 20,
    String? state,
    String? city,
  }) async {
    isLoading.value = true;
    isLoadingPeople.value = true;
    peopleCurrentPage.value = page;

    final cat = selectedCategory.value;
    final effectiveQuery = (query != null && query.isNotEmpty)
        ? query
        : (cat.isNotEmpty && cat.toLowerCase() != 'all' ? cat.toLowerCase() : 'advocate');

    final map = <String, dynamic>{
      'query': effectiveQuery,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (state != null && state.isNotEmpty && state.toLowerCase() != 'all') {
      map['state'] = state;
    }
    if (city != null && city.isNotEmpty && city.toLowerCase() != 'all') {
      map['city'] = city;
    }

    var res = await RemoteService.getPeople(map: map);
    log("fetchPeople Res--------->>>> $res");
    isLoading.value = false;
    isLoadingPeople.value = false;

    if (res != null) {
      dynamic listData;
      if (res is List) {
        listData = res;
      } else if (res is Map) {
        if (res['data'] is List) {
          listData = res['data'];
        } else if (res['people'] is List) {
          listData = res['people'];
        } else if (res['results'] is List) {
          listData = res['results'];
        } else if (res['docs'] is List) {
          listData = res['docs'];
        } else if (res['data'] is Map) {
          final d = res['data'] as Map;
          listData = d['people'] ?? d['docs'] ?? d['results'] ?? d['items'];
        }
      }

      if (listData is List) {
        final incoming = listData.map((b) {
          final itemMap = Map<String, dynamic>.from(b is Map ? b : {});
          if ((itemMap['category'] == null || itemMap['category'].toString().isEmpty) &&
              (itemMap['profession'] == null || itemMap['profession'].toString().isEmpty)) {
            itemMap['category'] = effectiveQuery;
          }
          return BusinessModel.fromJson(itemMap);
        }).toList();

        peopleList.assignAll(incoming);

        // Also merge into apiBusinesses so detail screens & search have access
        final existingMap = {for (var b in apiBusinesses) b.id: b};
        for (var b in incoming) {
          existingMap[b.id] = b;
        }
        apiBusinesses.assignAll(existingMap.values.toList());

        if (incoming.isNotEmpty) {
          if (selectedBusiness.value == null || !apiBusinesses.any((b) => b.id == selectedBusiness.value?.id)) {
            selectedBusiness.value = incoming.first;
          }
        }
      }
    }
    return res;
  }

  final RxBool isLoadingDetails = false.obs;

  Future fetchBusinessDetails(String id) async {
    isLoadingDetails.value = true;
    dynamic res;

    if (id.startsWith('usr_')) {
      res = await RemoteService.getPersonDetails(id: id);
    }

    if (res == null || (res is Map && res['success'] != true && res['status'] != 200)) {
      res = await RemoteService.getBusinessDetails(id: id);
      if (res == null || (res is Map && res['success'] != true && res['status'] != 200)) {
        res = await RemoteService.getPersonDetails(id: id);
      }
    }

    print("fetchBusinessDetails ($id) Res--------->>>> $res");
    isLoadingDetails.value = false;
    if (res != null && (res['success'] == true || res['status'] == 200)) {
      var data = res['data'] ?? res['business'] ?? res['person'] ?? res;
      if (data is Map && data['business'] is Map) {
        data = data['business'];
      } else if (data is Map && data['person'] is Map) {
        data = data['person'];
      }
      if (data is Map) {
        final b = BusinessModel.fromJson(Map<String, dynamic>.from(data));
        selectedBusiness.value = b;
      }
    }
    return res;
  }

  Future<void> fetchAvailableStates() async {
    isLoadingStates.value = true;
    try {
      var res = await RemoteService.getStates();
      if (res != null && (res['success'] == true || res['status'] == 200)) {
        final list = (res['data'] ?? res['states'] ?? res) as List?;
        if (list != null && list.isNotEmpty) {
          final states = list.map((item) {
            if (item is Map) {
              return item['name']?.toString() ?? item['state']?.toString() ?? '';
            }
            return item.toString();
          }).where((s) => s.isNotEmpty).toList();
          if (states.isNotEmpty) {
            apiStates.assignAll(states);
          }
        }
      }
    } catch (_) {}
    isLoadingStates.value = false;
  }

  Future<void> fetchCitiesForSelectedState(String state) async {
    if (state == 'All') {
      apiCitiesForState.clear();
      return;
    }
    isLoadingCities.value = true;
    apiCitiesForState.clear();
    try {
      // 1. Fetch cities for the selected state from getCities API
      var res = await RemoteService.getCities(map: {'state': state});
      var list = (res != null && (res['success'] == true || res['status'] == 200 || res is List))
          ? (res is List ? res : (res['data'] ?? res['cities'] ?? res['result'])) as List?
          : null;

      // 2. Fallback to getCitiesByState if needed
      if (list == null || list.isEmpty) {
        res = await RemoteService.getCitiesByState(state: state);
        list = (res != null && (res['success'] == true || res['status'] == 200 || res is List))
            ? (res is List ? res : (res['data'] ?? res['cities'] ?? res['result'])) as List?
            : null;
      }

      if (list != null && list.isNotEmpty) {
        final cities = list.map((item) {
          if (item is Map) {
            return (item['name'] ?? item['city'] ?? item['title'] ?? '').toString();
          }
          return item.toString();
        }).where((c) => c.trim().isNotEmpty).toList();
        apiCitiesForState.assignAll(cities);
      }
    } catch (_) {}
    isLoadingCities.value = false;
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }

  List<CategoryModel> get categories => apiCategories;

  List<BusinessModel> get allBusinesses => apiBusinesses;

  // Available State dropdown options with 'All' first (loaded from API)
  List<String> get availableStateOptions {
    final list = <String>['All'];
    final seen = <String>{'all'};

    for (final s in apiStates) {
      if (s.isNotEmpty && seen.add(s.toLowerCase())) {
        list.add(s);
      }
    }

    for (final b in apiBusinesses) {
      if (b.state.isNotEmpty && seen.add(b.state.toLowerCase())) {
        list.add(b.state);
      }
    }

    return list;
  }

  // Whether the City filter is enabled (requires a specific state to be selected)
  bool get isCityFilterEnabled => selectedState.value != 'All';

  // Available City dropdown options with 'All' first (dependent on selectedState, loaded from API)
  List<String> get availableCityOptions {
    final state = selectedState.value;
    if (state == 'All') {
      return const ['All'];
    }

    final list = <String>['All'];
    final seen = <String>{'all'};

    // 1. Cities loaded from API for the selected state
    for (final c in apiCitiesForState) {
      if (c.isNotEmpty && seen.add(c.toLowerCase())) {
        list.add(c);
      }
    }

    // 2. Cities from businesses loaded from API matching this state
    for (final b in apiBusinesses) {
      if (b.city.isNotEmpty) {
        if (b.state.toLowerCase() == state.toLowerCase()) {
          if (seen.add(b.city.toLowerCase())) {
            list.add(b.city);
          }
        }
      }
    }

    return list;
  }

  // All city options across all states (loaded from API)
  List<String> get allCityOptions {
    final list = <String>['All'];
    final seen = <String>{'all'};

    for (final c in apiCitiesForState) {
      if (c.isNotEmpty && seen.add(c.toLowerCase())) {
        list.add(c);
      }
    }

    for (final b in apiBusinesses) {
      if (b.city.isNotEmpty && seen.add(b.city.toLowerCase())) {
        list.add(b.city);
      }
    }

    return list;
  }

  // Businesses filtered for Category Listing Screen
  List<BusinessModel> get categoryListingBusinesses {
    final cat = selectedCategory.value;
    final state = selectedState.value;
    final city = selectedCity.value;
    final query = searchQuery.value.trim().toLowerCase();

    // Prioritize peopleList returned from /people API
    final source = peopleList.isNotEmpty ? peopleList : allBusinesses;

    return source.where((b) {
      // Category filter (only needed if falling back to allBusinesses; peopleList was already fetched for this category)
      if (peopleList.isEmpty && cat.isNotEmpty && cat.toLowerCase() != 'all') {
        if (!_isCategoryMatch(cat, b.category)) return false;
      }
      // State filter
      if (state.isNotEmpty && state.toLowerCase() != 'all') {
        if (b.state.toLowerCase() != state.toLowerCase()) return false;
      }
      // City filter
      if (city.isNotEmpty && city.toLowerCase() != 'all') {
        if (b.city.toLowerCase() != city.toLowerCase()) return false;
      }
      // Query filter
      if (query.isNotEmpty) {
        final matches = b.name.toLowerCase().contains(query) ||
            b.specialty.toLowerCase().contains(query) ||
            b.address.toLowerCase().contains(query) ||
            b.city.toLowerCase().contains(query) ||
            b.state.toLowerCase().contains(query);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  // Businesses filtered for Search Results Screen (combining category, state and city filters)
  List<BusinessModel> get searchResultsBusinesses {
    final query = searchQuery.value.trim().toLowerCase();
    final cat = filterController.activeCategory.value;
    final city = filterController.activeCity.value;

    return allBusinesses.where((b) {
      // Search Query
      if (query.isNotEmpty) {
        final matches = b.name.toLowerCase().contains(query) ||
            b.specialty.toLowerCase().contains(query) ||
            b.category.toLowerCase().contains(query) ||
            b.city.toLowerCase().contains(query) ||
            b.address.toLowerCase().contains(query);
        if (!matches) return false;
      }

      // Category
      if (cat.isNotEmpty && cat.toLowerCase() != 'all') {
        if (!_isCategoryMatch(cat, b.category)) return false;
      }

      // City
      if (city.isNotEmpty && city.toLowerCase() != 'all') {
        if (b.city.toLowerCase() != city.toLowerCase()) return false;
      }

      return true;
    }).toList();
  }

  bool _isCategoryMatch(String filterCategory, String itemCategory) {
    final f = filterCategory.trim().toLowerCase();
    final item = itemCategory.trim().toLowerCase();
    if (f.isEmpty || f == 'all') return true;
    if (f == item) return true;
    if (f == '${item}s' || item == '${f}s') return true;
    if (f == '${item}es' || item == '${f}es') return true;
    return f.startsWith(item) || item.startsWith(f);
  }

  void selectBusiness(BusinessModel business) {
    selectedBusiness.value = business;
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
    selectedState.value = 'All';
    selectedCity.value = 'All';
    filterController.activeCategory.value = cat;
    peopleList.clear();
    fetchPeople(
      query: cat.toLowerCase(),
      page: 1,
      limit: 20,
    );
    fetchAvailableStates();
  }

  void resetCityFilter() {
    selectedCity.value = 'All';
  }

  Future<void> selectState(String state) async {
    selectedState.value = state;
    selectedCity.value = 'All';
    if (state != 'All') {
      await fetchCitiesForSelectedState(state);
    } else {
      apiCitiesForState.clear();
    }
    final cat = selectedCategory.value;
    await fetchPeople(
      query: cat.isNotEmpty && cat.toLowerCase() != 'all' ? cat.toLowerCase() : 'advocate',
      page: 1,
      limit: 20,
      state: state != 'All' ? state : null,
    );
  }

  Future<void> selectCity(String city) async {
    selectedCity.value = city;
    final cat = selectedCategory.value;
    await fetchPeople(
      query: cat.isNotEmpty && cat.toLowerCase() != 'all' ? cat.toLowerCase() : 'advocate',
      page: 1,
      limit: 20,
      state: selectedState.value != 'All' ? selectedState.value : null,
      city: city != 'All' ? city : null,
    );
  }

  Future<void> resetListingFilters() async {
    selectedState.value = 'All';
    selectedCity.value = 'All';
    apiCitiesForState.clear();
    final cat = selectedCategory.value;
    await fetchPeople(
      query: cat.isNotEmpty && cat.toLowerCase() != 'all' ? cat.toLowerCase() : 'advocate',
      page: 1,
      limit: 20,
    );
  }

  void clearSearch() {
    searchInputController.clear();
    searchQuery.value = '';
  }
}
