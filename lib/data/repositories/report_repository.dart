import '../models/report_model.dart';
import '../providers/report_api_provider.dart';

class ReportRepository {
  final ReportApiProvider apiProvider;

  ReportRepository(this.apiProvider);

  Future<void> sendReport(Report report) async {
    await apiProvider.sendReport(report);
  }
}
