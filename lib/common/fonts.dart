import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static final TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle bodyText = GoogleFonts.roboto(
    fontSize: 16,
    color: Colors.white,
  );

  static final TextStyle button = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final TextStyle link = GoogleFonts.roboto(
    fontSize: 16,
    color: CupertinoColors.activeBlue,
    decoration: TextDecoration.underline,
  );
}
