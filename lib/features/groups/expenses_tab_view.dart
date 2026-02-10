import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:splitify/core/constants/constants.dart';
import 'package:splitify/features/profile/profile_controller.dart';

import '../../core/theme/app_themes.dart';
import 'groups_controller.dart';

class ExpensesTabView extends StatelessWidget {
  ExpensesTabView({super.key});

  final groupCtrl = Get.put(GroupsController());
  final profileCtrl = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height,
      color: Constants.bgColor,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupCtrl.groupExpenses.value.expenses?.length,
          itemBuilder: (context, index) {
            var expense = groupCtrl.groupExpenses.value.expenses?[index];
            double amount = 0.0;
            expense?.splits?.forEach((split) {
              if (expense.paidBy?.id == profileCtrl.user.value.user?.id &&
                  split.user?.id != profileCtrl.user.value.user?.id) {
                amount = amount + split.amount!;
              } else if (expense.paidBy?.id !=
                      profileCtrl.user.value.user?.id &&
                  split.user?.id == profileCtrl.user.value.user?.id) {
                amount = split.amount!;
              }
            });
            return Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Constants.bgColorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 38.w,
                    height: 38.w,
                    child: CircleAvatar(
                      backgroundColor: Constants.activeColor.withAlpha(25),
                      child: SvgPicture.asset(
                        expense!.description! == "Settlement"
                            ? Constants.walletLogo
                            : expense.description!.contains("meat")
                                ? Constants.meatLogo
                                : Constants.groceryLogo,
                        color: Constants.activeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      expense.description! == "Settlement"
                          ? const SizedBox()
                          : Text(expense.description!,
                              style: AppTheme.subHeadingText),
                      RichText(
                        text: TextSpan(
                          // style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                              text: profileCtrl.user.value.user?.id ==
                                      expense.paidBy?.id
                                  ? 'You paid '
                                  : '${expense.paidBy?.name} paid ',
                              style: AppTheme.normalText,
                            ),
                            TextSpan(
                              text: "\$${expense.amount}",
                              style: AppTheme.normalText.copyWith(
                                color: Constants.activeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      expense.description! == "Settlement"
                          ? Text(
                              "Settlement",
                              style: AppTheme.normalText
                                  .copyWith(color: Constants.activeColor),
                            )
                          : RichText(
                              text: TextSpan(
                                // style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(
                                    text: profileCtrl.user.value.user?.id ==
                                            expense.paidBy?.id
                                        ? 'You lent '
                                        : 'You borrowed ',
                                    style: AppTheme.normalText,
                                  ),
                                  TextSpan(
                                    text: "\$$amount",
                                    style: AppTheme.normalText.copyWith(
                                      color: Constants.redColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Text(
                        "19 Oct",
                        style: AppTheme.normalText,
                      )
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
