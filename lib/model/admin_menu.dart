import 'package:flutter/material.dart';

class AdminMenu {
  final String title;
  final Icon icon;
  AdminMenu({required this.title, required this.icon});
}

List<AdminMenu> menuData = [
  AdminMenu(
    title: 'All Users',
    icon: const Icon(
      Icons.groups,
      color: Colors.white,
      size: 27.0,
    ),
  ),
  AdminMenu(
    title: 'Admin Users',
    icon: const Icon(
      Icons.groups,
      color: Colors.white,
      size: 27.0,
    ),
  ),

  AdminMenu(
    title: 'Office Staff',
    icon: const Icon(
      Icons.groups,
      color: Colors.white,
      size: 27.0,
    ),
  ),
];
