import '../../core/services/remote_service.dart';

class BusinessModel {
  final String id;
  final String name;
  final String category;
  final String specialty;
  final String description;
  final String imageUrl;
  final String phoneNumber;
  final String whatsappNumber;
  final String email;
  final double rating;
  final int reviewCount;
  final String state;
  final String city;
  final String sector;
  final String address;
  final double latitude;
  final double longitude;
  final String distance;
  final String openingTime;
  final String closingTime;
  final bool isOpen;
  final String avatarInitials;
  final List<String> specializations;

  final String? businessName;
  final String? personalPhone;
  final String? personalEmail;
  final String? businessPhone;
  final String? businessEmail;
  final String? ownerId;

  const BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.specialty,
    required this.description,
    required this.imageUrl,
    required this.phoneNumber,
    this.whatsappNumber = '',
    required this.email,
    required this.rating,
    required this.reviewCount,
    this.state = 'Gujarat',
    required this.city,
    this.sector = 'Sector 1',
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.openingTime,
    required this.closingTime,
    required this.isOpen,
    required this.avatarInitials,
    this.specializations = const [],
    this.businessName,
    this.personalPhone,
    this.personalEmail,
    this.businessPhone,
    this.businessEmail,
    this.ownerId,
  });

  String get displayBusinessName =>
      (businessName != null && businessName!.isNotEmpty) ? businessName! : name;

  String get displayPersonalPhone =>
      (personalPhone != null && personalPhone!.isNotEmpty) ? personalPhone! : phoneNumber;

  String get displayPersonalEmail =>
      (personalEmail != null && personalEmail!.isNotEmpty) ? personalEmail! : email;

  String get displayBusinessPhone =>
      (businessPhone != null && businessPhone!.isNotEmpty) ? businessPhone! : phoneNumber;

  String get displayBusinessEmail =>
      (businessEmail != null && businessEmail!.isNotEmpty) ? businessEmail! : email;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'specialty': specialty,
      'description': description,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'rating': rating,
      'reviewCount': reviewCount,
      'state': state,
      'city': city,
      'sector': sector,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isOpen': isOpen,
      'avatarInitials': avatarInitials,
      'specializations': specializations,
      'businessName': businessName,
      'personalPhone': personalPhone,
      'personalEmail': personalEmail,
      'businessPhone': businessPhone,
      'businessEmail': businessEmail,
      'ownerId': ownerId,
    };
  }

  static String _extractState(String address, String city) {
    final lowerAddr = '$address $city'.toLowerCase();
    for (final s in [
      'Gujarat', 'Maharashtra', 'Rajasthan', 'Madhya Pradesh', 'Karnataka',
      'Tamil Nadu', 'Uttar Pradesh', 'Delhi', 'Punjab', 'Haryana',
      'West Bengal', 'Kerala', 'Goa', 'Andhra Pradesh', 'Telangana',
      'Bihar', 'Odisha', 'Assam', 'Uttarakhand', 'Himachal Pradesh'
    ]) {
      if (lowerAddr.contains(s.toLowerCase())) return s;
    }
    if (['surat', 'ahmedabad', 'rajkot', 'vadodara', 'bhavnagar', 'jamnagar', 'gandhinagar'].contains(city.trim().toLowerCase())) {
      return 'Gujarat';
    }
    if (['mumbai', 'pune', 'nagpur', 'nashik', 'aurangabad', 'thane'].contains(city.trim().toLowerCase())) {
      return 'Maharashtra';
    }
    return 'Gujarat';
  }

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? firstBiz;
    if (json['businesses'] is List && (json['businesses'] as List).isNotEmpty) {
      final bList = (json['businesses'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      Map<String, dynamic>? preferred;
      for (final b in bList) {
        if (b['isMatch'] == true && b['specialty'] != null && b['specialty'].toString().trim().isNotEmpty) {
          preferred = b;
          break;
        }
      }
      if (preferred == null) {
        for (final b in bList) {
          if (b['specialty'] != null && b['specialty'].toString().trim().isNotEmpty) {
            preferred = b;
            break;
          }
        }
      }
      if (preferred == null) {
        for (final b in bList) {
          if (b['isMatch'] == true) {
            preferred = b;
            break;
          }
        }
      }
      if (preferred == null && bList.isNotEmpty) {
        preferred = bList.first;
      }
      firstBiz = preferred;
    }

    final cityVal = (json['city'] ?? json['cityName'] ?? firstBiz?['city'] ?? '').toString();
    final addressVal = (json['address'] ?? json['location'] ?? firstBiz?['address'] ?? '').toString();
    final rawState = json['state'] ?? json['stateName'] ?? firstBiz?['state'];
    final stateVal = (rawState != null && rawState.toString().trim().isNotEmpty)
        ? rawState.toString().trim()
        : _extractState(addressVal, cityVal);

    final rawName = (json['name'] ?? json['fullName'] ?? json['businessName'] ?? json['title'] ?? firstBiz?['name'] ?? '').toString();

    String rawCategory = (firstBiz?['category'] ?? json['category'] ?? json['profession'] ?? json['role'] ?? json['type'] ?? '').toString();
    if (rawCategory.isEmpty && json['categories'] is List && (json['categories'] as List).isNotEmpty) {
      rawCategory = (json['categories'] as List).first.toString();
    }

    String specialtyFromFirstBiz = (firstBiz?['specialty'] ?? '').toString();
    if (specialtyFromFirstBiz.isEmpty && firstBiz?['specializations'] is List && (firstBiz!['specializations'] as List).isNotEmpty) {
      specialtyFromFirstBiz = (firstBiz['specializations'] as List).join(', ');
    }
    final rawSpecialty = (json['specialty'] ?? json['designation'] ?? json['specialization'] ?? (specialtyFromFirstBiz.isNotEmpty ? specialtyFromFirstBiz : null) ?? (rawCategory.isNotEmpty ? rawCategory : '')).toString();
    final rawPhone = (json['phoneNumber'] ?? json['phone'] ?? json['mobile'] ?? json['contact'] ?? json['personalPhone'] ?? firstBiz?['personalPhone'] ?? firstBiz?['phoneNumber'] ?? firstBiz?['businessPhone'] ?? '').toString();
    final rawEmail = (json['email'] ?? json['personalEmail'] ?? firstBiz?['personalEmail'] ?? firstBiz?['email'] ?? firstBiz?['ownerEmail'] ?? firstBiz?['businessEmail'] ?? '').toString();

    var rawImage = (json['imageUrl'] ?? json['avatar'] ?? json['avatarUrl'] ?? json['photo'] ?? json['image'] ?? json['profileImage'] ?? firstBiz?['imageUrl'] ?? '').toString();
    if (rawImage.startsWith('/') && !rawImage.startsWith('//')) {
      final host = RemoteService.baseUrl.replaceAll('/api/v1', '');
      rawImage = '$host$rawImage';
    }

    String initials = (json['avatarInitials'] ?? firstBiz?['avatarInitials'] ?? '').toString();
    if (initials.isEmpty && rawName.isNotEmpty) {
      final parts = rawName.trim().split(RegExp(r'\s+'));
      if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts[0][0].toUpperCase();
      }
    }

    final List<String> specs = [];
    void addSpecString(dynamic val) {
      if (val == null) return;
      if (val is List) {
        for (final item in val) {
          if (item != null) addSpecString(item.toString());
        }
      } else if (val is String && val.trim().isNotEmpty) {
        for (final part in val.split(',')) {
          final trimmed = part.trim();
          if (trimmed.isNotEmpty && !specs.contains(trimmed)) {
            specs.add(trimmed);
          }
        }
      }
    }

    addSpecString(json['specializations']);
    addSpecString(json['specialization']);
    if (specs.isEmpty) {
      addSpecString(firstBiz?['specializations']);
      addSpecString(firstBiz?['specialization']);
    }
    if (json['categories'] is List) {
      for (final c in (json['categories'] as List)) {
        final cStr = c.toString().trim();
        if (cStr.isNotEmpty && !specs.contains(cStr)) specs.add(cStr);
      }
    }
    if (specs.isEmpty && rawSpecialty.isNotEmpty) {
      specs.add(rawSpecialty);
    }

    final bName = json['businessName']?.toString() ?? firstBiz?['businessName']?.toString() ?? firstBiz?['name']?.toString() ?? (rawName.isNotEmpty ? rawName : null);
    final bPhone = json['businessPhone']?.toString() ?? firstBiz?['businessPhone']?.toString() ?? rawPhone;
    final bEmail = json['businessEmail']?.toString() ?? firstBiz?['businessEmail']?.toString() ?? rawEmail;

    return BusinessModel(
      id: (json['personId'] ?? json['_id'] ?? json['id'] ?? (json['person'] is Map ? (json['person']['_id'] ?? json['person']['id']) : null) ?? firstBiz?['id'] ?? '').toString(),
      name: rawName,
      category: rawCategory,
      specialty: rawSpecialty,
      description: (json['description'] ?? json['desc'] ?? json['about'] ?? json['bio'] ?? firstBiz?['description'] ?? '').toString(),
      imageUrl: rawImage,
      phoneNumber: rawPhone,
      whatsappNumber: (json['whatsappNumber'] ?? json['whatsapp'] ?? firstBiz?['whatsappNumber'] ?? rawPhone).toString(),
      email: rawEmail,
      rating: (json['rating'] ?? firstBiz?['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] ?? json['reviewsCount'] ?? json['totalReviews'] ?? firstBiz?['reviewCount'] as num?)?.toInt() ?? 0,
      state: stateVal,
      city: cityVal,
      sector: (json['sector'] ?? json['sectorName'] ?? json['area'] ?? firstBiz?['sector'] ?? 'Sector 1').toString(),
      address: addressVal,
      latitude: (json['latitude'] ?? json['lat'] ?? firstBiz?['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] ?? json['lng'] ?? firstBiz?['longitude'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] ?? json['distanceKm'] ?? firstBiz?['distance'] ?? '').toString(),
      openingTime: (json['openingTime'] ?? firstBiz?['openingTime'] ?? '').toString(),
      closingTime: (json['closingTime'] ?? firstBiz?['closingTime'] ?? '').toString(),
      isOpen: json['isOpen'] ?? firstBiz?['isOpen'] ?? false,
      avatarInitials: initials,
      specializations: specs,
      businessName: bName,
      personalPhone: json['personalPhone']?.toString() ?? firstBiz?['personalPhone']?.toString() ?? rawPhone,
      personalEmail: json['personalEmail']?.toString() ?? firstBiz?['personalEmail']?.toString() ?? rawEmail,
      businessPhone: bPhone,
      businessEmail: bEmail,
      ownerId: (json['ownerId'] ?? firstBiz?['ownerId'] ?? json['userId'] ?? '').toString(),
    );
  }

  BusinessModel copyWith({
    String? id,
    String? name,
    String? category,
    String? specialty,
    String? description,
    String? imageUrl,
    String? phoneNumber,
    String? whatsappNumber,
    String? email,
    double? rating,
    int? reviewCount,
    String? state,
    String? city,
    String? sector,
    String? address,
    double? latitude,
    double? longitude,
    String? distance,
    String? openingTime,
    String? closingTime,
    bool? isOpen,
    String? avatarInitials,
    List<String>? specializations,
    String? businessName,
    String? personalPhone,
    String? personalEmail,
    String? businessPhone,
    String? businessEmail,
    String? ownerId,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      specialty: specialty ?? this.specialty,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      state: state ?? this.state,
      city: city ?? this.city,
      sector: sector ?? this.sector,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      isOpen: isOpen ?? this.isOpen,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      specializations: specializations ?? this.specializations,
      businessName: businessName ?? this.businessName,
      personalPhone: personalPhone ?? this.personalPhone,
      personalEmail: personalEmail ?? this.personalEmail,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
