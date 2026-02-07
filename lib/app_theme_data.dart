import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final TextTheme _googleFontRobotoTheme = GoogleFonts.robotoTextTheme();
final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    side: const BorderSide(
      color: Color(0xFF0095F6)
    )
    )
);

class AppThemeData {

  final ThemeData _lightThemeData = ThemeData(
    outlinedButtonTheme: _outlinedButtonTheme,
    elevatedButtonTheme:
    ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0095F6),
            foregroundColor: Colors.white)),
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0095F6)
      ),
      textTheme: _googleFontRobotoTheme,
    );

  final ThemeData _darkThemeData = ThemeData(
    outlinedButtonTheme: _outlinedButtonTheme,
    colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0x00334155)
      ),
      textTheme: _googleFontRobotoTheme,
    );

    light(){
      return _lightThemeData;
    }

    dark(){
      return _darkThemeData;
    }


}