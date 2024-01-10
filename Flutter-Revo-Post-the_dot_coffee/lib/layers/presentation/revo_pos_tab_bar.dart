import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';

class RevoPosTabBar extends StatelessWidget {
  final TabController controller;
  final bool? isScrollable;
  final List items;
  final Widget Function(dynamic) itemBuilder;
  final Color? labelColor;
  final Color? indicatorColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  const RevoPosTabBar({Key? key, required this.controller, this.isScrollable, required this.itemBuilder, required this.items, this.labelStyle, this.unselectedLabelStyle, this.labelColor, this.indicatorColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      labelColor: labelColor ?? Theme.of(context).primaryColor,
      indicatorColor: indicatorColor ?? Theme.of(context).primaryColor,
      labelStyle: labelStyle ?? Theme.of(context).textTheme.headline6,
      unselectedLabelStyle: unselectedLabelStyle ?? Theme.of(context).textTheme.bodyText1!.copyWith(
        color: colorDisabled,
        fontSize: 16
      ),
      isScrollable: isScrollable ?? false,
      tabs: items.map(itemBuilder).toList(),
    );
  }
}
