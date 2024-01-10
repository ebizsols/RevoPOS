import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/auth/page/store_page.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/page/main_page.dart';
import 'package:provider/provider.dart';

import '../../revo_pos_dialog.dart';
import 'item_menu_drawer.dart';

class DrawerMain extends StatefulWidget {
  final List<MainMenu> menus;
  final int selected;

  const DrawerMain({Key? key, required this.menus, required this.selected})
      : super(key: key);

  @override
  _DrawerMainState createState() => _DrawerMainState();
}

class _DrawerMainState extends State<DrawerMain> {
  String? _versionName;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: colorWhite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListView(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Expanded(
                        child: Text(
                      "MENU",
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: colorBlack),
                    ))
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  color: const Color(0xFFebebeb),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.asset(
                          "assets/images/placeholder_user.png",
                          fit: BoxFit.fill,
                          width: 60,
                          height: 60,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You are login with",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${context.read<LoginNotifier>().user!.user!.firstname} ${context.read<LoginNotifier>().user!.user!.lastname}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Username : ${context.read<LoginNotifier>().user!.user!.username}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.menus.length,
                    itemBuilder: (_, index) => ItemMenuDrawer(
                          icon: widget.menus[index].icon,
                          text: widget.menus[index].text,
                          type: widget.menus[index].type,
                          color: index == widget.menus.length - 1
                              ? colorDanger
                              : null,
                          isSelected: index == widget.selected,
                          onTap: () {
                            if (index != widget.selected) {
                              if (index < widget.menus.length - 1) {
                                context.read<MainNotifier>().setSelected(index);
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus)
                                  currentFocus.unfocus();
                                Navigator.pop(context);
                              } else {
                                _showLogoutDialog();
                              }
                            }
                          },
                        ))
              ],
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.only(left: 10, bottom: 10),
              child: FutureBuilder(
                future: _init(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _versionName = snapshot.data as String?;
                    return Text(
                      'Version ' + _versionName!,
                      style: TextStyle(fontSize: 14),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _init() async {
    final _packageInfo = await PackageInfo.fromPlatform();

    context.read<MainNotifier>().setPackageInfo(_packageInfo);

    return _packageInfo.version;
  }

  _showLogoutDialog() {
    showDialog(
        context: context,
        builder: (_) => RevoPosDialog(
              titleIcon: FontAwesomeIcons.signOutAlt,
              primaryColor: colorDanger,
              title: "Logout",
              content: "Do you want to logout?",
              actions: [
                RevoPosDialogAction(
                    text: "No", onPressed: () => Navigator.pop(context)),
                RevoPosDialogAction(
                    text: "Yes",
                    onPressed: () {
                      context.read<StoreNotifier>().logout().then((value) {
                        context.read<MainNotifier>().resetMenu();
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            RevoPosRouteBuilder.routeBuilder(
                                const LoginPage()));
                      });
                    })
              ],
            ));
  }
}
