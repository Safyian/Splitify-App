import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../features/friends/friends_model.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({
    super.key,
    required this.friend,
    this.onRemove,
    this.onTap,
  });

  final Friend friend;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final net = friend.balance.net;
    final status = friend.balance.status;
    final isSettled = status == FriendBalanceStatus.settled;
    final youOwe = status == FriendBalanceStatus.youOwe;

    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Constants.bgColorLight,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.08)),
          ),
        ),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────────
            CircleAvatar(
              radius: 19,
              backgroundColor: Constants.activeColor.withAlpha(28),
              child: Text(
                friend.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Constants.activeColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Name ─────────────────────────────────────────────
            Expanded(
              child: Text(
                friend.name,
                style:
                    AppTheme.normalText.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── Balance ──────────────────────────────────────────
            if (isSettled)
              Text(
                "Settled",
                style: AppTheme.normalText.copyWith(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${net.abs().toStringAsFixed(2)}",
                    style: AppTheme.normalText.copyWith(
                      color:
                          youOwe ? Constants.redColor : Constants.activeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    youOwe ? "you owe" : "owes you",
                    style: AppTheme.normalText.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    // Only explicit friends can be swiped to remove
    if (!friend.isExplicitFriend || onRemove == null) return card;

    return Dismissible(
      key: Key(friend.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await Get.dialog<bool>(
              AlertDialog(
                backgroundColor: Constants.bgColorLight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text("Remove Friend", style: AppTheme.subHeadingText),
                content: Text(
                  "Remove ${friend.name} from your friends list?",
                  style: AppTheme.normalText,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text("Cancel",
                        style:
                            AppTheme.normalText.copyWith(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text("Remove",
                        style: AppTheme.normalText.copyWith(
                          color: Constants.redColor,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onRemove?.call(),
      background: Container(
        color: Constants.redColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_remove_outlined, color: Colors.white, size: 22),
            SizedBox(height: 4),
            Text(
              "Remove",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: card,
    );
  }
}
