import 'package:flutter/material.dart';

class AppResponsive {
  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
}