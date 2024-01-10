import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revo_pos/core/config/pos_notification.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/chat/page/chat_detail_page.dart';
import 'package:revo_pos/layers/presentation/main/page/main_page.dart';
import 'package:revo_pos/layers/presentation/orders/page/detail_order_page.dart';
import 'package:uni_links/uni_links.dart';

class DeeplinkConfig {
  Future Function()? onLinkClicked;
  Future<Widget> initUniLinks(BuildContext context) async {
    Widget screen = LoginPage();
    try {
      String? initialLink = await getInitialLink();
      print(initialLink);
      if (initialLink != null) {
        Uri uri = Uri.parse(initialLink);
        print(uri);
        printLog('Deeplink Exists!', name: 'Deeplink');
        pathUrl(uri, context, true);
        screen = LoginPage(
          onLinkClicked: onLinkClicked,
        );
      }
      if (selectedNotificationPayload != null) {
        var _payload = json.decode(selectedNotificationPayload!);
        if (_payload['type'] == 'order') {
          onLinkClicked = () async => await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => DetailOrderPage()));
        } else if (_payload['type'] == 'chat') {
          onLinkClicked =
              () async => await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatDetailPage(
                        receiverID: int.parse(_payload['id']),
                        username: "",
                        chatID: 0,
                      )));
        } else {
          print("Else");
          Uri uri = Uri.parse(_payload['click_action']);
          pathUrl(uri, context, true);
        }
        screen = LoginPage(
          onLinkClicked: onLinkClicked,
        );
      }
    } on PlatformException {
      print("Error");
    }
    return screen;
  }

  pathUrl(Uri uri, BuildContext context, bool fromLaunchApp) async {
    /*Shop (Detail Product)*/
    // if (uri.pathSegments[0] == "shop" || uri.pathSegments[0] == "product") {
    //   if (uri.pathSegments[1].isNotEmpty) {
    //     print("Detail Product");
    //     if (fromLaunchApp) {
    //       onLinkClicked = () async => await Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (_) => DetailProductScreen(
    //                     slug: uri.pathSegments[1],
    //                   )));
    //     } else {
    //       await Navigator.of(GlobalVariable.navState.currentContext!)
    //           .push(MaterialPageRoute(
    //               builder: (context) => DetailProductScreen(
    //                     slug: uri.pathSegments[1],
    //                   )));
    //     }
    //   }
    // }
    // /*Forgot Password*/
    // if (uri.pathSegments[0] == "my-account" &&
    //     uri.pathSegments[1] == "lost-password") {
    //   if (uri.queryParametersAll.isNotEmpty) {
    //     if (fromLaunchApp) {
    //       onLinkClicked = () async => await Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (_) => ForgotPasswordScreen(
    //                     cek: true,
    //                     id: uri.queryParameters["id"].toString(),
    //                     keys: uri.queryParameters["key"].toString(),
    //                   )));
    //       // onLinkClicked = () async {
    //       //   await AuthAPI()
    //       //       .checkPassKey(uri.queryParameters["key"].toString(),
    //       //           uri.queryParameters["id"].toString())
    //       //       .then((data) async {
    //       //     printLog("id : ${data["ID"]} + ${uri.queryParameters["id"]}");
    //       //     if (data["ID"] == uri.queryParameters["id"]) {
    //       //       await Navigator.push(context,
    //       //           MaterialPageRoute(builder: (_) => ResetPasswordScreen()));
    //       //     } else {
    //       //       await Navigator.push(
    //       //           context,
    //       //           MaterialPageRoute(
    //       //               builder: (_) => ForgotPasswordScreen(
    //       //                     cek: true,
    //       //                   )));
    //       //     }
    //       //   });
    //       // };
    //     }
    //   }
    // }

    // /*Blog (Detail Blog)*/
    // if (uri.pathSegments[0] == "artikel" ||
    //     uri.pathSegments[0] == "articles" ||
    //     uri.pathSegments[0] == "blog" ||
    //     uri.pathSegments[0] == "blogs" ||
    //     uri.pathSegments[0] == "post") {
    //   if (uri.pathSegments[1].isNotEmpty) {
    //     print("Detail Blog");
    //     debugPrint(uri.toString());
    //     debugPrint(uri.pathSegments[0]);
    //     debugPrint(uri.pathSegments[1]);
    //     if (fromLaunchApp) {
    //       onLinkClicked = () async => await Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (_) => DetailBlog(
    //                     slug: uri.pathSegments[1],
    //                   )));
    //     } else {
    //       await Navigator.of(GlobalVariable.navState.currentContext!)
    //           .push(MaterialPageRoute(
    //               builder: (context) => DetailBlog(
    //                     slug: uri.pathSegments[1],
    //                   )));
    //     }
    //   }
    // }
  }
}
