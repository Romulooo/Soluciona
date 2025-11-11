import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:soluciona/data/models/place_model.dart';
import 'package:soluciona/main.dart';

Future<void> getPlace(int location_id) async {
  http.Client client = http.Client();

  try {
    final response = await client.get(
      Uri.parse("${dotenv.get("API_URL")}/places"),
    );

    final data = jsonDecode(response.body);

    late Place place;

    if (response.statusCode == 200) {
      for (List location in data) {
        if (location[0] == place_id) {
          switch (location[2]) {
            case "Campus":
              place = Place(
                type: location[2],
                place_id: location_id,
                institution_name: location[1],
              );
            default:
              place = Place(
                type: location[2],
                place_id: location_id,
                town_name: location[1],
              );
          }
        }
      }

      place_id = place.place_id;
      locationName = place.town_name ?? place.institution_name!;

      print(locationName);
    } else {
      throw Exception("Erro ao nomear local da conta.");
    }
  } catch (e) {
    throw Exception("Erro ao nomear local da conta.");
  }
}
