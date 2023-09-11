

import 'package:kiranapp/emoji/src/emoji_category.dart';
import 'package:kiranapp/emoji/src/emoji_category_Icon.dart';
import 'package:kiranapp/emoji/src/emoji_internal_data.dart';

class EmojiGroup {
  final EmojiCategory category;
  final EmojiCategoryIcon icon;
  final String title;
  final List<String> names;
  final List<List<EmojiInternalData>> pages = [];

  EmojiGroup(this.category, this.icon, this.title, this.names);
}
