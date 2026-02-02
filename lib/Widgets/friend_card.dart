import 'package:flutter/material.dart';

import '../Utils/constants.dart';
import '../Utils/themes.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Constants.bgColorLight,
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(
                  "https://jarvis.cx/tools/_next/image?url=https%3A%2F%2Ffiles.oaiusercontent.com%2Ffile-ctTMt4msuva5EDGFhkxV4zR7%3Fse%3D2123-11-06T01%253A08%253A20Z%26sp%3Dr%26sv%3D2021-08-06%26sr%3Db%26rscc%3Dmax-age%253D31536000%252C%2520immutable%26rscd%3Dattachment%253B%2520filename%253Ddanny-2.webp%26sig%3DHFENdbWjKuaTqdZOdWHzlZ%252BsF1CRtZW1pBI3q94pJ0s%253D&w=1080&q=75"),
            ),
            const SizedBox(width: 8),
            Text(
              index == 0
                  ? 'Sufian Mughal'
                  : index == 1
                      ? 'Mubeen Ahmad'
                      : 'Lallu Laal',
              style: AppTheme.subHeadingText,
            ),
            const Spacer(),
            Text(
              index == 1 ? 'you owe ' : 'owes you ',
              style: AppTheme.normalText,
            ),
            Text(
              '\$${6 + index * 2.8}0',
              style: AppTheme.normalText.copyWith(
                  color:
                      index == 1 ? Constants.redColor : Constants.activeColor),
            ),
          ],
        ),
      ),
    );
  }
}
