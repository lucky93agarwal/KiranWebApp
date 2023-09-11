import 'dart:convert';
import 'dart:math';

import 'package:emoji_choose/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kiranapp/emoji/src/emoji_category.dart';
import 'package:kiranapp/emoji/src/emoji_category_Icon.dart';
import 'package:kiranapp/emoji/src/emoji_category_selector.dart';
import 'package:kiranapp/emoji/src/emoji_data.dart';
import 'package:kiranapp/emoji/src/emoji_group.dart';
import 'package:kiranapp/emoji/src/emoji_internal_data.dart';
import 'package:kiranapp/emoji/src/emoji_page.dart';
import 'package:kiranapp/emoji/src/emoji_skin_tone_selector.dart';

class EmojiSelector extends StatefulWidget {
  final int columns;
  final int rows;
  final Function(EmojiData) onSelected;

  const EmojiSelector({
    Key? key,
    this.columns = 10,
    this.rows = 5,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmojiSelectorState();
}

class _EmojiSelectorState extends State<EmojiSelector> {
  EmojiCategory selectedCategory = EmojiCategory.smileys;

  final List<EmojiInternalData> _emojis = [];
  final Map<EmojiCategory, EmojiGroup> _groups = {
    EmojiCategory.smileys: EmojiGroup(
      EmojiCategory.smileys,
      EmojiCategoryIcons.smileyIcon,
      'smileys & People',
      ['smileys & Emotion', 'People & Body'],
    ),
    EmojiCategory.animals: EmojiGroup(
      EmojiCategory.animals,
      EmojiCategoryIcons.animalIcon,
      'animals & Nature',
      ['animals & Nature'],
    ),
    EmojiCategory.foods: EmojiGroup(
      EmojiCategory.foods,
      EmojiCategoryIcons.foodIcon,
      'Food & Drink',
      ['Food & Drink'],
    ),
    EmojiCategory.activities: EmojiGroup(
      EmojiCategory.activities,
      EmojiCategoryIcons.activityIcon,
      'Activity',
      ['activities'],
    ),
    EmojiCategory.travel: EmojiGroup(
      EmojiCategory.travel,
      EmojiCategoryIcons.travelIcon,
      'travel & Places',
      ['travel & Places'],
    ),
    EmojiCategory.objects: EmojiGroup(
      EmojiCategory.objects,
      EmojiCategoryIcons.objectIcon,
      'objects',
      ['objects'],
    ),
    EmojiCategory.symbols: EmojiGroup(
      EmojiCategory.symbols,
      EmojiCategoryIcons.symbolIcon,
      'symbols',
      ['symbols'],
    ),
    EmojiCategory.flags: EmojiGroup(
      EmojiCategory.flags,
      EmojiCategoryIcons.flagIcon,
      'flags',
      ['flags'],
    ),
  };
  List<EmojiCategory> order = [
    EmojiCategory.smileys,
    EmojiCategory.animals,
    EmojiCategory.foods,
    EmojiCategory.activities,
    EmojiCategory.travel,
    EmojiCategory.objects,
    EmojiCategory.symbols,
    EmojiCategory.flags,
  ];

  int _skin = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    loadEmoji(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return Container();

    int smileysNum = _groups[EmojiCategory.smileys]!.pages.length;
    int animalsNum = _groups[EmojiCategory.animals]!.pages.length;
    int foodsNum = _groups[EmojiCategory.foods]!.pages.length;
    int activitiesNum = _groups[EmojiCategory.activities]!.pages.length;
    int travelNum = _groups[EmojiCategory.travel]!.pages.length;
    int objectsNum = _groups[EmojiCategory.objects]!.pages.length;
    int symbolsNum = _groups[EmojiCategory.symbols]!.pages.length;
    int flagsNum = _groups[EmojiCategory.flags]!.pages.length;

    PageController pageController;
    switch (selectedCategory) {
      case EmojiCategory.smileys:
        pageController = PageController(initialPage: 0);
        break;
      case EmojiCategory.animals:
        pageController = PageController(initialPage: smileysNum);
        break;
      case EmojiCategory.foods:
        pageController = PageController(initialPage: smileysNum + animalsNum);
        break;
      case EmojiCategory.activities:
        pageController =
            PageController(initialPage: smileysNum + animalsNum + foodsNum);
        break;
      case EmojiCategory.travel:
        pageController = PageController(
            initialPage: smileysNum + animalsNum + foodsNum + activitiesNum);
        break;
      case EmojiCategory.objects:
        pageController = PageController(
            initialPage:
            smileysNum + animalsNum + foodsNum + activitiesNum + travelNum);
        break;
      case EmojiCategory.symbols:
        pageController = PageController(
            initialPage: smileysNum +
                animalsNum +
                foodsNum +
                activitiesNum +
                travelNum +
                objectsNum);
        break;
      case EmojiCategory.flags:
        pageController = PageController(
            initialPage: smileysNum +
                animalsNum +
                foodsNum +
                activitiesNum +
                travelNum +
                objectsNum +
                symbolsNum);
        break;
      default:
        pageController = PageController(initialPage: 0);
        break;
    }
    pageController.addListener(() {
      setState(() {});
    });

    List<Widget> pages = [];
    List<Widget> selectors = [];
    EmojiGroup selectedGroup = _groups[selectedCategory]!;
    int index = 0;
    for (EmojiCategory category in _groups.keys) {
      EmojiGroup group = _groups[category]!;
      pages.addAll(group.pages.map((e) => EmojiPage(
        rows: widget.rows,
        columns: widget.columns,
        skin: _skin,
        emojis: e,
        onSelected: (internalData) {
          EmojiData emoji = EmojiData(
            id: internalData.id,
            name: internalData.name,
            unified: internalData.unifiedForSkin(_skin),
            char: internalData.charForSkin(_skin),
            category: internalData.category,
            skin: _skin,
          );
          widget.onSelected(emoji);
        },
      )));
      int current = index;
      selectors.add(
        EmojiCategorySelector(
          icon: group.icon,
          selected: selectedCategory == group.category,
          onSelected: () {
            pageController.jumpToPage(current);
          },
        ),
      );
      index += group.pages.length;
    }
    selectors.add(
      EmojiSkinToneSelector(onSkinChanged: (skin) {
        setState(() {
          _skin = skin;
        });
      }),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            10.0,
            10.0,
            10.0,
            4.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedGroup.title.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.caption!.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: (MediaQuery.of(context).size.width / widget.columns),
          child: PageView(
            pageSnapping: true,
            controller: pageController,
            onPageChanged: (index) {
              if (index < smileysNum) {
                selectedCategory = EmojiCategory.smileys;
              } else if (index < smileysNum + animalsNum) {
                selectedCategory = EmojiCategory.animals;
              } else if (index < smileysNum + animalsNum + foodsNum) {
                selectedCategory = EmojiCategory.foods;
              } else if (index <
                  smileysNum + animalsNum + foodsNum + activitiesNum) {
                selectedCategory = EmojiCategory.activities;
              } else if (index <
                  smileysNum +
                      animalsNum +
                      foodsNum +
                      activitiesNum +
                      travelNum) {
                selectedCategory = EmojiCategory.travel;
              } else if (index <
                  smileysNum +
                      animalsNum +
                      foodsNum +
                      activitiesNum +
                      travelNum +
                      objectsNum) {
                selectedCategory = EmojiCategory.objects;
              } else if (index <
                  smileysNum +
                      animalsNum +
                      foodsNum +
                      activitiesNum +
                      travelNum +
                      objectsNum +
                      symbolsNum) {
                selectedCategory = EmojiCategory.symbols;
              } else if (index <
                  smileysNum +
                      animalsNum +
                      foodsNum +
                      activitiesNum +
                      travelNum +
                      objectsNum +
                      symbolsNum +
                      flagsNum) {
                selectedCategory = EmojiCategory.flags;
              }
            },
            children: pages,
          ),
        ),
        SizedBox(
          /* Category PICKER */
          height: 50,
          child: Row(
            children: selectors,
          ),
        ),
      ],
    );
  }

  loadEmoji(BuildContext context) async {
    const path = 'packages/kiranapp/data/emoji.json';
    String data = await rootBundle.loadString(path);
    final emojiList = json.decode(data);
    for (var emojiJson in emojiList) {
      EmojiInternalData data = EmojiInternalData.fromJson(emojiJson);
      _emojis.add(data);
    }
    // Per Category, create pages
    for (EmojiCategory category in order) {
      EmojiGroup group = _groups[category]!;
      List<EmojiInternalData> categoryEmojis = [];
      for (String name in group.names) {
        List<EmojiInternalData> subName = _emojis
            .where((element) => element.category == name && element.hasApple!)
            .toList();
        subName.sort((lhs, rhs) => lhs.sortOrder!.compareTo(rhs.sortOrder!));
        categoryEmojis.addAll(subName);
      }

      // Create pages for that Category
      int num = (categoryEmojis.length / (widget.rows * widget.columns)).ceil();
      for (var i = 0; i < num; i++) {
        int start = widget.columns * widget.rows * i;
        int end =
        min(widget.columns * widget.rows * (i + 1), categoryEmojis.length);
        List<EmojiInternalData> pageEmojis = categoryEmojis.sublist(start, end);
        group.pages.add(pageEmojis);
      }
    }
    setState(() {
      _loaded = true;
    });
  }
}
