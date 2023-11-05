import 'package:flutter/material.dart';
import 'package:share_quiz/common/fonts.dart';
import 'package:share_quiz/screens/home/colors.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_tag_screen.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({
    Key? key,
    required this.size,
    required this.name,
    required this.username,
    required this.categories,
    required this.topScorerName,
    required this.topScorerImage,
    required this.creatorUserID,
    required this.topScorerUid,
  }) : super(key: key);

  final Size size;
  final String name;
  final String username;
  final List<dynamic> categories;
  final String topScorerName;
  final String topScorerImage;
  final String creatorUserID;
  final String topScorerUid;

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
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InsideProfileScreen(
                          userId: creatorUserID,
                        )),
              );
            },
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InsideProfileScreen(
                            userId: creatorUserID,
                          )),
                );
              },
              child: Text(
                name,
                style: const TextStyle(color: white, fontSize: 20),
              ),
            ),
          ),
          Text(
            '@$username',
            style: const TextStyle(color: white, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: categories!.asMap().entries.map((entry) {
              final tagName = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InsideQuizTagScreen(
                                  tag: tagName,
                                )),
                      );
                    },
                    child: Text(
                      tagName,
                      style: AppFonts.link.copyWith(color: Colors.white),
                    )),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              if (topScorerUid != '') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InsideProfileScreen(
                            userId: topScorerUid,
                          )),
                );
              }
            },
            child: Row(
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
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
