import 'package:flutter/material.dart';

class AppRadius {
  static const double sm = 8.0;
  static const double card = 12.0;
  static const double sheet = 20.0;
  static const double pill = 999.0;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get sheetRadius => BorderRadius.circular(sheet);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);

  static Radius get sheetRadiusVal => const Radius.circular(sheet);
  static Radius get cardRadiusVal => const Radius.circular(card);
}
