import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository repository;

  ReportCubit(this.repository) : super(const ReportState());

  Future<void> sendReport(Report report) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, error: null));

    try {
      await repository.sendReport(report);
      emit(state.copyWith(isLoading: false, isSuccess: true, error: "Problema reportado com sucesso"));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void reset() => emit(const ReportState());
}
