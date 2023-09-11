
import 'package:flutter/material.dart';
import 'package:kiranapp/emoji/src/emoji_selector.dart';


class EmojiPickerWidget extends StatelessWidget {
  final ValueChanged<String> onEmojiSelecterd;
  const EmojiPickerWidget({Key? key,required this.onEmojiSelecterd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: EmojiSelector(
        rows: 2,
        onSelected: (emoji) {
          onEmojiSelecterd(emoji.char);
          print('Selected emoji ${emoji.char}');
        },
      ),
    );
  }
}
