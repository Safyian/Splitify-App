import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_themes.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    required this.onApple,
    required this.onGoogle,
    this.label = 'Sign in with',
  });

  final VoidCallback onApple;
  final VoidCallback onGoogle;
  final String label;

  // Apple HIG: logo-only buttons must be 1:1 aspect ratio
  // Minimum recommended: 44pt, but can be larger[reference:8]
  static final double _buttonSize = 56.r;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$label:',
          style: AppTheme.normalText.copyWith(color: Colors.grey.shade600),
        ),
        SizedBox(height: 14.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (Platform.isIOS) ...[
              _AppleLogoOnlyButton(
                size: _buttonSize,
                onTap: onApple,
              ),
              // Margin: at least 1/10 of button height[reference:9]
              SizedBox(width: _buttonSize * 0.2),
            ],
            _GoogleButton(
              size: _buttonSize,
              onTap: onGoogle,
            ),
          ],
        ),
      ],
    );
  }
}

/// Apple logo-only button following HIG guidelines[reference:10]
class _AppleLogoOnlyButton extends StatelessWidget {
  const _AppleLogoOnlyButton({
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          // Apple HIG: background must be black or white[reference:11]
          color: Colors.white,
          shape: BoxShape.circle, // circular is allowed[reference:12]
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        // Apple HIG: artwork already includes correct padding[reference:13]
        // Don't crop, don't add padding, don't scale down the logo[reference:14]
        child: SvgPicture.asset(
          'assets/images/apple_logo.svg',
          // Use the artwork as-is - it already has correct internal padding
          // Setting width/height to size fills the button while preserving
          // the artwork's built-in padding[reference:15]
          width: size,
          height: size,
          // BoxFit.none or fit: BoxFit.scaleDown preserves artwork padding
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}

/// Google sign-in button (matching visual style)
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/images/google_logo.svg',
          width: size * 0.32,
          height: size * 0.32,
        ),
      ),
    );
  }
}
