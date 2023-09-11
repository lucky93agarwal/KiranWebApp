
import 'package:flutter/material.dart';
import 'package:kiranapp/emoji/src/emoji_skin_dot.dart';
import 'package:kiranapp/emoji/src/emoji_skin_tones.dart';

class EmojiSkinToneSelector extends StatefulWidget {
  final Function(int) onSkinChanged;

  const EmojiSkinToneSelector({
    Key? key,
    required this.onSkinChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmojiSkinToneState();
}

class _EmojiSkinToneState extends State<EmojiSkinToneSelector> {
  int _skin = 0;
  late OverlayEntry _overlayEntry;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return SkinDotButton(
      skin: _skin,
      onPressed: () {
        if (_expanded) {
          _overlayEntry.remove();
        } else {
          _overlayEntry = createOverlay(context);
          Overlay.of(context)!.insert(_overlayEntry);
        }
        setState(() {
          _expanded = !_expanded;
        });
      },
    );
  }

  OverlayEntry createOverlay(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    List<Widget> dots = [];
    for (var i = 0; i < EmojiSkinTones.tones.length; i++) {
      dots.add(
        SkinDotButton(
          skin: i,
          onPressed: () {
            _overlayEntry.remove();
            setState(() {
              _skin = i;
              _expanded = false;
            });
            widget.onSkinChanged(_skin);
          },
        ),
      );
    }

    var w = size.width * 6;
    return OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx - w + size.width,
          top: offset.dy - size.height,
          width: w,
          height: size.height,
          child: Material(
            elevation: 4.0,
            child: Row(
              children: dots,
            ),
          ),
        ));
  }
}

class SkinDotButton extends StatelessWidget {
  final int? skin;
  final Function()? onPressed;

  const SkinDotButton({Key? key, this.skin, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 20,
      height: MediaQuery.of(context).size.width / 20,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(0.0),
        ),
        autofocus: true,
        onPressed: onPressed,
        child: EmojiSkinDot(
          skin: skin,
        ),
      ),
    );
  }
}
