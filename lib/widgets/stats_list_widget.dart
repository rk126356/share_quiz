import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget statTile(String title, IconData icon, String value) {
  return ListTile(
    leading: Icon(icon, color: CupertinoColors.activeBlue),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.grey,
      ),
    ),
    subtitle: Text(
      value,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
