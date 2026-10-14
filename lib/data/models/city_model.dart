class CityModel {
  final String id;
  final String name;
  final String imageUrl;
  final String state;
  final String businessCount;

  const CityModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.state = 'Gujarat',
    this.businessCount = '120+',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'state': state,
      'businessCount': businessCount,
    };
  }

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      state: json['state']?.toString() ?? 'Gujarat',
      businessCount: json['businessCount']?.toString() ?? '120+',
    );
  }
}
