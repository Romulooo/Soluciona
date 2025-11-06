import 'package:http/http.dart' as http;
import 'package:soluciona/main.dart';
import 'dart:convert';
import '../models/report_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReportApiProvider {
  final String apiUrl = dotenv.get("API_URL");

  Future<void> sendReport(Report report) async {
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
  }
}
