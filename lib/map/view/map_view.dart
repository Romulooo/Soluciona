import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soluciona/data/models/report_model.dart';
import 'package:soluciona/main.dart';
import 'package:soluciona/map/cubit/map_cubit.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:soluciona/report/report_cubit.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final List<Report> _reports = [
    Report(
      name: "Teste",
      description: "Descrição",
      latitude: "-27",
      longitude: "-52",
      place: "Conkas",
      registeredBy: "1",
    ),
  ];

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
              Text("Rômulo"),
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
        listener: (context, state) {
          if (state is MapSuccess) {
            mapController.move(state.location, 15.0);
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

                  if (place["town"] == "Concórdia") { //TODO: Pegar a cidade do usuário
                    context.read<MapCubit>().reportPin(point);
                  }
                },

                initialCenter: const LatLng(0, 0),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?key=CanpjbKvOGYhddHuo8Ut',
                  userAgentPackageName: 'com.example.soluciona',
                ),

                MarkerLayer(
                  markers: List.generate(_reports.length, (index) {
                    final report = _reports[index];

                    return Marker(
                      point: LatLng(
                        double.parse(report.latitude),
                        double.parse(report.longitude),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          showPopupCard(
                            context: context,
                            builder: (context) {
                              return PopupCard(
                                elevation: 8,

                                color: white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: SizedBox(
                                  width: 300,
                                  height: 500,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          report.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(report.description),
                                        Spacer(),
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

                              showPopupCard(
                                context: context,
                                builder: (context) {
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
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Reportar Problema',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 20),
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
                                                          borderSide: BorderSide(
                                                            color:
                                                                const Color.fromARGB(
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
                                                SizedBox(width: 4),
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
                                                          borderSide: BorderSide(
                                                            color:
                                                                const Color.fromARGB(
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
                                            SizedBox(height: 8),
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
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color:
                                                          const Color.fromARGB(
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
                                            SizedBox(height: 8),
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
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color:
                                                          const Color.fromARGB(
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
                                            Spacer(),
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
                                                child: Text(
                                                  'Escolher Arquivo',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            if (_selectedFile != null)
                                              /*SizedBox(
                                                width: 200,
                                                child: Image.memory(
                                                  _selectedFile!.bytes!,
                                                  height: 50,
                                                ),
                                              )*/
                                              SizedBox()
                                            else
                                              Text(
                                                'Nenhum arquivo selecionado',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            SizedBox(height: 10),
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
                                                onPressed: () {
                                                  //Verifica se algum tá vazio
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
                                                    // Não está vazio
                                                    final report = Report(
                                                      name:
                                                          _reportController
                                                              .text,
                                                      description:
                                                          _descriptionController
                                                              .text,
                                                      latitude:
                                                          state
                                                              .location
                                                              .latitude
                                                              .toString(),
                                                      longitude:
                                                          state
                                                              .location
                                                              .longitude
                                                              .toString(),
                                                      place:
                                                          "${_roadController.text}, ${_suburbController.text}",
                                                      registeredBy:
                                                          "0", // TODO: Colocar o nome do usuário
                                                    );

                                                    context
                                                        .read<ReportCubit>()
                                                        .sendReport(report);
                                                    Navigator.pop(context);
                                                  } else {
                                                    //Algum está vazio
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).clearSnackBars();
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
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
                shape: CircleBorder(),
                splashColor: lightBlue,
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: ListView.builder(
                            itemCount: _reports.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Icon(Icons.report_problem),
                                title: Text(_reports[index].name),
                                subtitle: Text(_reports[index].place),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(width: 2),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.info_outline),
                                  onPressed: () {
                                    // TODO: Abrir o Popup
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Icon(Icons.list, color: darkBlue, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
