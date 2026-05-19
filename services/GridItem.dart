import 'package:flutter/cupertino.dart';

class GridItem {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  GridItem({required this.imagePath, required this.label, required this.onTap});
}