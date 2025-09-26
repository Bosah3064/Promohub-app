import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RegistrationHeaderWidget extends StatelessWidget {
  final VoidCallback onBackPressed;

  const RegistrationHeaderWidget({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBackPressed,
                    icon: Icon(Icons.arrow_back, size: 5.w),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: Text(
                  'Join PromoHub and start buying, selling, and trading with confidence in Africa\'s trusted marketplace.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
