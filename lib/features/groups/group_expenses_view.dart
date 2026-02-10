import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:splitify/core/constants/constants.dart';
import 'package:splitify/features/groups/tabs_view.dart';

import '../../core/theme/app_themes.dart';
import 'group_summary_model.dart';
import 'groups_controller.dart';

class GroupExpensesView extends StatelessWidget {
  GroupExpensesView({super.key, required this.summary});
  final GroupSummary summary;
  final groupCtrl = Get.put(GroupsController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        title: Text(
          "Back",
          style: AppTheme.normalText,
        ),
        titleSpacing: 0.0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              Constants.backLogo,
              width: 24.w,
              height: 24.w,
            ),
          ),
        ),
        actions: [
          SvgPicture.asset(
            Constants.settingsLogo,
            width: 24.w,
            height: 24.w,
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        color: Constants.bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: const EdgeInsets.only(top: 12),
        child: Obx(() {
          return groupCtrl.isLoading.isTrue
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  width: Get.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 85.w,
                            height: 85.w,
                            child: const CircleAvatar(
                              backgroundImage: NetworkImage(
                                "https://jarvis.cx/tools/_next/image?url=https%3A%2F%2Ffiles.oaiusercontent.com%2Ffile-ctTMt4msuva5EDGFhkxV4zR7%3Fse%3D2123-11-06T01%253A08%253A20Z%26sp%3Dr%26sv%3D2021-08-06%26sr%3Db%26rscc%3Dmax-age%253D31536000%252C%2520immutable%26rscd%3Dattachment%253B%2520filename%253Ddanny-2.webp%26sig%3DHFENdbWjKuaTqdZOdWHzlZ%252BsF1CRtZW1pBI3q94pJ0s%253D&w=1080&q=75",
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  summary.name,
                                  style: AppTheme.headingText,
                                ),
                                summary.balance.status == BalanceStatus.settled
                                    ? const SizedBox()
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: summary.preview.length,
                                        itemBuilder: (context, index) {
                                          var entity = summary.preview[index];
                                          return RichText(
                                            text: TextSpan(
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style,
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: entity.direction ==
                                                          PreviewDirection
                                                              .youPay
                                                      ? "You owe ${entity.name} "
                                                      : '${entity.name} owes you',
                                                  style:
                                                      AppTheme.subHeadingText,
                                                ),
                                                TextSpan(
                                                  text: "\$${entity.amount}",
                                                  style: AppTheme.subHeadingText
                                                      .copyWith(
                                                    color: entity.direction ==
                                                            PreviewDirection
                                                                .youPay
                                                        ? Constants.redColor
                                                        : Constants.activeColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      const Expanded(child: TabsView()),
                    ],
                  ),
                );
        }),
      ),
    );
  }
}
