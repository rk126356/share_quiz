import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SmallRowButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final Icon icon;

  const SmallRowButton(
      {super.key,
      required this.onTap,
      required this.title,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: CupertinoColors.activeBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            icon
          ],
        ),
      ),
    );
  }
}
