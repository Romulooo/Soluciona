class Report {
  String name;
  String description;
  String latitude;
  String longitude;
  String place;
  String registeredBy;

  Report({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.registeredBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'place': place,
      'registeredBy': registeredBy,
    };
  }
}
