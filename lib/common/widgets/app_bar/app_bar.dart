import 'package:flutter/material.dart';
import 'package:sporify/common/helpers/is_dark.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? action;
  final Widget? leading;
  final bool hideback;
  const BasicAppBar({
    this.title,
    super.key,
    this.hideback = false,
    this.action,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: title ?? const Text(''),
      actions: action != null ? [action!] : null,
      centerTitle: true,
      leading:
          leading ??
          (hideback
              ? null
              : IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.white.withOpacity(0.03)
                          : Colors.black.withOpacity(0.04),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 15,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                )),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
