import 'dart:io';

class Report {
  String name;
  String description;
  double latitude;
  double longitude;
  String place;
  String registeredBy;
  String address;
  int place_id;
  int id;
  List<String> images;

  Report({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.address,
    required this.registeredBy,
    required this.place_id,
    required this.id,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'place': place,
      'registeredBy': registeredBy,
      'address': address,
      'place_id': place_id,
      'images': images,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = List<String>.from(
        json['images'].map((item) => item.toString()),
      );
    }
    return Report(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      place: json['place'] ?? "Cidade indefinida",
      address: json['address'] ?? "Endereço indefinido",
      registeredBy: json['registered_by'].toString() ?? "0",
      place_id: json['place_id'] ?? 1,
      id: json['id'] ?? 1,
      images: imagesList,
    );
  }
}
