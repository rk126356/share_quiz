import 'package:flutter/material.dart';

Widget buildSearchButton(BuildContext context, String text, Color color,
    Icon icon, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
        minimumSize: MaterialStateProperty.all<Size>(const Size(120.0, 40.0)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8.0),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
