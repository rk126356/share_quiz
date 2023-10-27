import 'package:flutter/material.dart';
import 'package:share_quiz/common/colors.dart';

class QuizItem extends StatelessWidget {
  final String title;
  final List<String>? categories;
  final String quizID;
  final int taken;
  final int views;
  final double rating;
  final String topScorerName;

  const QuizItem({
    super.key,
    required this.title,
    this.categories,
    this.quizID = "123456",
    required this.taken,
    required this.views,
    required this.rating,
    required this.topScorerName,
  });

  @override
  Widget build(BuildContext context) {
    final defaultCategory = ["Sports", 'Cricket'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.length > 30 ? "${title.substring(0, 30)}..." : title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 5.0),
            const Row(
              children: [
                Icon(Icons.percent, color: AppColors.primaryColor),
                SizedBox(width: 4.0),
                Text('77% wins', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 2.0),
            Row(
              children: [
                const Icon(Icons.play_circle_outlined,
                    color: AppColors.primaryColor),
                const SizedBox(width: 4.0),
                Text('$taken plays',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.tag_sharp, color: AppColors.primaryColor),
                const SizedBox(width: 4.0),
                Text('Tags: ${(categories ?? defaultCategory).join(", ")}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 2.0),
            const SizedBox(height: 2.0),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Row(
                children: [
                  CircleAvatar(
                    maxRadius: 10,
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      topScorerName[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text('Top Scorer: $topScorerName',
                      style: const TextStyle(color: AppColors.primaryColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
