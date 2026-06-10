import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'coins_display.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? scoreWidget;

  const GameAppBar({
    super.key,
    required this.title,
    this.actions,
    this.scoreWidget,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.goldPrimary),
      ),
      title: Text(title,
          style: const TextStyle(
              color: AppTheme.goldPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 3)),
      actions: [
        if (scoreWidget != null) scoreWidget!,
        const CoinsDisplay(),
        const SizedBox(width: 8),
        ...(actions ?? []),
      ],
    );
  }
}
