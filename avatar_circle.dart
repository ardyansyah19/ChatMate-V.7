import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  final String initials;
  final Color color;
  final double radius;
  final bool showOnlineDot;

  const AvatarCircle({
    super.key,
    required this.initials,
    required this.color,
    this.radius = 26,
    this.showOnlineDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: color,
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: radius * 0.65,
            ),
          ),
        ),
        if (showOnlineDot)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: radius * 0.36,
              height: radius * 0.36,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
