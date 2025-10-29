import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soluciona/data/providers/report_api_provider.dart';
import 'package:soluciona/data/repositories/report_repository.dart';
import 'package:soluciona/map/map.dart';
import 'package:soluciona/report/report_cubit.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MapCubit()),
        BlocProvider(
          create: (_) => ReportCubit(ReportRepository(ReportApiProvider())),
        ),
      ],
      child: const MapView(),
    );
  }
}
