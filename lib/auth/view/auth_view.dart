import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soluciona/auth/auth.dart';
import 'package:soluciona/main.dart';
import 'package:soluciona/map/view/map_page.dart';

enum AccountType { instituicao, cidade }

class AuthView extends StatefulWidget {
  bool login;
  AuthView({super.key, required this.login});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool _obscurePassword = true;
  late bool _isLogin;
  late AccountType _accountType; // Tipo da conta
  String? _selectedCity; // Cidade selecionada
  String? _selectedInstitution; // Instituição selecionada
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmpasswordController;
  late TextEditingController _phoneController;

  final List<String> _cities = [
    'Peritiba',
    'Paim Filho',
    'Concórdia',
    'Itá',
    'Capinzal',
    'Chapecó',
    'Xanxerê',
  ];
  final List<String> _institutions = ['IFC Concórdia', 'EEBIAS'];

  @override
  void initState() {
    super.initState();
    _isLogin = widget.login;
    _accountType = AccountType.cidade;
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmpasswordController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Image.asset("assets/logo.png", height: 80),
                    const SizedBox(height: 10),
                    Text(
                      "SOLUCIONA",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: mediumBlue,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),

                _isLogin
                    ? Column(
                      children: [
                        // Campo usuário
                        TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: lightBlue.withAlpha(90),
                            cursorColor: lightBlue,
                            selectionHandleColor: lightBlue,
                          ),
                          child: TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: "Usuário, email ou telefone",
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: const Color(0xFFF2F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: mediumBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            cursorColor: mediumBlue,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Campo senha
                        TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: lightBlue.withAlpha(90),
                            cursorColor: lightBlue,
                            selectionHandleColor: lightBlue,
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Senha",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: mediumBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            cursorColor: mediumBlue,
                          ),
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        // Campo usuário
                        TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: lightBlue.withAlpha(90),
                            cursorColor: lightBlue,
                            selectionHandleColor: lightBlue,
                          ),
                          child: TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: "Usuário",
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: const Color(0xFFF2F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: mediumBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            cursorColor: mediumBlue,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Campo email
                        TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: lightBlue.withAlpha(90),
                            cursorColor: lightBlue,
                            selectionHandleColor: lightBlue,
                          ),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "E-mail",
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: const Color(0xFFF2F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: mediumBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            cursorColor: mediumBlue,
                          ),
                        ),

                        SizedBox(height: 16),

                        // Campo telefone
                        TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: lightBlue.withAlpha(90),
                            cursorColor: lightBlue,
                            selectionHandleColor: lightBlue,
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            maxLength: 11,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: "Telefone (opcional)",
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: const Color(0xFFF2F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: mediumBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            cursorColor: mediumBlue,
                          ),
                        ),

                        SizedBox(height: 16),

                        // Campo senha
                        TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: lightBlue.withAlpha(90),
                            cursorColor: lightBlue,
                            selectionHandleColor: lightBlue,
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Senha",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: mediumBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            cursorColor: mediumBlue,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Campo para confirmar senha
                        TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: lightBlue.withAlpha(90),
                            cursorColor: lightBlue,
                            selectionHandleColor: lightBlue,
                          ),
                          child: TextField(
                            controller: _confirmpasswordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Confirmar senha",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: mediumBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            cursorColor: mediumBlue,
                          ),
                        ),

                        SizedBox(height: 16),

                        // Campo instituição ou cidade
                        Text(
                          "Vincular conta a:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        // Botões de Rádio
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<AccountType>(
                                title: const Text("Instituição"),
                                value: AccountType.instituicao,
                                groupValue: _accountType,
                                onChanged: (AccountType? value) {
                                  if (value != null) {
                                    setState(() {
                                      _accountType = value;
                                    });
                                  }
                                },
                                activeColor: mediumBlue,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<AccountType>(
                                title: const Text("Cidade"),
                                value: AccountType.cidade,
                                groupValue: _accountType,
                                onChanged: (AccountType? value) {
                                  if (value != null) {
                                    setState(() {
                                      _accountType = value;
                                    });
                                  }
                                },
                                activeColor: mediumBlue,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: lightBlue.withAlpha(90),
                            cursorColor: lightBlue,
                            selectionHandleColor: lightBlue,
                          ),

                          child:
                              _accountType == AccountType.cidade
                                  ? DropdownButtonFormField<String>(
                                    value: _selectedCity,
                                    isExpanded: true,
                                    dropdownColor: white,
                                    style: TextStyle(color: darkBlue),
                                    items:
                                        _cities.map((String city) {
                                          return DropdownMenuItem<String>(
                                            value: city,
                                            child: Text(city),
                                          );
                                        }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedCity = newValue;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Nome da Cidade",
                                      prefixIcon: const Icon(
                                        Icons.location_city_outlined,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF2F5F9),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: mediumBlue,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            value == null
                                                ? 'Por favor, selecione uma cidade'
                                                : null,
                                  )
                                  : DropdownButtonFormField<String>(
                                    value: _selectedInstitution,
                                    isExpanded: true,
                                    dropdownColor: white,
                                    style: TextStyle(color: darkBlue),

                                    items:
                                        _institutions.map((String institution) {
                                          return DropdownMenuItem<String>(
                                            value: institution,
                                            child: Text(institution),
                                          );
                                        }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedInstitution = newValue;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Nome da Instituição",
                                      prefixIcon: const Icon(Icons.school),
                                      filled: true,
                                      fillColor: const Color(0xFFF2F5F9),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: mediumBlue,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            value == null
                                                ? 'Por favor, selecione uma instituição'
                                                : null,
                                  ),
                        ),
                      ],
                    ),

                SizedBox(height: 24),

                // Botão Entrar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mediumBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () {},
                          child: CircularProgressIndicator(),
                        );
                      }
                      return BlocListener<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPage(),
                              ),
                            );
                          } else if (state is AuthFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.error)),
                            );
                          }
                        },
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mediumBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () async {
                            if (!_isLogin &&
                                _usernameController.text.isNotEmpty &&
                                _emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty) {
                              if (_passwordController.text ==
                                  _confirmpasswordController.text) {
                                await context.read<AuthCubit>().register(
                                  _usernameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                  _phoneController.text,
                                );

                                context.read<AuthCubit>().login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                              } else {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Senhas não coincidem."),
                                  ),
                                );
                              }
                            } else if (_isLogin &&
                                _usernameController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty) {
                              context.read<AuthCubit>().login(
                                _usernameController.text,
                                _passwordController.text,
                              );
                            } else {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Preencha os campos corretamente.",
                                  ),
                                ),
                              );
                            }
                          },
                          child:
                              state is AuthLoading
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    _isLogin ? "Entrar" : "Cadastrar",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("ou"),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botão criar conta
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: mediumBlue,
                    side: BorderSide(color: mediumBlue, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _isLogin ? "Criar nova conta" : "Já possuo uma conta",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
