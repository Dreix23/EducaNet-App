import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const CustomAppBar({
    Key? key,
    required this.userName,
    required this.onProfileTap,
    required this.onLogoutTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(userName, style: TextStyle(color: Colors.black)),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.account_circle, color: Colors.black),
        onPressed: onProfileTap,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.black),
          onPressed: onLogoutTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
