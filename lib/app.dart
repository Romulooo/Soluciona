import 'package:flutter/material.dart';
import 'package:soluciona/auth/view/auth_page.dart';
import 'package:soluciona/map/map.dart';

class MainApp extends MaterialApp {
  const MainApp({super.key})
    : super(home: const AuthPage(), debugShowCheckedModeBanner: false);
}
