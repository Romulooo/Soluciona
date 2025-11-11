import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository repository;

  ReportCubit(this.repository) : super(const ReportState());

  Future<String> sendReport(Report report) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, error: null));

    try {
      final id = await repository.sendReport(report);
      print(id);
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          error: "Problema reportado com sucesso",
        ),
      );
      return id;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
    return "";
  }

  Future<void> sendImage(File imagePath, String id) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, error: null));

    try {
      await repository.sendImage(imagePath, id);
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          error: "Imagem enviada com sucesso",
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void reset() => emit(const ReportState());
}
