import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soluciona/data/models/report_model.dart';
import 'package:soluciona/main.dart';
import 'package:soluciona/map/cubit/map_cubit.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:soluciona/map/view/components/info_popup.dart';
import 'package:soluciona/map/view/components/modal_bottom_sheet.dart';
import 'package:soluciona/report/report_cubit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  List<Report> _reports = [];
  bool readyList = true;

  PlatformFile? _selectedFile;

  final MapController mapController = MapController();
  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().getCurrentLocation();
  }

  Future<void> _selecionarArquivo() async {
    await [Permission.storage].request();

    FilePickerResult? resultado = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
      withData: true,
    );

    if (resultado != null && resultado.files.isNotEmpty) {
      setState(() {
        _selectedFile = resultado.files.first;
      });
    } else {
      setState(() {
        _selectedFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        actions: [
          Column(
            children: [
              Icon(Icons.person, color: darkBlue, size: 34),
              Text(appUsername),
            ],
          ),
          SizedBox(width: 12),
        ],
      ),

      floatingActionButton: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          if (state is MapSuccess) {
            return FloatingActionButton(
              backgroundColor: white,
              shape: CircleBorder(),
              splashColor: lightBlue,
              onPressed: () {
                context.read<MapCubit>().getCurrentLocation();
              },
              child: Icon(Icons.my_location, color: darkBlue),
            );
          } else {
            return FloatingActionButton(
              backgroundColor: white,
              shape: CircleBorder(),
              splashColor: lightBlue,
              onPressed: () {},
              child: CircularProgressIndicator(color: darkBlue),
            );
          }
        },
      ),

      body: BlocListener<MapCubit, MapState>(
        listenWhen: (previous, current) {
          return (previous is MapLoading && current is MapSuccess) ||
              current is MapFailure;
        },
        listener: (context, state) async {
          if (state is MapSuccess) {
            mapController.move(state.location, 15.0);

            await context.read<MapCubit>().getReports(state.location, _reports);

            setState(() {
              _reports = _reports;
            });
          } else if (state is MapFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                onTap: (tapPosition, point) async {
                  final place = await context.read<MapCubit>().getPlace(point);

                  print(locationName);
                  print(place["town"]);

                  if (place["town"] == locationName) {
                    context.read<MapCubit>().reportPin(point);
                  }
                },

                initialCenter: const LatLng(0, 0),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?key=${dotenv.get("API_KEY")}',
                  userAgentPackageName: 'com.example.soluciona',
                ),

                MarkerLayer(
                  markers: List.generate(_reports.length, (index) {
                    Report report = _reports[index];

                    return Marker(
                      point: LatLng(report.latitude, report.longitude),
                      child: GestureDetector(
                        onTap: () async {
                          final mapCubit = context.read<MapCubit>();
                          final state = mapCubit.state;

                          if (state is MapSuccess) {
                            await mapCubit.getReports(state.location, _reports);

                            report = await mapCubit.viewReport(
                              state.location,
                              report.id,
                            );

                            setState(() {
                              report = report;
                            });
                          }
                          InfoPopup(context, report);
                        },
                        child: Icon(
                          Icons.report_problem,
                          color: Colors.red,
                          shadows: [
                            Shadow(color: white, blurRadius: 1),
                            Shadow(color: white, blurRadius: 1),
                            Shadow(color: white, blurRadius: 1),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                BlocBuilder<MapCubit, MapState>(
                  builder: (context, state) {
                    if (state is! MapSuccess) {
                      return const MarkerLayer(markers: []);
                    }

                    final List<Marker> markers = [];

                    markers.add(
                      Marker(
                        width: 80,
                        height: 80,
                        rotate: true,
                        point: state.location,
                        child: Icon(
                          Icons.person_pin_circle,
                          color: mediumBlue,
                          shadows: [
                            Shadow(color: white, blurRadius: 1),
                            Shadow(color: white, blurRadius: 1),
                            Shadow(color: white, blurRadius: 1),
                          ],
                          size: 40,
                        ),
                      ),
                    );

                    if (state.reportPin != null) {
                      markers.add(
                        Marker(
                          width: 80,
                          height: 80,
                          rotate: true,
                          point: state.reportPin!,
                          child: GestureDetector(
                            /*onLongPress: () {
                              context.read<MapCubit>().clearPin();
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pin removido'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },*/
                            onTap: () async {
                              final place = await context
                                  .read<MapCubit>()
                                  .getPlace(state.reportPin!);
                              final TextEditingController _reportController =
                                  TextEditingController();
                              final TextEditingController
                              _descriptionController = TextEditingController();

                              final TextEditingController _roadController =
                                  TextEditingController(text: place["road"]);
                              final TextEditingController _suburbController =
                                  TextEditingController(text: place["suburb"]);

                              await Future.delayed(
                                const Duration(milliseconds: 300),
                              );
                              if (!context.mounted)
                                return; // Pra esperar o contexto se adequar ao async

                              final parentContext = context;

                              showPopupCard(
                                context: context,
                                builder: (popupContext) {
                                  return PopupCard(
                                    elevation: 8,
                                    color: white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: SizedBox(
                                      width: 450,
                                      height: 500,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Reportar Problema',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 20),

                                            // Rua e Bairro
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextSelectionTheme(
                                                    data:
                                                        TextSelectionThemeData(
                                                          selectionColor:
                                                              lightBlue
                                                                  .withValues(
                                                                    alpha: 0.5,
                                                                  ),
                                                        ),
                                                    child: TextField(
                                                      controller:
                                                          _roadController,
                                                      minLines: 1,
                                                      maxLines: 4,
                                                      maxLength: 40,
                                                      decoration: InputDecoration(
                                                        floatingLabelStyle:
                                                            TextStyle(
                                                              color: darkBlue,
                                                            ),
                                                        labelText: "Rua",
                                                        filled: true,
                                                        fillColor: const Color(
                                                          0xFFF2F5F9,
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color:
                                                                    Color.fromARGB(
                                                                      255,
                                                                      60,
                                                                      60,
                                                                      60,
                                                                    ),
                                                                width: 2,
                                                              ),
                                                        ),
                                                      ),
                                                      cursorColor: darkBlue,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: TextSelectionTheme(
                                                    data:
                                                        TextSelectionThemeData(
                                                          selectionColor:
                                                              lightBlue
                                                                  .withValues(
                                                                    alpha: 0.5,
                                                                  ),
                                                        ),
                                                    child: TextField(
                                                      controller:
                                                          _suburbController,
                                                      minLines: 1,
                                                      maxLines: 4,
                                                      maxLength: 30,
                                                      decoration: InputDecoration(
                                                        floatingLabelStyle:
                                                            TextStyle(
                                                              color: darkBlue,
                                                            ),
                                                        labelText: "Bairro",
                                                        filled: true,
                                                        fillColor: const Color(
                                                          0xFFF2F5F9,
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color:
                                                                    Color.fromARGB(
                                                                      255,
                                                                      60,
                                                                      60,
                                                                      60,
                                                                    ),
                                                                width: 2,
                                                              ),
                                                        ),
                                                      ),
                                                      cursorColor: darkBlue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 8),

                                            // Problema
                                            TextSelectionTheme(
                                              data: TextSelectionThemeData(
                                                selectionColor: lightBlue
                                                    .withValues(alpha: 0.5),
                                              ),
                                              child: TextField(
                                                controller: _reportController,
                                                maxLength: 30,
                                                decoration: InputDecoration(
                                                  floatingLabelStyle: TextStyle(
                                                    color: darkBlue,
                                                  ),
                                                  labelText: "Problema",
                                                  prefixIcon: const Icon(
                                                    Icons.report_problem_sharp,
                                                  ),
                                                  filled: true,
                                                  fillColor: const Color(
                                                    0xFFF2F5F9,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    60,
                                                                    60,
                                                                    60,
                                                                  ),
                                                              width: 2,
                                                            ),
                                                      ),
                                                ),
                                                cursorColor: darkBlue,
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            // Descrição
                                            TextSelectionTheme(
                                              data: TextSelectionThemeData(
                                                selectionColor: lightBlue
                                                    .withValues(alpha: 0.5),
                                              ),
                                              child: TextField(
                                                controller:
                                                    _descriptionController,
                                                minLines: 1,
                                                maxLines: 4,
                                                maxLength: 200,
                                                decoration: InputDecoration(
                                                  floatingLabelStyle: TextStyle(
                                                    color: darkBlue,
                                                  ),
                                                  labelText: "Descrição",
                                                  filled: true,
                                                  fillColor: const Color(
                                                    0xFFF2F5F9,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    60,
                                                                    60,
                                                                    60,
                                                                  ),
                                                              width: 2,
                                                            ),
                                                      ),
                                                ),
                                                cursorColor: darkBlue,
                                              ),
                                            ),

                                            const Spacer(),

                                            // Botão de escolher arquivo
                                            ElevatedButtonTheme(
                                              data: ElevatedButtonThemeData(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: darkBlue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _selecionarArquivo();
                                                },
                                                child: const Text(
                                                  'Escolher Arquivo',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            if (_selectedFile != null)
                                              SizedBox()
                                            else
                                              const Text(
                                                'Nenhum arquivo selecionado',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 12),
                                              ),

                                            const SizedBox(height: 10),

                                            // Botão Enviar
                                            SizedBox(
                                              width: double.infinity,
                                              height: 40,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: mediumBlue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  elevation: 3,
                                                ),
                                                onPressed: () async {
                                                  if (_roadController
                                                          .text
                                                          .isNotEmpty &&
                                                      _suburbController
                                                          .text
                                                          .isNotEmpty &&
                                                      _reportController
                                                          .text
                                                          .isNotEmpty &&
                                                      _descriptionController
                                                          .text
                                                          .isNotEmpty) {
                                                    final report = Report(
                                                      name:
                                                          _reportController
                                                              .text,
                                                      description:
                                                          _descriptionController
                                                              .text,
                                                      latitude:
                                                          state
                                                              .reportPin!
                                                              .latitude,
                                                      longitude:
                                                          state
                                                              .reportPin!
                                                              .longitude,
                                                      place:
                                                          place["town"] ??
                                                          "Cidade indefinida",
                                                      registeredBy: appUsername,
                                                      address:
                                                          "${_roadController.text}, ${_suburbController.text}",
                                                      place_id: place_id,
                                                      id: 0,
                                                    );

                                                    await parentContext
                                                        .read<ReportCubit>()
                                                        .sendReport(report);

                                                    await parentContext
                                                        .read<MapCubit>()
                                                        .getReports(
                                                          state.location,
                                                          _reports,
                                                        );

                                                    setState(() {
                                                      _reports = _reports;
                                                    });

                                                    Navigator.pop(popupContext);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                      popupContext,
                                                    ).clearSnackBars();
                                                    ScaffoldMessenger.of(
                                                      popupContext,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Preencha todos os campos corretamente",
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: const Text(
                                                  "Enviar",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                alignment: Alignment.center,
                                useSafeArea: true,
                                dimBackground: true,
                              );
                            },
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Text(
                                      "Relatar Problema",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Relatar Problema",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        foreground:
                                            Paint()
                                              ..style = PaintingStyle.stroke
                                              ..strokeWidth = 0.2
                                              ..color = const Color.fromARGB(
                                                255,
                                                255,
                                                255,
                                                255,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  shadows: [
                                    Shadow(color: white, blurRadius: 1),
                                    Shadow(color: white, blurRadius: 1),
                                    Shadow(color: white, blurRadius: 1),
                                  ],
                                  Icons.add_location_alt_rounded,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return MarkerLayer(markers: markers);
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 14,
              left: 14,
              child: FloatingActionButton(
                backgroundColor: white,
                shape: const CircleBorder(),
                splashColor: lightBlue,
                onPressed: () async {
                  final mapCubit = context.read<MapCubit>();
                  final state = mapCubit.state;

                  if (state is MapSuccess) {
                    await mapCubit.getReports(state.location, _reports);
                    setState(() {
                      readyList = false;
                      _reports = _reports;
                    });

                    List<Report> _newReports = [];

                    for (Report report in _reports) {
                      report = await mapCubit.viewReport(
                        state.location,
                        report.id,
                      );
                      _newReports.add(report);
                    }

                    setState(() {
                      _reports = _newReports;
                      readyList = true;
                    });
                  }

                  ModalBottomSheet(context, _reports);
                },
                child:
                    readyList
                        ? Icon(Icons.list, color: darkBlue, size: 30)
                        : CircularProgressIndicator(color: darkBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
