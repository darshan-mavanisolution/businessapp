import 'package:get/get.dart';

class FilterController extends GetxController {
  // Active applied filter values (Category & City)
  final RxString activeCategory = 'All'.obs;
  final RxString activeCity = 'Surat'.obs;

  // Draft filter values (used while in Filter modal/screen)
  final RxString draftCategory = 'All'.obs;
  final RxString draftCity = 'Surat'.obs;

  void openFilterScreen() {
    draftCategory.value = activeCategory.value;
    draftCity.value = activeCity.value;
  }

  void selectDraftCategory(String cat) {
    draftCategory.value = cat;
  }

  void selectDraftCity(String city) {
    draftCity.value = city;
  }

  void clearDraftFilters() {
    draftCategory.value = 'All';
    draftCity.value = 'Surat';
  }

  void applyDraftFilters() {
    activeCategory.value = draftCategory.value;
    activeCity.value = draftCity.value;
  }

  void resetAllActiveFilters() {
    activeCategory.value = 'All';
    activeCity.value = 'Surat';
  }

  void setCity(String city) {
    activeCity.value = city;
  }

  void setCategory(String category) {
    activeCategory.value = category;
  }
}
