import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class CustomLikeButton extends StatelessWidget {
  const CustomLikeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      circleColor:
          const CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
      bubblesColor: const BubblesColor(
        dotPrimaryColor: Colors.pink,
        dotSecondaryColor: Colors.white,
      ),
      likeBuilder: (bool isLiked) {
        return Icon(
          CupertinoIcons.heart,
          color: isLiked ? Colors.red : Colors.grey,
        );
      },
    );
  }
}
