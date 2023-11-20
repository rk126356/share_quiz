import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class InsideQuizShimmer extends StatelessWidget {
  const InsideQuizShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Quiz Card
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: ListTile(
                    title: Container(
                      width: double.infinity,
                      height: 24.0,
                      color: Colors.white,
                    ),
                    subtitle: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Container(
                        width: double.infinity,
                        height: 16.0,
                        color: Colors.white,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              width: double.infinity,
                              height: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(4)),
                        ),
                        child: TextButton(
                          onPressed: null,
                          child: Container(
                            width: double.infinity,
                            height: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
