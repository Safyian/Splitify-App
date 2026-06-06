import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';

/// A single row showing a person's avatar, name, optional subtitle (email or
/// phone), and a trailing action chip.
///
/// States:
///   isAdded     = greyed avatar + "Added" chip (not tappable)
///   isProcessing = spinner label "..." on the button, not tappable
///   default     = teal avatar + [addLabel] button, calls onTap
class PersonRow extends StatelessWidget {
  const PersonRow({
    super.key,
    required this.name,
    this.subtitle,
    this.isAdded = false,
    this.isProcessing = false,
    this.onTap,
    this.addLabel = 'Add',
  });

  final String name;
  final String? subtitle;
  final bool isAdded;
  final bool isProcessing;
  final VoidCallback? onTap;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    final muted = isAdded || isProcessing;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // ── Avatar ─────────────────────────────────────────────────────────
          CircleAvatar(
            radius: 20,
            backgroundColor: isAdded
                ? Colors.grey.withAlpha(30)
                : Constants.activeColor.withAlpha(20),
            child: Text(
              initial,
              style: AppTheme.normalText.copyWith(
                color: isAdded ? Colors.grey.shade400 : Constants.activeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Name + subtitle ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.normalText.copyWith(
                    fontWeight: FontWeight.w500,
                    color: muted ? Colors.black45 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: AppTheme.normalText.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // ── Trailing chip ─────────────────────────────────────────────────
          if (isAdded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withAlpha(40)),
              ),
              child: Text(
                'Added',
                style: AppTheme.normalText.copyWith(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: isProcessing ? null : onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isProcessing
                      ? Colors.grey.withAlpha(15)
                      : Constants.activeColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Constants.activeColor.withAlpha(60)),
                ),
                child: Text(
                  isProcessing ? '...' : addLabel,
                  style: AppTheme.normalText.copyWith(
                    color: Constants.activeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
