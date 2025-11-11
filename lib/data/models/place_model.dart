class Place {
  String? town_name;
  String? institution_name;
  String type;
  int place_id;

  Place({
    this.town_name,
    this.institution_name,
    required this.type,
    required this.place_id
  });

  factory Place.fromList(List<dynamic> list) {
  return Place(
    type: list[2],
    town_name: list[2] == "Cidade" ? list[1] : null,
    institution_name: list[2] == "Campus" ? list[1] : null,
    place_id: list[0] ?? 1,
  );
}
}
