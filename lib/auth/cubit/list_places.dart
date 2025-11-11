import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:soluciona/data/models/place_model.dart';
import 'package:soluciona/main.dart';

Future<List<Place>> listPlaces(String type) async {
  http.Client client = http.Client();

  try {
    final response = await client.get(
      Uri.parse("${dotenv.get("API_URL")}/places"),
    );

    final data = jsonDecode(response.body);

    List<Place> places = [];

    if (response.statusCode == 200) {
      for (List place in data) {
        print(Place.fromList(place));
        place[2] == type? places.add(Place.fromList(place)): ();
      }
      print(places);
      return places;
    } else {
      throw Exception("Erro ao nomear local da conta.");
    }
  } catch (e) {
    throw Exception("Erro ao nomear local da conta.");
  }
}
