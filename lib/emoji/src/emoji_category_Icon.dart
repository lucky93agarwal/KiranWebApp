import 'package:flutter/material.dart';

class EmojiCategoryIcon {
  final IconData icon;
  final Color color;
  final Color selectedColor;

  const EmojiCategoryIcon({
    required this.icon,
    this.color = const Color.fromRGBO(211, 211, 211, 1),
    this.selectedColor = const Color.fromRGBO(178, 178, 178, 1),
  });
}

class EmojiCategoryIcons {
  static const EmojiCategoryIcon recommendationIcon =
  EmojiCategoryIcon(icon: Icons.search);

  static const EmojiCategoryIcon recentIcon = EmojiCategoryIcon(icon: Icons.access_time);

  static const EmojiCategoryIcon smileyIcon = EmojiCategoryIcon(icon: Icons.tag_faces);

  static const EmojiCategoryIcon peopleIcon = EmojiCategoryIcon(icon: Icons.person);

  static const EmojiCategoryIcon animalIcon = EmojiCategoryIcon(icon: Icons.pets);

  static const EmojiCategoryIcon foodIcon = EmojiCategoryIcon(icon: Icons.fastfood);

  static const EmojiCategoryIcon travelIcon =
  EmojiCategoryIcon(icon: Icons.location_city);

  static const EmojiCategoryIcon activityIcon =
  EmojiCategoryIcon(icon: Icons.directions_run);

  static const EmojiCategoryIcon objectIcon =
  EmojiCategoryIcon(icon: Icons.lightbulb_outline);

  static const EmojiCategoryIcon symbolIcon = EmojiCategoryIcon(icon: Icons.euro_symbol);

  static const EmojiCategoryIcon flagIcon = EmojiCategoryIcon(icon: Icons.flag);
}
