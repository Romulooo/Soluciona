import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/report_model.dart';

class ReportApiProvider {
  final String apiUrl = '<URL DA API>';

  Future<void> sendReport(Report report) async {
    final url = Uri.parse('$apiUrl/reports');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(report.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Falha ao enviar: ${response.body}');
    }
  }
}
