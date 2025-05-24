import 'package:flutter/material.dart';

/// AppBar sur font clair
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final bool centerTitle;
  final double horizontalPadding;
  final TextStyle? titleTextStyle;
  final Color? backgroundColor;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.centerTitle = true,
    this.horizontalPadding = 16.0,
    this.titleTextStyle,
    this.backgroundColor,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: AppBar(
        backgroundColor: backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
        leading: leading,
        title: Text(
          title,
          style: titleTextStyle ?? Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: centerTitle,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}