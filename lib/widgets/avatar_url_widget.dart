import 'package:flutter/material.dart';

Widget avatarTile(String title, String url, String name, onTap) {
  return ListTile(
    onTap: onTap,
    leading: CircleAvatar(
      radius: 20,
      backgroundColor: Colors.blue, // Change the background color as needed
      child: CircleAvatar(
        radius: 18, // Adjust the radius to make it circular
        backgroundImage: NetworkImage(url.length > 1
            ? url
            : 'https://www.zooniverse.org/assets/simple-avatar.png'),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.grey,
      ),
    ),
    subtitle: Text(
      name,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
