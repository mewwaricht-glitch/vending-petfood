import 'package:flutter/material.dart';
import 'pages/menu_page.dart';

void main() {
  runApp(const VendingMachineApp());
}

class VendingMachineApp extends StatelessWidget {
  const VendingMachineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Food Vending Machine',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorSchemeSeed: const Color.fromARGB(255, 249, 247, 246),

        scaffoldBackgroundColor: Colors.white,
      ),

      home: const MenuPage(),
    );
  }
}