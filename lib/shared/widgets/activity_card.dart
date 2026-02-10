import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Constants.bgColor,
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              child: SvgPicture.asset(Constants.walletLogo),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      index == 0
                          ? 'Eggs, Wipes Roll'
                          : index == 1
                              ? 'Grocery'
                              : 'Milk, Butter, Bread',
                      style: AppTheme.normalText
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    SvgPicture.asset(Constants.rightLogo),
                    Text(
                      index == 1 ? 'Boys ' : 'House Mates ',
                      style: AppTheme.normalText,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
