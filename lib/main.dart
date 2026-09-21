import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'arcanova_db.dart';

import 'pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ArcanovaDB.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arcanova Tarot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,

        // Background utama
        scaffoldBackgroundColor:
            const Color(0xFF1E1B4B),

        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),

        primaryColor:
            const Color(0xFFD8B4FE),

        dialogTheme: DialogThemeData(
          backgroundColor:
              const Color(0xFF1E1B4B),

          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),

          contentTextStyle: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),


        inputDecorationTheme:
            InputDecorationTheme(
          labelStyle: GoogleFonts.poppins(
            color: Colors.white70,
          ),

          floatingLabelStyle:
              GoogleFonts.poppins(
            color: const Color(0xFFD8B4FE),
          ),

          hintStyle: GoogleFonts.poppins(
            color: Colors.white38,
          ),

          prefixIconColor:
              const Color(0xFFD8B4FE),

          enabledBorder:
              const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white54,
            ),
          ),

          focusedBorder:
              const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFD8B4FE),
              width: 2,
            ),
          ),
        ),

        //tombol
        filledButtonTheme:
            FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor:
                const Color(0xFF7C3AED),

            foregroundColor:
                Colors.white,

            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        //AppBar
        appBarTheme: AppBarTheme(
          backgroundColor:
              const Color(0xFF1E1B4B),

          foregroundColor:
              Colors.white,

          elevation: 0,

          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        //snackbar
        snackBarTheme:
            SnackBarThemeData(
          backgroundColor:
              const Color(0xFF312E81),

          contentTextStyle:
              GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
      ),

      //home page
      home: const LoginPage(),
    );
  }
}