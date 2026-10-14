class SectorModel {
  final String id;
  final String name;
  final String businessCount;

  const SectorModel({
    required this.id,
    required this.name,
    required this.businessCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'businessCount': businessCount,
    };
  }

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    final rawCount = json['businessCount'] ??
        json['businessesCount'] ??
        json['count'] ??
        json['total'] ??
        json['totalBusinesses'];
    String formattedCount;
    if (rawCount != null) {
      final s = rawCount.toString();
      formattedCount = s.toLowerCase().contains('business') ? s : '$s+ Businesses';
    } else {
      formattedCount = '0 Businesses';
    }

    return SectorModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['sector']?.toString() ?? '',
      businessCount: formattedCount,
    );
  }
}
