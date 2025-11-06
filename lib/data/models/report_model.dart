class Report {
  String name;
  String description;
  double latitude;
  double longitude;
  String place;
  String registeredBy;
  String address;
  int place_id;

  Report({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.address,
    required this.registeredBy,
    required this.place_id
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
      'place_id': place_id
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
  return Report(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    place: json['place'] ?? "Cidade indefinida",
    address: json['address'] ?? "Endereço indefinido",
    registeredBy: json['registered_by'] ?? "0",
    place_id: json['place_id'] ?? 1,
  );
}
}
