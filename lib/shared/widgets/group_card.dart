// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:splitify/features/groups/group_summary_model.dart';
// import 'package:splitify/features/groups/groups_controller.dart';
//
// import '../../core/constants/constants.dart';
// import '../../core/theme/app_themes.dart';
// import '../../features/groups/group_expenses_view.dart';
//
// class GroupCard extends StatelessWidget {
//   GroupCard({super.key, required this.index});
//   final int index;
//
//   final groupCtrl = Get.find<GroupsController>();
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         groupCtrl.fetchGroupMembers(groupId: groupCtrl.summaries[index].id);
//         groupCtrl.fetchGroupExpenses(groupId: groupCtrl.summaries[index].id);
//         Get.to(() => GroupExpensesView(index: index));
//       },
//       child: Card(
//         color: Constants.bgColorLight,
//         elevation: 0.6,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               Container(
//                 width: 85.w,
//                 height: 85.w,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   image: const DecorationImage(
//                     image: NetworkImage(
//                       "https://jarvis.cx/tools/_next/image?url=https%3A%2F%2Ffiles.oaiusercontent.com%2Ffile-ctTMt4msuva5EDGFhkxV4zR7%3Fse%3D2123-11-06T01%253A08%253A20Z%26sp%3Dr%26sv%3D2021-08-06%26sr%3Db%26rscc%3Dmax-age%253D31536000%252C%2520immutable%26rscd%3Dattachment%253B%2520filename%253Ddanny-2.webp%26sig%3DHFENdbWjKuaTqdZOdWHzlZ%252BsF1CRtZW1pBI3q94pJ0s%253D&w=1080&q=75",
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 8),
//                   child: Obx(() {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text(
//                           groupCtrl.summaries[index].name,
//                           style: AppTheme.headingText.copyWith(height: 0.85),
//                         ),
//                         groupCtrl.summaries[index].balance.status ==
//                                 BalanceStatus.settled
//                             ? Text(
//                                 "You're all settled",
//                                 style: AppTheme.subHeadingText.copyWith(
//                                   color: Constants.activeColor,
//                                 ),
//                               )
//                             : RichText(
//                                 text: TextSpan(
//                                   style: DefaultTextStyle.of(context).style,
//                                   children: <TextSpan>[
//                                     TextSpan(
//                                       text: groupCtrl.summaries[index].balance
//                                                   .status ==
//                                               BalanceStatus.youOwe
//                                           ? "You owe "
//                                           : "You are owed ",
//                                       style: AppTheme.normalText,
//                                     ),
//                                     TextSpan(
//                                       text:
//                                           "\$${groupCtrl.summaries[index].balance.net}",
//                                       style: AppTheme.subHeadingText.copyWith(
//                                         color: groupCtrl.summaries[index]
//                                                     .balance.status ==
//                                                 BalanceStatus.youOwe
//                                             ? Constants.redColor
//                                             : Constants.activeColor,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                         groupCtrl.summaries[index].balance.status ==
//                                 BalanceStatus.settled
//                             ? const SizedBox()
//                             : ListView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount:
//                                     groupCtrl.summaries[index].preview.length,
//                                 itemBuilder: (context, index) {
//                                   var entity = groupCtrl
//                                       .summaries[this.index].preview[index];
//                                   return RichText(
//                                     text: TextSpan(
//                                       style: DefaultTextStyle.of(context).style,
//                                       children: <TextSpan>[
//                                         TextSpan(
//                                           text: entity.direction ==
//                                                   PreviewDirection.youPay
//                                               ? "You owe ${entity.name} "
//                                               : '${entity.name} owes you',
//                                           style: AppTheme.normalText.copyWith(
//                                               color: Constants.textGrey),
//                                         ),
//                                         TextSpan(
//                                           text: "\$${entity.amount}",
//                                           style: AppTheme.normalText.copyWith(
//                                             color: entity.direction ==
//                                                     PreviewDirection.youPay
//                                                 ? Constants.redColor
//                                                 : Constants.activeColor,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }),
//                       ],
//                     );
//                   }),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ************* Cloude Code *************
// group_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../features/groups/group_expenses_view.dart';
import '../../features/groups/group_summary_model.dart';
import '../../features/groups/groups_controller.dart';

class GroupCard extends StatelessWidget {
  GroupCard({super.key, required this.index});
  final int index;

  final groupCtrl = Get.find<GroupsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = groupCtrl.summaries[index];
      final isSettled = summary.balance.status == BalanceStatus.settled;
      final youOwe = summary.balance.status == BalanceStatus.youOwe;
      final balanceColor = isSettled
          ? Colors.grey
          : youOwe
              ? Constants.redColor
              : Constants.activeColor;

      return GestureDetector(
        onTap: () {
          groupCtrl.fetchGroupMembers(groupId: summary.id);
          groupCtrl.fetchGroupExpenses(groupId: summary.id);
          Get.to(() => GroupExpensesView(index: index));
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Constants.bgColorLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              // ── Group image ──────────────────────────────────
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://jarvis.cx/tools/_next/image?url=https%3A%2F%2Ffiles.oaiusercontent.com%2Ffile-ctTMt4msuva5EDGFhkxV4zR7%3Fse%3D2123-11-06T01%253A08%253A20Z%26sp%3Dr%26sv%3D2021-08-06%26sr%3Db%26rscc%3Dmax-age%253D31536000%252C%2520immutable%26rscd%3Dattachment%253B%2520filename%253Ddanny-2.webp%26sig%3DHFENdbWjKuaTqdZOdWHzlZ%252BsF1CRtZW1pBI3q94pJ0s%253D&w=1080&q=75",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Group info ───────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.name,
                      style: AppTheme.subHeadingText.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (isSettled)
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 13, color: Constants.activeColor),
                          const SizedBox(width: 4),
                          Text(
                            "All settled up",
                            style: AppTheme.normalText.copyWith(
                              color: Constants.activeColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    else
                      // Preview entries
                      ...summary.preview.take(2).map(
                        (entity) {
                          final youPay =
                              entity.direction == PreviewDirection.youPay;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: youPay
                                      ? "${entity.name} "
                                      : "${entity.name} ",
                                  style: AppTheme.normalText.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: youPay ? "owes you " : "you owe ",
                                  style: AppTheme.normalText.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: "\$${entity.amount.toStringAsFixed(2)}",
                                  style: AppTheme.normalText.copyWith(
                                    color: youPay
                                        ? Constants.activeColor
                                        : Constants.redColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // ── Balance badge ────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: balanceColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isSettled
                          ? "Settled"
                          : "\$${summary.balance.net.abs().toStringAsFixed(2)}",
                      style: TextStyle(
                        color: balanceColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
