import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final int? index;
  const MainPage({Key? key, this.index}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      context.read<MainNotifier>().setSelected(widget.index!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = context.select((MainNotifier n) => n.selected);
    final menus = context.select((MainNotifier n) => n.menus);

    return DoubleBack(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
          },
          child: menus[selected].page,
        ),
      ),
      message: "Press back again to close",
    );
  }
}

class MainMenu {
  final dynamic icon;
  final String text;
  final Widget page;
  final String type;

  MainMenu(
      {required this.icon,
      required this.text,
      required this.page,
      required this.type});
}
