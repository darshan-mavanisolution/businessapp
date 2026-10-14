import '../models/business_model.dart';
import '../models/category_model.dart';

abstract class IBusinessRepository {
  List<BusinessModel> getAllBusinesses();
  BusinessModel? getBusinessById(String id);
  List<BusinessModel> getBusinessesByCategory(String category);
  List<BusinessModel> searchBusinesses({
    String query = '',
    String category = '',
    String city = '',
    double? minRating,
    bool? openOnly,
  });
  List<CategoryModel> getCategories();
  void setBusinesses(List<BusinessModel> list);
  void setCategories(List<CategoryModel> list);
}

class BusinessRepository implements IBusinessRepository {
  final List<BusinessModel> _businesses = [];
  final List<CategoryModel> _categories = [];

  BusinessRepository({List<BusinessModel>? businesses, List<CategoryModel>? categories}) {
    if (businesses != null) _businesses.addAll(businesses);
    if (categories != null) _categories.addAll(categories);
  }

  @override
  void setBusinesses(List<BusinessModel> list) {
    _businesses.clear();
    _businesses.addAll(list);
  }

  @override
  void setCategories(List<CategoryModel> list) {
    _categories.clear();
    _categories.addAll(list);
  }

  @override
  List<BusinessModel> getAllBusinesses() {
    return List.unmodifiable(_businesses);
  }

  @override
  BusinessModel? getBusinessById(String id) {
    try {
      return _businesses.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<BusinessModel> getBusinessesByCategory(String category) {
    if (category.isEmpty || category.toLowerCase() == 'all') {
      return getAllBusinesses();
    }
    return _businesses
        .where((b) => b.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  List<BusinessModel> searchBusinesses({
    String query = '',
    String category = '',
    String city = '',
    double? minRating,
    bool? openOnly,
  }) {
    return _businesses.where((b) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchesQuery = b.name.toLowerCase().contains(q) ||
            b.specialty.toLowerCase().contains(q) ||
            b.category.toLowerCase().contains(q) ||
            b.address.toLowerCase().contains(q) ||
            b.city.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }

      if (category.isNotEmpty && category.toLowerCase() != 'all') {
        if (b.category.toLowerCase() != category.toLowerCase()) {
          return false;
        }
      }

      if (city.isNotEmpty && city.toLowerCase() != 'all') {
        if (b.city.toLowerCase() != city.toLowerCase()) {
          return false;
        }
      }

      if (minRating != null && minRating > 0) {
        if (b.rating < minRating) {
          return false;
        }
      }

      if (openOnly == true) {
        if (!b.isOpen) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  List<CategoryModel> getCategories() {
    return List.unmodifiable(_categories);
  }
}
