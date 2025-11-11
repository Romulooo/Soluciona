import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:soluciona/main.dart';
import 'dart:convert';
import '../models/report_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReportApiProvider {
  final String apiUrl = dotenv.get("API_URL");

  Future<String> sendReport(Report report) async {
    final url = Uri.parse('$apiUrl/reports');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $access_token',
      },

      body: jsonEncode(report.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Falha ao enviar: ${response.body}');
    }

    final data = jsonDecode(response.body);

    print("------------------- RESPOSTA DA API: " + data.toString());

    return data['report']['id'].toString();
  }

  Future<void> sendImage(File imagePath, String id) async {
    final url = Uri.parse('$apiUrl/reports/$id/upload-image');
    final request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    });

    request.files.add(
      await http.MultipartFile.fromPath('image', imagePath.path),
    );

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      final respStr = await response.stream.bytesToString();
      throw Exception('Falha ao enviar imagem: $respStr');
    }
  }
}
