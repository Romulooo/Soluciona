import 'dart:io';

import '../models/report_model.dart';
import '../providers/report_api_provider.dart';

class ReportRepository {
  final ReportApiProvider apiProvider;

  ReportRepository(this.apiProvider);

  Future<String> sendReport(Report report) async {
    final id = await apiProvider.sendReport(report);
    return id;
  }

  Future<void> sendImage(File imagePath, String id) async {
    await apiProvider.sendImage(imagePath, id);
  }
}
