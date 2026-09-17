import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'package:google_fonts/google_fonts.dart'; // Jangan lupa di-import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arcanova Tarot',
      debugShowCheckedModeBanner: false,
      
      // DI SINI KUNCINYA: Mengatur tema global aplikasi
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1E1B4B), // Contoh warna latar galaksi
        
        // Menerapkan font Poppins ke seluruh teks di aplikasi
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme, // Menyesuaikan dengan tema gelap (opsional)
        ),
        
        // (Opsional) Mengatur warna default teks agar putih/terang
        primaryColor: const Color(0xFFD8B4FE),
      ),
      
      home: const LoginPage(),
    );
  }
}