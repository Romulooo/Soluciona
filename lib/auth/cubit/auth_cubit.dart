import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  Future<void> login() async {
    //TODO: Função para fazer um POST pro login
    http.Client client = http.Client();

    client.post(Uri.parse(""));
  }

  Future<void> register(
    String username,
    String email,
    String password,
    String? phone,
  ) async {
    http.Client client = http.Client();

    Map<String, dynamic> body = {
      "username": username,
      "email": email,
      "password": password,
    };

    phone!.isNotEmpty ? body.addAll({"phone": phone}) : ();

    client.post(
      Uri.parse("${dotenv.get("API_URL")}/register"),
      body: jsonEncode(body),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );

    appUsername = username; // Define o nome do usuário no aplicativo
  }
}
