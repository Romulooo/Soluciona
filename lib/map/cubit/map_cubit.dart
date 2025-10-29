import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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

  const MapSuccess({required this.location, this.reportPin});

  @override
  List<Object?> get props => [location, reportPin];
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
}
