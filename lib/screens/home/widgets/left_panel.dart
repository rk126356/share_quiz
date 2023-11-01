import 'package:flutter/material.dart';
import 'package:share_quiz/screens/home/colors.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({
    Key? key,
    required this.size,
    required this.name,
    required this.username,
    required this.categories,
    required this.topScorerName,
    required this.topScorerImage,
  }) : super(key: key);

  final Size size;
  final String name;
  final String username;
  final String categories;
  final String topScorerName;
  final String topScorerImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //  height: 100,
      height: size.height,
      width: size.width * 0.78,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            name,
            style: const TextStyle(color: white, fontSize: 20),
          ),
          Text(
            '@$username',
            style: const TextStyle(color: white, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            categories,
            style: const TextStyle(
              color: white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    topScorerImage,
                    fit: BoxFit.cover,
                    width: 35,
                    height: 35,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                'Top Scorer: $topScorerName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
