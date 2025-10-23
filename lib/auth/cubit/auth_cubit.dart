import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

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

  Future<void> register() async {
    //TODO: Função para fazer um POST pro cadastro
    http.Client client = http.Client();

    client.post(Uri.parse(""));
  }
}
