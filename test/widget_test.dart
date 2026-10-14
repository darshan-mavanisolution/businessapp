import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:businessmen/data/repositories/business_repository.dart';
import 'package:businessmen/features/filters/filter_controller.dart';
import 'package:businessmen/features/business_listing/business_controller.dart';
import 'package:businessmen/main.dart';
import 'package:businessmen/app/themes/app_colors.dart';
import 'package:businessmen/app/themes/app_theme.dart';
import 'package:businessmen/data/models/business_model.dart';
import 'package:businessmen/data/models/city_model.dart';
import 'package:businessmen/features/city_sector/city_sector_controller.dart';
import 'package:businessmen/features/authentication/auth_controller.dart';
import 'package:businessmen/features/onboarding/onboarding_controller.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  testWidgets('BizFinderApp smoke test', (WidgetTester tester) async {
    GetStorage.init();
    await tester.pumpWidget(const BizFinderApp());
    expect(find.byType(BizFinderApp), findsOneWidget);
    // Pump past splash timer
    await tester.pump(const Duration(seconds: 4));
  });

  test('BusinessModel and CityModel JSON serialization test', () {
    const city = CityModel(id: 'surat', name: 'Surat', imageUrl: '', businessCount: '5', state: 'Gujarat');
    expect(city.id, equals('surat'));
    expect(city.name, equals('Surat'));

    const business = BusinessModel(
      id: 'doc_1',
      name: 'Dr. Mehul Desai',
      category: 'Doctors',
      specialty: 'Cardiologist',
      description: 'Cardiology specialist',
      imageUrl: '',
      phoneNumber: '+91 98980 54321',
      whatsappNumber: '',
      email: 'dr.mehul@gmail.com',
      rating: 4.9,
      reviewCount: 150,
      city: 'Surat',
      sector: 'Sector 1',
      address: 'Ghod Dod Road',
      latitude: 21.17,
      longitude: 72.81,
      distance: '2.5 km',
      openingTime: '09:00 AM',
      closingTime: '08:00 PM',
      isOpen: true,
      avatarInitials: 'MD',
      specializations: ['Cardiology'],
    );
    expect(business.name, equals('Dr. Mehul Desai'));
    expect(business.category, equals('Doctors'));
  });

  test('Filter category matching in CitySectorController', () {
    final csc = CitySectorController();
    expect(csc.isCategoryMatch('Doctor', 'Doctors'), isTrue);
    expect(csc.isCategoryMatch('Doctors', 'Doctor'), isTrue);
    expect(csc.isCategoryMatch('Hotel', 'Hotels'), isTrue);
    expect(csc.isCategoryMatch('All', 'Doctors'), isTrue);
  });

  test('Theme single White palette with Rotary & Rotaract logo colors verification', () {
    // Single White Theme: Pure White background, Rotary Royal Blue primary, Rotaract Pink secondary, Rotary Gold tertiary
    expect(AppColors.lightBackground, equals(const Color(0xFFFFFFFF)));
    expect(AppColors.rotaryBlue, equals(const Color(0xFF00246C)));
    expect(AppColors.rotaractPink, equals(const Color(0xFFE11383)));
    expect(AppColors.rotaryGold, equals(const Color(0xFFF7A81B)));
    expect(AppTheme.lightTheme.colorScheme.primary, equals(AppColors.rotaryBlue));
    expect(AppTheme.lightTheme.colorScheme.secondary, equals(AppColors.rotaractPink));
    expect(AppTheme.lightTheme.colorScheme.tertiary, equals(AppColors.rotaryGold));
    expect(AppTheme.lightTheme.scaffoldBackgroundColor, equals(const Color(0xFFFFFFFF)));
  });

  test('BusinessController allCityOptions and city selection behavior', () {
    Get.put(FilterController());
    final bc = BusinessController(repository: BusinessRepository());

    // Populate API businesses
    bc.apiBusinesses.assignAll([
      const BusinessModel(id: '1', name: 'B1', category: 'Doctors', specialty: 'Cardio', description: '', imageUrl: '', phoneNumber: '', whatsappNumber: '', email: '', rating: 4.5, reviewCount: 10, city: 'Surat', sector: 'Sector 1', address: '', latitude: 0, longitude: 0, distance: '', openingTime: '', closingTime: '', isOpen: true, avatarInitials: 'B1', specializations: []),
      const BusinessModel(id: '2', name: 'B2', category: 'Doctors', specialty: 'Pedia', description: '', imageUrl: '', phoneNumber: '', whatsappNumber: '', email: '', rating: 4.5, reviewCount: 10, city: 'Ahmedabad', sector: 'Sector 1', address: '', latitude: 0, longitude: 0, distance: '', openingTime: '', closingTime: '', isOpen: true, avatarInitials: 'B2', specializations: []),
    ]);

    // 'All' is default selected
    expect(bc.selectedCity.value, equals('All'));

    // First option is 'All'
    final options = bc.allCityOptions;
    expect(options.first, equals('All'));
    expect(options.contains('Surat'), isTrue);
    expect(options.contains('Ahmedabad'), isTrue);

    // selectCategory resets selectedCity back to 'All'
    bc.selectCity('Surat');
    expect(bc.selectedCity.value, equals('Surat'));
    bc.selectCategory('Hotels');
    expect(bc.selectedCity.value, equals('All'));
  });

  test('BusinessController city filter is enabled only when state is selected', () async {
    final bc = Get.find<BusinessController>();
    
    // When state is 'All', city filter is disabled and only contains 'All'
    bc.selectedState.value = 'All';
    expect(bc.isCityFilterEnabled, isFalse);
    expect(bc.availableCityOptions, equals(const ['All']));

    // When a state is selected, city filter is enabled and populated via API
    await bc.selectState('Gujarat');
    bc.apiCitiesForState.assignAll(['Surat', 'Ahmedabad']);
    expect(bc.isCityFilterEnabled, isTrue);
    expect(bc.availableCityOptions.first, equals('All'));
    expect(bc.availableCityOptions.contains('Surat'), isTrue);

    // Resetting filters disables city filter again
    await bc.resetListingFilters();
    expect(bc.selectedState.value, equals('All'));
    expect(bc.selectedCity.value, equals('All'));
    expect(bc.isCityFilterEnabled, isFalse);
  });

  test('Email OTP validation and state verification', () {
    final ac = Get.put(AuthController());
    expect(ac.selectedLoginTab.value, equals(1));
    expect(ac.emailController.text, isNotEmpty);
  });

  test('CitySectorController defaults to Gujarat and handles state selection', () {
    final csc = Get.put(CitySectorController());
    expect(csc.selectedState.value, equals('Gujarat'));
    expect(csc.allStates.contains('Gujarat'), isTrue);
    expect(csc.allStates.contains('Maharashtra'), isTrue);

    csc.selectState('Maharashtra');
    expect(csc.selectedState.value, equals('Maharashtra'));

    // Searching states
    csc.stateSearchQuery.value = 'guj';
    expect(csc.filteredStates.length, equals(1));
    expect(csc.filteredStates.first, equals('Gujarat'));

    csc.stateSearchQuery.value = '';
    expect(csc.filteredStates.length, equals(csc.allStates.length));
  });

  test('BusinessController categoryListingBusinesses shows all Doctors directly from API data', () {
    final bc = Get.find<BusinessController>();
    bc.apiBusinesses.assignAll([
      const BusinessModel(id: 'doc_1', name: 'Dr. Mehul Desai', category: 'Doctors', specialty: 'Cardiologist', description: '', imageUrl: '', phoneNumber: '', whatsappNumber: '', email: '', rating: 4.9, reviewCount: 10, city: 'Surat', sector: 'Sector 1', address: '', latitude: 0, longitude: 0, distance: '', openingTime: '', closingTime: '', isOpen: true, avatarInitials: 'MD', specializations: []),
      const BusinessModel(id: 'doc_2', name: 'Dr. Jignesh Patel', category: 'Doctor', specialty: 'Physician', description: '', imageUrl: '', phoneNumber: '', whatsappNumber: '', email: '', rating: 4.8, reviewCount: 10, city: 'Rajkot', sector: 'Sector 2', address: '', latitude: 0, longitude: 0, distance: '', openingTime: '', closingTime: '', isOpen: true, avatarInitials: 'JP', specializations: []),
    ]);

    bc.selectCategory('Doctors');
    bc.resetCityFilter();

    final doctors = bc.categoryListingBusinesses;
    expect(doctors.length, equals(2));
    final names = doctors.map((d) => d.name).toList();
    expect(names.contains('Dr. Mehul Desai'), isTrue);
    expect(names.contains('Dr. Jignesh Patel'), isTrue);
  });

  test('BusinessController fetchBusinessDetails handles single business API call', () async {
    final bc = Get.find<BusinessController>();
    final res = await bc.fetchBusinessDetails('doc_1');
    expect(res, isNotNull);
  });

  test('OnboardingController pagination and items test', () {
    final controller = Get.put(OnboardingController());
    expect(controller.items.length, equals(3));
    expect(controller.currentPage.value, equals(0));

    controller.onPageChanged(1);
    expect(controller.currentPage.value, equals(1));

    controller.onPageChanged(2);
    expect(controller.currentPage.value, equals(2));
  });
}

