import 'package:flutter/material.dart';

class MikoziBrand extends StatelessWidget {
  const MikoziBrand({
    this.logoSize = 52,
    this.showName = true,
    this.foregroundColor,
    super.key,
  });

  final double logoSize;
  final bool showName;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mikozi',
      image: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(logoSize * 0.9),
            child: Image.asset(
              'assets/brand/mikozi-logo.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          if (showName) ...[
            const SizedBox(width: 13),
            Text(
              'Mikozi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
