import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/city_model.dart';
import '../../data/models/sector_model.dart';
import '../../data/models/business_model.dart';
import '../business_listing/business_controller.dart';
import '../filters/filter_controller.dart';

import '../../core/services/remote_service.dart';

const List<String> defaultIndianStates = [
  'Gujarat',
  'Maharashtra',
  'Rajasthan',
  'Madhya Pradesh',
  'Karnataka',
  'Tamil Nadu',
  'Uttar Pradesh',
  'Delhi',
  'Punjab',
  'Haryana',
  'West Bengal',
  'Kerala',
  'Goa',
  'Andhra Pradesh',
  'Telangana',
  'Bihar',
  'Odisha',
  'Assam',
  'Uttarakhand',
  'Himachal Pradesh',
  'Jharkhand',
  'Chhattisgarh',
];

class CitySectorController extends GetxController {
  // States
  final RxString selectedState = 'Gujarat'.obs;
  final RxList<String> allStates = <String>[...defaultIndianStates].obs;
  final TextEditingController stateSearchController = TextEditingController();
  final RxString stateSearchQuery = ''.obs;
  final RxBool isLoadingStates = false.obs;

  // Cities
  final TextEditingController citySearchController = TextEditingController();
  final RxString citySearchQuery = ''.obs;
  final Rx<CityModel> selectedCity = const CityModel(
    id: 'surat',
    name: 'Surat',
    imageUrl: 'https://images.unsplash.com/photo-1596176530529-78163a4f7af2?w=800&auto=format&fit=crop&q=80',
    state: 'Gujarat',
    businessCount: '0',
  ).obs;

  // Sectors
  final Rx<SectorModel> selectedSector = const SectorModel(
    id: 'sec_1',
    name: 'Sector 1',
    businessCount: '0',
  ).obs;

  // Active Category Filter (e.g. 'All', 'Doctor', 'Advocates', 'Restaurant', etc.)
  final RxString selectedCategory = 'All'.obs;

  // Sector Businesses Search
  final TextEditingController sectorSearchController = TextEditingController();
  final RxString sectorSearchQuery = ''.obs;

  // Live API States
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSectors = false.obs;
  final RxBool hasFetchedFromApi = false.obs;
  final RxList<CityModel> apiCities = <CityModel>[].obs;
  final RxList<SectorModel> apiSectors = <SectorModel>[].obs;
  final RxList<BusinessModel> apiSectorBusinesses = <BusinessModel>[].obs;

  List<String> get filteredStates {
    final q = stateSearchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return allStates;
    return allStates.where((s) => s.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    stateSearchController.addListener(() {
      stateSearchQuery.value = stateSearchController.text;
    });
    citySearchController.addListener(() {
      citySearchQuery.value = citySearchController.text;
    });
    sectorSearchController.addListener(() {
      sectorSearchQuery.value = sectorSearchController.text;
    });

    debounce(sectorSearchQuery, (_) {
      fetchBusinessesForSector();
    }, time: const Duration(milliseconds: 350));

    fetchStates();
    fetchCitiesForSelectedState();
    fetchCitySectors(city: selectedCity.value.name);
  }

  Future fetchStates({String search = ''}) async {
    isLoadingStates.value = true;
    final map = search.isNotEmpty ? {'search': search} : null;
    var res = await RemoteService.getStates(map: map);
    print("fetchStates Res--------->>>> $res");
    isLoadingStates.value = false;

    if (res != null && (res['success'] == true || res['status'] == 200)) {
      final list = (res['data'] ?? res['states'] ?? res) as List?;
      if (list != null && list.isNotEmpty) {
        final parsed = list.map((item) {
          if (item is Map) {
            return item['name']?.toString() ?? item['state']?.toString() ?? item.toString();
          }
          return item.toString();
        }).where((s) => s.isNotEmpty).toList();
        if (parsed.isNotEmpty) {
          allStates.assignAll(parsed);
        }
      }
    }
    if (!allStates.contains(selectedState.value)) {
      allStates.insert(0, selectedState.value);
    }
    return res;
  }

  Future selectState(String state) async {
    selectedState.value = state;
    citySearchController.clear();
    citySearchQuery.value = '';
    hasFetchedFromApi.value = false;
    apiCities.clear();
    await fetchCitiesForSelectedState();
  }

  Future fetchCitiesForSelectedState({String search = ''}) async {
    isLoading.value = true;
    final state = selectedState.value;
    final map = search.isNotEmpty ? {'search': search} : null;
    var res = await RemoteService.getCitiesByState(state: state, map: map);
    print("fetchCitiesForSelectedState ($state) Res--------->>>> $res");
    isLoading.value = false;

    if (res != null && (res['success'] == true || res['status'] == 200)) {
      final list = (res['data'] ?? res['cities'] ?? res) as List?;
      if (list != null && list.isNotEmpty) {
        final citiesList = list
            .map((c) => CityModel.fromJson(Map<String, dynamic>.from(c)))
            .toList();
        apiCities.assignAll(citiesList);
        if (apiCities.isNotEmpty &&
            !apiCities.any((c) => c.name.toLowerCase() == selectedCity.value.name.toLowerCase())) {
          selectedCity.value = apiCities.first;
        }
      } else {
        apiCities.clear();
      }
    } else {
      await fetchCities(map: {'state': state, if (search.isNotEmpty) 'search': search});
    }
    // Also fetch sectors for the selected city so sectors are pre-loaded
    fetchCitySectors(city: selectedCity.value.name);
    return res;
  }

  Future fetchCities({Map<String, dynamic>? map}) async {
    isLoading.value = true;
    var res = await RemoteService.getCities(map: map);
    print("fetchCities Res--------->>>> $res");
    isLoading.value = false;
    if (res != null && (res['success'] == true || res['status'] == 200)) {
      final list = (res['data'] ?? res['cities'] ?? res) as List?;
      if (list != null && list.isNotEmpty) {
        apiCities.assignAll(list.map((c) => CityModel.fromJson(Map<String, dynamic>.from(c))).toList());
        if (!apiCities.any((c) => c.name.toLowerCase() == selectedCity.value.name.toLowerCase())) {
          selectedCity.value = apiCities.first;
        }
      }
    }
    fetchCitySectors(city: selectedCity.value.name);
    return res;
  }

  Future fetchCitySectors({required String city, Map<String, dynamic>? map}) async {
    isLoadingSectors.value = true;
    try {
      var res = await RemoteService.getCitySectors(city: city, map: map);
      print("fetchCitySectors Res--------->>>> $res");
      if (res != null && (res['success'] == true || res['status'] == 200)) {
        final list = (res['data'] ?? res['sectors'] ?? res) as List?;
        if (list != null && list.isNotEmpty) {
          apiSectors.assignAll(list.map((s) => SectorModel.fromJson(Map<String, dynamic>.from(s))).toList());
          selectedSector.value = apiSectors.first;
        } else {
          apiSectors.clear();
        }
      } else {
        apiSectors.clear();
      }
      if (apiSectors.isNotEmpty) {
        fetchPeopleForSector();
      } else {
        apiSectorBusinesses.clear();
      }
      return res;
    } catch (e) {
      print("fetchCitySectors error: $e");
      apiSectors.clear();
      apiSectorBusinesses.clear();
      return null;
    } finally {
      isLoadingSectors.value = false;
    }
  }

  /// Optional filters matching the pickers:
  /// `curl "http://host/api/v1/people?query=...&state=Gujarat&city=Surat&sector=Sector%201&category=Advocates&latitude=21.17&longitude=72.83"`
  Future fetchPeopleForSector({Map<String, dynamic>? map}) async {
    isLoading.value = true;
    try {
      final String stateName = selectedState.value.isNotEmpty
          ? selectedState.value
          : (selectedCity.value.state.isNotEmpty ? selectedCity.value.state : 'Gujarat');
      final String cityName = selectedCity.value.name;
      final String sectorName = selectedSector.value.name;
      final String catName = selectedCategory.value;
      final String q = sectorSearchQuery.value.trim();

      final payload = map ?? <String, dynamic>{
        if (q.isNotEmpty) "query": q,
        if (stateName.isNotEmpty && stateName.toLowerCase() != 'all') "state": stateName,
        if (cityName.isNotEmpty && cityName.toLowerCase() != 'all') "city": cityName,
        if (sectorName.isNotEmpty && sectorName.toLowerCase() != 'all') "sector": sectorName,
        if (catName.isNotEmpty && catName.toLowerCase() != 'all') "category": catName,
        // "latitude": "21.17",
        // "longitude": "72.83",
      };

      print("fetchPeopleForSector payload: $payload");
      var res = await RemoteService.getPeople(map: payload);
      log("fetchPeopleForSector (getPeople) Res--------->>>> $res");

      if (res != null && (res['success'] == true || res['status'] == 200 || res['data'] != null || res is List)) {
        hasFetchedFromApi.value = true;
        List? rawList;
        if (res is List) {
          rawList = res;
        } else if (res is Map) {
          if (res['data'] is List) {
            rawList = res['data'];
          } else if (res['people'] is List) {
            rawList = res['people'];
          } else if (res['results'] is List) {
            rawList = res['results'];
          } else if (res['data'] is Map && (res['data'] as Map)['people'] is List) {
            rawList = (res['data'] as Map)['people'];
          }
        }

        if (rawList != null) {
          final List<BusinessModel> parsedUsers = [];
          for (final item in rawList) {
            if (item is Map) {
              final itemMap = Map<String, dynamic>.from(item);
              final businesses = itemMap['businesses'];
              final List<Map<String, dynamic>> bList = (businesses is List)
                  ? businesses.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
                  : <Map<String, dynamic>>[];

              // Pick the best matching business for this user
              Map<String, dynamic>? chosenBiz;
              if (catName.isNotEmpty && catName != 'All') {
                chosenBiz = bList.firstWhereOrNull(
                  (b) => isCategoryMatch(catName, (b['category'] ?? '').toString()) ||
                         (b['specialty'] != null && b['specialty'].toString().toLowerCase().contains(catName.toLowerCase())),
                );
              }
              if (q.isNotEmpty) {
                chosenBiz ??= bList.firstWhereOrNull(
                  (b) => (b['name'] ?? '').toString().toLowerCase().contains(q) ||
                         (b['specialty'] ?? '').toString().toLowerCase().contains(q) ||
                         (b['category'] ?? '').toString().toLowerCase().contains(q),
                );
              }
              chosenBiz ??= bList.firstWhereOrNull((b) => b['isMatch'] == true && b['specialty'] != null && b['specialty'].toString().trim().isNotEmpty);
              chosenBiz ??= bList.firstWhereOrNull((b) => b['specialty'] != null && b['specialty'].toString().trim().isNotEmpty);
              chosenBiz ??= bList.firstWhereOrNull((b) => b['isMatch'] == true);
              chosenBiz ??= bList.firstOrNull;

              if (chosenBiz != null && bList.isNotEmpty) {
                itemMap['businesses'] = [chosenBiz, ...bList.where((b) => b != chosenBiz)];
              }

              if ((itemMap['city'] == null || itemMap['city'].toString().isEmpty)) {
                itemMap['city'] = chosenBiz?['city'] ?? cityName;
              }
              if ((itemMap['state'] == null || itemMap['state'].toString().isEmpty)) {
                itemMap['state'] = chosenBiz?['state'] ?? stateName;
              }
              if ((itemMap['sector'] == null || itemMap['sector'].toString().isEmpty)) {
                itemMap['sector'] = chosenBiz?['sector'] ?? sectorName;
              }

              parsedUsers.add(BusinessModel.fromJson(itemMap));
            }
          }
          apiSectorBusinesses.assignAll(parsedUsers);
        } else {
          apiSectorBusinesses.clear();
        }
      } else {
        apiSectorBusinesses.clear();
      }
      return res;
    } catch (e) {
      print("fetchPeopleForSector error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Alias for backward compatibility
  Future fetchBusinessesForSector({Map<String, dynamic>? map}) => fetchPeopleForSector(map: map);

  @override
  void onClose() {
    stateSearchController.dispose();
    citySearchController.dispose();
    sectorSearchController.dispose();
    super.onClose();
  }

  List<CityModel> get allCities => apiCities;

  List<CityModel> get filteredCities {
    final query = citySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return allCities;
    return allCities.where((c) => c.name.toLowerCase().contains(query)).toList();
  }

  List<SectorModel> get allSectors => apiSectors;

  void selectCity(CityModel city) {
    selectedCity.value = city;
    selectedCategory.value = 'All';
    hasFetchedFromApi.value = false;
    apiSectors.clear();
    apiSectorBusinesses.clear();

    if (Get.isRegistered<BusinessController>()) {
      Get.find<BusinessController>().selectCity(city.name);
    }
    if (Get.isRegistered<FilterController>()) {
      Get.find<FilterController>().activeCity.value = city.name;
      Get.find<FilterController>().draftCity.value = city.name;
    }
    fetchCitySectors(city: city.name);
  }

  void selectSector(SectorModel sector) {
    selectedSector.value = sector;
    hasFetchedFromApi.value = false;
    apiSectorBusinesses.clear();
    fetchPeopleForSector();
  }

  void applyFilter({required String category, required String cityName}) {
    selectedCategory.value = category;
    hasFetchedFromApi.value = false;
    apiSectorBusinesses.clear();

    // If city name is provided, update selected city from available API cities
    if (cityName.isNotEmpty && cityName.toLowerCase() != 'all') {
      final cityMatch = apiCities.firstWhereOrNull(
        (c) => c.name.toLowerCase() == cityName.toLowerCase(),
      );
      if (cityMatch != null) {
        selectedCity.value = cityMatch;
      }
    }
    fetchPeopleForSector();
  }

  void clearCategoryFilter() {
    selectedCategory.value = 'All';
    if (Get.isRegistered<FilterController>()) {
      Get.find<FilterController>().activeCategory.value = 'All';
      Get.find<FilterController>().draftCategory.value = 'All';
    }
    fetchPeopleForSector();
  }

  /// Normalizes and matches categories (e.g. Doctor matches Doctors, Hotel matches Hotels)
  bool isCategoryMatch(String filterCategory, String itemCategory) {
    final f = filterCategory.trim().toLowerCase();
    final item = itemCategory.trim().toLowerCase();
    if (f.isEmpty || f == 'all') return true;
    if (f == item) return true;
    if (f == '${item}s' || item == '${f}s') return true;
    if (f == '${item}es' || item == '${f}es') return true;
    return f.startsWith(item) || item.startsWith(f);
  }

  List<BusinessModel> get businessesForSelectedSector {
    final categoryFilter = selectedCategory.value.trim();
    final query = sectorSearchQuery.value.trim().toLowerCase();

    List<BusinessModel> list = List.from(apiSectorBusinesses);

    // 1. Filter by category
    if (categoryFilter.isNotEmpty && categoryFilter.toLowerCase() != 'all') {
      final filtered = list.where((b) {
        return isCategoryMatch(categoryFilter, b.category) ||
            isCategoryMatch(categoryFilter, b.specialty) ||
            b.specializations.any((s) => isCategoryMatch(categoryFilter, s));
      }).toList();
      if (filtered.isNotEmpty) {
        list = filtered;
      }
    }

    // 2. Filter by search query if any
    if (query.isNotEmpty) {
      final queryFiltered = list.where((b) {
        return b.name.toLowerCase().contains(query) ||
            b.specialty.toLowerCase().contains(query) ||
            b.category.toLowerCase().contains(query) ||
            b.address.toLowerCase().contains(query) ||
            b.specializations.any((s) => s.toLowerCase().contains(query));
      }).toList();
      if (queryFiltered.isNotEmpty) {
        list = queryFiltered;
      }
    }

    return list;
  }

  void clearCitySearch() {
    citySearchController.clear();
    citySearchQuery.value = '';
  }

  void clearSectorSearch() {
    sectorSearchController.clear();
    sectorSearchQuery.value = '';
    fetchPeopleForSector();
  }
}
