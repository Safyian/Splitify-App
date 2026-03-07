// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
// import 'package:splitify/features/groups/groups_controller.dart';
//
// import '../../core/constants/constants.dart';
// import '../../core/theme/app_themes.dart';
// import '../../shared/widgets/alert_widgets.dart';
// import 'group_summary_model.dart';
//
// class SettleUpView extends StatelessWidget {
//   SettleUpView({super.key, required this.index});
//   final int index;
//   final groupCtrl = Get.find<GroupsController>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Constants.bgColor,
//       appBar: AppBar(
//         centerTitle: false,
//         title: Text(
//           "Settle Up",
//           style: AppTheme.normalText,
//         ),
//         titleSpacing: 0.0,
//         leading: GestureDetector(
//           onTap: () => Get.back(),
//           child: Container(
//             width: 24.w,
//             height: 24.w,
//             alignment: Alignment.center,
//             child: SvgPicture.asset(
//               Constants.backLogo,
//               width: 24.w,
//               height: 24.w,
//             ),
//           ),
//         ),
//         backgroundColor: Constants.bgColor,
//         foregroundColor: Constants.bgColor,
//       ),
//       body: Container(
//         width: Get.width,
//         height: Get.height,
//         color: Constants.bgColor,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Obx(() {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               groupCtrl.summaries[index].balance.status ==
//                       BalanceStatus.youAreOwed
//                   ? Text(
//                       "You're owed",
//                       style: AppTheme.subHeadingText,
//                     )
//                   : Text(
//                       "Make full or partial settlement",
//                       style: AppTheme.subHeadingText,
//                     ),
//               const SizedBox(height: 12),
//               ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   padding: const EdgeInsets.only(top: 6),
//                   itemCount: groupCtrl.summaries[index].preview.length,
//                   itemBuilder: (context, index) {
//                     var entity = groupCtrl.summaries[this.index].preview[index];
//                     return GestureDetector(
//                       onTap: () => Get.to(() => SettleAmountView(
//                           entity: entity,
//                           groupId: groupCtrl.summaries[this.index].id)),
//                       child: Container(
//                         color: Constants.bgColor,
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 const CircleAvatar(
//                                   backgroundColor: Constants.bgColorLight,
//                                   radius: 24,
//                                   child: Icon(
//                                     Icons.person,
//                                     color: Constants.activeColor,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Text(
//                                   entity.name,
//                                   style: AppTheme.subHeadingText,
//                                 ),
//                                 const Spacer(),
//                                 Column(
//                                   children: [
//                                     Text(
//                                       entity.direction ==
//                                               PreviewDirection.youPay
//                                           ? "You owe"
//                                           : "Owes you",
//                                       style: AppTheme.normalText,
//                                     ),
//                                     Text(
//                                       "\$${entity.amount}",
//                                       style: AppTheme.subHeadingText.copyWith(
//                                         color: entity.direction ==
//                                                 PreviewDirection.youPay
//                                             ? Constants.redColor
//                                             : Constants.activeColor,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             index <
//                                     groupCtrl.summaries[this.index].preview
//                                             .length -
//                                         1
//                                 ? const Divider(
//                                     indent: 12, endIndent: 12, height: 20)
//                                 : const SizedBox(),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//               SizedBox(height: 0.1.sh),
//               Center(
//                 child: Lottie.asset(Constants.settleLogo,
//                     width: 280, height: 280, repeat: false),
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }
//
// class SettleAmountView extends StatefulWidget {
//   SettleAmountView({super.key, required this.entity, required this.groupId});
//   final Preview entity;
//   final String groupId;
//
//   @override
//   State<SettleAmountView> createState() => _SettleAmountViewState();
// }
//
// class _SettleAmountViewState extends State<SettleAmountView> {
//   late TextEditingController settleCtrl;
//
//   final formKey = GlobalKey<FormState>();
//   final groupCtrl = Get.find<GroupsController>();
//   @override
//   void initState() {
//     super.initState();
//     settleCtrl = TextEditingController(
//       text: widget.entity.amount.toStringAsFixed(2),
//     );
//   }
//
//   @override
//   void dispose() {
//     settleCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Constants.bgColor,
//       appBar: AppBar(
//         leading: GestureDetector(
//           onTap: () => Get.back(),
//           child: Container(
//             width: 24.w,
//             height: 24.w,
//             alignment: Alignment.center,
//             child: SvgPicture.asset(
//               Constants.backLogo,
//               width: 24.w,
//               height: 24.w,
//             ),
//           ),
//         ),
//         backgroundColor: Constants.bgColor,
//         foregroundColor: Constants.bgColor,
//       ),
//       body: Container(
//         width: Get.width,
//         height: Get.height,
//         color: Constants.bgColor,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Make full or partial settlement",
//               style: AppTheme.subHeadingText,
//             ),
//             const SizedBox(height: 26),
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 36),
//                 child: Row(
//                   children: [
//                     Column(
//                       children: [
//                         const CircleAvatar(
//                           backgroundColor: Constants.bgColorLight,
//                           radius: 24,
//                           child: Icon(
//                             Icons.person,
//                             color: Constants.activeColor,
//                           ),
//                         ),
//                         Text(
//                           "You",
//                           style: AppTheme.subHeadingText,
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     Lottie.asset(
//                       Constants.arrowLogo,
//                       width: 180,
//                       height: 180,
//                       repeat: false,
//                     ),
//                     const Spacer(),
//                     Column(
//                       children: [
//                         const CircleAvatar(
//                           backgroundColor: Constants.bgColorLight,
//                           radius: 24,
//                           child: Icon(
//                             Icons.person,
//                             color: Constants.activeColor,
//                           ),
//                         ),
//                         Text(
//                           widget.entity.name,
//                           style: AppTheme.subHeadingText,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // const SizedBox(height: 26),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   width: 32,
//                   height: 32,
//                   child: SvgPicture.asset(
//                     Constants.cashLogo,
//                     // color: Constants.activeColor,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 SizedBox(
//                   width: 0.4.sw,
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 12.0),
//                     child: Form(
//                       key: formKey,
//                       child: TextFormField(
//                         controller: settleCtrl,
//                         decoration: InputDecoration(
//                           hintText: "0.00",
//                           prefixText: "\$",
//                           helper: RichText(
//                             text: TextSpan(
//                               children: <TextSpan>[
//                                 TextSpan(
//                                   text: "You owe ",
//                                   style: AppTheme.normalText
//                                       .copyWith(color: Colors.grey.shade600),
//                                 ),
//                                 TextSpan(
//                                   text:
//                                       "\$${widget.entity.amount.toStringAsFixed(2)}",
//                                   style: AppTheme.normalText.copyWith(
//                                     color: Constants.redColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           isDense: true,
//                         ),
//                         keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true),
//                         validator: (val) {
//                           if (val == null || val.isEmpty) {
//                             return 'Please enter an amount';
//                           }
//
//                           double entered = double.tryParse(val) ?? 0;
//
//                           if (entered > widget.entity.amount) {
//                             return "Cannot exceed \$${widget.entity.amount.toStringAsFixed(2)}";
//                           }
//
//                           return null;
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Center(
//               child: GestureDetector(
//                 onTap: () async {
//                   if (formKey.currentState!.validate()) {
//                     AlertWidgets.showLoadingDialog(context,
//                         message: 'Please wait ...');
//
//                     await groupCtrl.settleExpense(
//                         groupId: widget.groupId,
//                         toUserId: widget.entity.userId,
//                         amount: double.parse(settleCtrl.value.text));
//                   }
//                 },
//                 child: Container(
//                   width: 0.4.sw,
//                   height: 36,
//                   decoration: BoxDecoration(
//                       color: Constants.activeColor,
//                       borderRadius: BorderRadius.circular(8)),
//                   alignment: Alignment.center,
//                   child: Text("Settle Up",
//                       style: AppTheme.subHeadingText.copyWith(
//                         color: Constants.textLight,
//                       )),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// **************** Cloude Code ************
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

// ── Settle Up View (member list) ───────────────────────────────────────────────
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
        title: Text("Settle Up", style: AppTheme.headingText),
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
      body: Obx(() {
        final preview = groupCtrl.summaries[index].preview;
        final status = groupCtrl.summaries[index].balance.status;
        final isOwed = status == BalanceStatus.youAreOwed;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status Banner ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isOwed
                      ? Constants.activeColor.withAlpha(25)
                      : Constants.redColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isOwed
                        ? Constants.activeColor.withAlpha(60)
                        : Constants.redColor.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isOwed
                            ? Constants.activeColor.withAlpha(40)
                            : Constants.redColor.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOwed
                            ? Icons.call_received_rounded
                            : Icons.call_made_rounded,
                        color:
                            isOwed ? Constants.activeColor : Constants.redColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOwed ? "You are owed" : "You owe",
                            style: AppTheme.normalText
                                .copyWith(color: Colors.grey),
                          ),
                          Text(
                            isOwed
                                ? "Tap a person below to record a payment"
                                : "Select who you want to settle with",
                            style: AppTheme.normalText.copyWith(
                              color: isOwed
                                  ? Constants.activeColor
                                  : Constants.redColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text("People", style: AppTheme.subHeadingText),
              const SizedBox(height: 10),

              // ── Member List ────────────────────────────────────
              ...preview.asMap().entries.map((entry) {
                final i = entry.key;
                final entity = entry.value;
                final youPay = entity.direction == PreviewDirection.youPay;

                return GestureDetector(
                  onTap: () => Get.to(
                    () => SettleAmountView(
                      entity: entity,
                      groupId: groupCtrl.summaries[index].id,
                    ),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 300),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Constants.bgColorLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // ── Avatar with initial ──────────────────
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Constants.activeColor.withAlpha(25),
                          child: Text(
                            entity.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Constants.activeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // ── Name + direction ─────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entity.name,
                                style: AppTheme.subHeadingText,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                youPay
                                    ? "Tap to settle your debt"
                                    : "Tap to record their payment",
                                style: AppTheme.normalText.copyWith(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Amount + arrow ───────────────────────
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${entity.amount.toStringAsFixed(2)}",
                              style: AppTheme.subHeadingText.copyWith(
                                color: youPay
                                    ? Constants.redColor
                                    : Constants.activeColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              youPay ? "you owe" : "owes you",
                              style: AppTheme.normalText.copyWith(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // ── Lottie animation ───────────────────────────────
              const SizedBox(height: 20),
              Center(
                child: Lottie.asset(
                  Constants.settleLogo,
                  width: 220,
                  height: 220,
                  repeat: false,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Settle Amount View ─────────────────────────────────────────────────────────
class SettleAmountView extends StatefulWidget {
  const SettleAmountView({
    super.key,
    required this.entity,
    required this.groupId,
  });
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
    final youPay = widget.entity.direction == PreviewDirection.youPay;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──────────────────────────────────────────
              Text(
                youPay
                    ? "Settling with ${widget.entity.name}"
                    : "Recording payment from ${widget.entity.name}",
                style: AppTheme.headingText,
              ),
              const SizedBox(height: 4),
              Text(
                youPay
                    ? "Enter the amount you want to pay"
                    : "Enter the amount they paid you",
                style: AppTheme.normalText.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // ── You → Them animation ───────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Constants.bgColorLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── From ──
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Constants.activeColor.withAlpha(25),
                          child: Text(
                            youPay ? "You" : widget.entity.name[0],
                            style: TextStyle(
                              color: Constants.activeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          youPay ? "You" : widget.entity.name,
                          style: AppTheme.normalText,
                        ),
                      ],
                    ),

                    // ── Arrow animation ──
                    Expanded(
                      child: Lottie.asset(
                        Constants.arrowLogo,
                        height: 80,
                        repeat: false,
                      ),
                    ),

                    // ── To ──
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Constants.activeColor.withAlpha(25),
                          child: Text(
                            youPay ? widget.entity.name[0] : "You",
                            style: TextStyle(
                              color: Constants.activeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          youPay ? widget.entity.name : "You",
                          style: AppTheme.normalText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Amount input ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Constants.bgColorLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Amount", style: AppTheme.subHeadingText),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: settleCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: AppTheme.headingText.copyWith(fontSize: 28),
                      decoration: InputDecoration(
                        prefixText: "\$ ",
                        prefixStyle:
                            AppTheme.headingText.copyWith(fontSize: 28),
                        border: InputBorder.none,
                        hintText: "0.00",
                        hintStyle: AppTheme.headingText.copyWith(
                          fontSize: 28,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final entered = double.tryParse(val) ?? 0;
                        if (entered <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        if (entered > widget.entity.amount) {
                          return "Cannot exceed \$${widget.entity.amount.toStringAsFixed(2)}";
                        }
                        return null;
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 4),

                    // ── Quick amount chips ───────────────────────
                    Row(
                      children: [
                        _QuickAmount(
                          label: "25%",
                          onTap: () => settleCtrl.text =
                              (widget.entity.amount * 0.25).toStringAsFixed(2),
                        ),
                        const SizedBox(width: 8),
                        _QuickAmount(
                          label: "50%",
                          onTap: () => settleCtrl.text =
                              (widget.entity.amount * 0.50).toStringAsFixed(2),
                        ),
                        const SizedBox(width: 8),
                        _QuickAmount(
                          label: "75%",
                          onTap: () => settleCtrl.text =
                              (widget.entity.amount * 0.75).toStringAsFixed(2),
                        ),
                        const SizedBox(width: 8),
                        _QuickAmount(
                          label: "Full",
                          onTap: () => settleCtrl.text =
                              widget.entity.amount.toStringAsFixed(2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Outstanding: \$${widget.entity.amount.toStringAsFixed(2)}",
                      style: AppTheme.normalText.copyWith(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Settle button ──────────────────────────────────
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.activeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: groupCtrl.isSettling.isTrue
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                AlertWidgets.showLoadingDialog(context,
                                    message: 'Processing...');
                                await groupCtrl.settleExpense(
                                  groupId: widget.groupId,
                                  toUserId: widget.entity.userId,
                                  amount: double.parse(settleCtrl.text.trim()),
                                );
                              }
                            },
                      child: groupCtrl.isSettling.isTrue
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              youPay ? "Confirm Payment" : "Record Payment",
                              style: AppTheme.subHeadingText.copyWith(
                                color: Constants.textLight,
                              ),
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick Amount Chip ──────────────────────────────────────────────────────────
class _QuickAmount extends StatelessWidget {
  const _QuickAmount({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Constants.activeColor.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Constants.activeColor.withAlpha(60),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Constants.activeColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
