
import 'package:flutter/material.dart';
import 'package:kiranapp/emoji/src/emoji_skin_tones.dart';

class EmojiSkinDot extends StatelessWidget {
  final int? skin;

  const EmojiSkinDot({Key? key, this.skin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: EmojiSkinTones.tones[skin!],
        shape: BoxShape.circle,
      ),
    );
  }
}
