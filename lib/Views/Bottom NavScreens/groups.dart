import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:splitify/Utils/themes.dart';
import 'package:splitify/Widgets/group_card.dart';

import '../../Utils/constants.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Groups',
          style: AppTheme.headingText,
        ),
        actions: [
          SvgPicture.asset(
            Constants.searchLogo,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 16),
          SvgPicture.asset(
            Constants.teamsLogo,
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
              Row(
                children: [
                  // owing status
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Overall, you are owed ',
                          style: AppTheme.subHeadingText,
                        ),
                        TextSpan(
                          text: "\$14.45",
                          style: AppTheme.subHeadingText.copyWith(
                            color: Constants.activeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // filter
                  SvgPicture.asset(
                    Constants.filterLineLogo,
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: GroupCard(index: index),
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
