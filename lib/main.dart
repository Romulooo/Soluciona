import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soluciona/app.dart';
import 'package:soluciona/map_observer.dart';

Color darKBlue = Color.fromARGB(255, 1, 9, 28);
Color mediumBlue = Color.fromARGB(255, 43, 87, 160);
Color lightBlue = Color.fromARGB(255, 139, 197, 255);
Color white = Color.fromARGB(255, 224, 224, 224);

void main() async {
  await dotenv.load();
  Bloc.observer = const MapObserver();
  runApp(const MainApp());
}
