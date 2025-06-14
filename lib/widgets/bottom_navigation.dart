import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        // ...existing items...
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
      onTap: (index) {},
    );
  }
}
