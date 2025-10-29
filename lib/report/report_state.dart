// lib/logic/report/report_state.dart
import 'package:equatable/equatable.dart';

class ReportState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const ReportState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  ReportState copyWith({bool? isLoading, bool? isSuccess, String? error}) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, error];
}
