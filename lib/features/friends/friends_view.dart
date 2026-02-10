import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:splitify/shared/widgets/friend_card.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Friends',
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
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
      ),
      backgroundColor: Constants.bgColor,
      body: Container(
        color: Constants.bgColor,
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
                      child: FriendCard(index: index),
                    );
                  }),
              const SizedBox(height: 16),
              // Add more mates
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
                      'Add more mates',
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
