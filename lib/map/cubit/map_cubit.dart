import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class MapInitial extends MapState {}

// Estado de carregamento
class MapLoading extends MapState {}

// Estado de sucesso
class MapSuccess extends MapState {
  final LatLng location;
  final LatLng? reportPin;
  final String? road;
  final String? suburb;

  const MapSuccess({
    required this.location,
    this.reportPin,
    this.suburb,
    this.road,
  });

  @override
  List<Object?> get props => [location, reportPin, road, suburb];
}

// Estado de falha
class MapFailure extends MapState {
  final String error;

  const MapFailure(this.error);

  @override
  List<Object> get props => [error];
}

// Cubit

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapInitial());

  /// Busca a localização atual do usuário e atualiza o estado.
  Future<void> getCurrentLocation() async {
    try {
      emit(MapLoading());

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const MapFailure('Serviço de GPS desativado.'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const MapFailure('Permissão de localização negada.'));
          return;
        }
      }

      // Buscar posição se permissão for concedida
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      final userLocation = LatLng(position.latitude, position.longitude);

      emit(MapSuccess(location: userLocation));
    } catch (e) {
      emit(MapFailure('Erro ao obter localização: ${e.toString()}'));
    }
  }

  Future<void> reportPin(final LatLng tapPosition) async {
    final currentState = state;
    if (currentState is MapSuccess) {
      emit(MapSuccess(location: currentState.location, reportPin: tapPosition));
    }
  }

  Future<void> clearPin() async {
    final currentState = state;
    if (currentState is MapSuccess) {
      emit(MapSuccess(location: currentState.location, reportPin: null));
    }
  }

  Future<Map<String, String>> getPlace(LatLng latlng) async {
    final currentState = state;

    final client = http.Client();

    final response = await client.get(
      Uri.parse(
        "https://us1.locationiq.com/v1/reverse?key=${dotenv.get("GEOCODING_KEY")}&lat=${latlng.latitude}&lon=${latlng.longitude}&format=json&",
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String road = data["address"]["road"] ?? "Rua indefinida";
      String suburb = data["address"]["suburb"] ?? "Indefinido";

      if (currentState is MapSuccess) {
        emit(
          MapSuccess(
            location: currentState.location,
            road: road,
            suburb: suburb,
          ),
        );

        return {"road": road, "suburb": suburb};
      }
    } else {
      emit(MapFailure("Erro ao nomear localização"));
    }
    return {"road": "Rua indefinida", "suburb": "Indefinido"};
  }
}
