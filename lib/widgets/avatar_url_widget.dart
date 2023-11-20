import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget avatarTile(String title, String url, String name, onTap) {
  return ListTile(
    onTap: onTap,
    leading: CachedNetworkImage(
      width: 45,
      height: 45,
      imageUrl: url,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        child: ClipOval(
          child: Image(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
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
    trailing:
        IconButton(onPressed: onTap, icon: const Icon(Icons.arrow_forward_ios)),
  );
}
