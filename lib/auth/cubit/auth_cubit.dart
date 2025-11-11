import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soluciona/auth/cubit/get_place.dart';
import 'package:soluciona/main.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Estado inicial
class AuthInitial extends AuthState {}

// Estado de carregamento
class AuthLoading extends AuthState {}

// Estado de sucesso
class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// Estado de falha
class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object> get props => [error];
}

// Cubit

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login(String identifier, String password) async {
    http.Client client = http.Client();

    emit(AuthLoading());

    try {
      final response = await client.post(
        Uri.parse("${dotenv.get("API_URL")}/login"),
        body: jsonEncode({"identifier": identifier, "password": password}),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        access_token = data["access_token"];

        // Define o nome do usuário no aplicativo
        appUsername = data["username"];

        // Define a cidade/campus do usuário no aplicativo
        int location_id = data["place_id"];
        await getPlace(location_id);

        // Retorna no terminal o token de acesso para debug
        print(access_token);
        emit(AuthSuccess("Credenciais válidas"));
      } else {
        throw Exception();
      }
    } catch (e) {
      emit(
        AuthFailure(
          "Credenciais inválidas. Verifique seus dados e tente novamente.",
        ),
      );
    }
  }

  Future<void> register(
    String username,
    String email,
    String password,
    String? phone,
    int placeId
  ) async {
    http.Client client = http.Client();

    emit(AuthLoading());

    Map<String, dynamic> body = {
      "username": username,
      "email": email,
      "password": password,
      "place_id": placeId,
    };

    phone!.isNotEmpty ? body.addAll({"phone": phone}) : ();

    try {
      client.post(
        Uri.parse("${dotenv.get("API_URL")}/register"),
        body: jsonEncode(body),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      emit(AuthFailure("Erro ao tentar realizar o cadastro."));
    }
  }
}
