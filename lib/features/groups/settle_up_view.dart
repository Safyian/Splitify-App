import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:splitify/features/groups/groups_controller.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../shared/widgets/alert_widgets.dart';
import 'group_summary_model.dart';

class SettleUpView extends StatelessWidget {
  SettleUpView({super.key, required this.index});
  final int index;
  final groupCtrl = Get.find<GroupsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Settle Up",
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
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        color: Constants.bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              groupCtrl.summaries[index].balance.status ==
                      BalanceStatus.youAreOwed
                  ? Text(
                      "You're owed",
                      style: AppTheme.subHeadingText,
                    )
                  : Text(
                      "Make full or partial settlement",
                      style: AppTheme.subHeadingText,
                    ),
              const SizedBox(height: 12),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 6),
                  itemCount: groupCtrl.summaries[index].preview.length,
                  itemBuilder: (context, index) {
                    var entity = groupCtrl.summaries[this.index].preview[index];
                    return GestureDetector(
                      onTap: () => Get.to(() => SettleAmountView(
                          entity: entity,
                          groupId: groupCtrl.summaries[this.index].id)),
                      child: Container(
                        color: Constants.bgColor,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Constants.bgColorLight,
                                  radius: 24,
                                  child: Icon(
                                    Icons.person,
                                    color: Constants.activeColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  entity.name,
                                  style: AppTheme.subHeadingText,
                                ),
                                const Spacer(),
                                Column(
                                  children: [
                                    Text(
                                      entity.direction ==
                                              PreviewDirection.youPay
                                          ? "You owe"
                                          : "Owes you",
                                      style: AppTheme.normalText,
                                    ),
                                    Text(
                                      "\$${entity.amount}",
                                      style: AppTheme.subHeadingText.copyWith(
                                        color: entity.direction ==
                                                PreviewDirection.youPay
                                            ? Constants.redColor
                                            : Constants.activeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            index <
                                    groupCtrl.summaries[this.index].preview
                                            .length -
                                        1
                                ? const Divider(
                                    indent: 12, endIndent: 12, height: 20)
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    );
                  }),
              SizedBox(height: 0.1.sh),
              Center(
                child: Lottie.asset(Constants.settleLogo,
                    width: 280, height: 280, repeat: false),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class SettleAmountView extends StatefulWidget {
  SettleAmountView({super.key, required this.entity, required this.groupId});
  final Preview entity;
  final String groupId;

  @override
  State<SettleAmountView> createState() => _SettleAmountViewState();
}

class _SettleAmountViewState extends State<SettleAmountView> {
  late TextEditingController settleCtrl;

  final formKey = GlobalKey<FormState>();
  final groupCtrl = Get.find<GroupsController>();
  @override
  void initState() {
    super.initState();
    settleCtrl = TextEditingController(
      text: widget.entity.amount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    settleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
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
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        color: Constants.bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Make full or partial settlement",
              style: AppTheme.subHeadingText,
            ),
            const SizedBox(height: 26),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Row(
                  children: [
                    Column(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Constants.bgColorLight,
                          radius: 24,
                          child: Icon(
                            Icons.person,
                            color: Constants.activeColor,
                          ),
                        ),
                        Text(
                          "You",
                          style: AppTheme.subHeadingText,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Lottie.asset(
                      Constants.arrowLogo,
                      width: 180,
                      height: 180,
                      repeat: false,
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Constants.bgColorLight,
                          radius: 24,
                          child: Icon(
                            Icons.person,
                            color: Constants.activeColor,
                          ),
                        ),
                        Text(
                          widget.entity.name,
                          style: AppTheme.subHeadingText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: SvgPicture.asset(
                    Constants.cashLogo,
                    // color: Constants.activeColor,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 0.4.sw,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        controller: settleCtrl,
                        decoration: InputDecoration(
                          hintText: "0.00",
                          prefixText: "\$",
                          helper: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "You owe ",
                                  style: AppTheme.normalText
                                      .copyWith(color: Colors.grey.shade600),
                                ),
                                TextSpan(
                                  text:
                                      "\$${widget.entity.amount.toStringAsFixed(2)}",
                                  style: AppTheme.normalText.copyWith(
                                    color: Constants.redColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter an amount';
                          }

                          double entered = double.tryParse(val) ?? 0;

                          if (entered > widget.entity.amount) {
                            return "Cannot exceed \$${widget.entity.amount.toStringAsFixed(2)}";
                          }

                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () async {
                  if (formKey.currentState!.validate()) {
                    AlertWidgets.showLoadingDialog(context,
                        message: 'Please wait ...');

                    await groupCtrl.settleExpense(
                        groupId: widget.groupId,
                        toUserId: widget.entity.userId,
                        amount: double.parse(settleCtrl.value.text));
                  }
                },
                child: Container(
                  width: 0.4.sw,
                  height: 36,
                  decoration: BoxDecoration(
                      color: Constants.activeColor,
                      borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text("Settle Up",
                      style: AppTheme.subHeadingText.copyWith(
                        color: Constants.textLight,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
