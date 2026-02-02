import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:splitify/Utils/themes.dart';

import '../../Utils/constants.dart';
import '../../Widgets/activity_card.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Activity',
          style: AppTheme.headingText,
        ),
        leading: Row(
          children: [
            const SizedBox(width: 16),
            SvgPicture.asset(
              Constants.notificationLogo,
              width: 24,
              height: 24,
            ),
          ],
        ),
        actions: [
          SvgPicture.asset(
            Constants.filterLogo,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Constants.bgColorLight,
        foregroundColor: Constants.bgColorLight,
      ),
      backgroundColor: Constants.bgColorLight,
      body: Container(
        color: Constants.bgColorLight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                "Recent",
                style: AppTheme.headingText,
              ),
              const SizedBox(height: 12),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: ActivityCard(index: index),
                    );
                  }),
              const SizedBox(height: 16),
              // Start a new group
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Constants.activeColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Constants.teamsLogo,
                      width: 24,
                      height: 24,
                      color: Constants.activeColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Start a new group',
                      style: AppTheme.subHeadingText.copyWith(
                          color: Constants.activeColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
