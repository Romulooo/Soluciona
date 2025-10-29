import 'package:flutter/material.dart';
import 'package:soluciona/auth/view/auth_page.dart';

class MainApp extends MaterialApp {
  const MainApp({super.key})
    : super(home: const AuthPage(), debugShowCheckedModeBanner: false);
}
