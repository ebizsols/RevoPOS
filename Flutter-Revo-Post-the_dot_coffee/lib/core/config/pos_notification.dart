import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:revo_pos/core/config/global_variable.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists_detail.dart';
import 'package:revo_pos/layers/presentation/chat/page/chat_detail_page.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/page/main_page.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/orders_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/page/detail_order_page.dart';
import 'package:revo_pos/layers/presentation/orders/page/orders_page.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();

String? selectedNotificationPayload;

class POSNotification {
  static late SharedPreferences data;
  static late FirebaseMessaging messaging;

  static Future init() async {
    data = await SharedPreferences.getInstance();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      printLog(value!, name: 'Device Token');
      data.setString('device_token', value);
    });

    // AwesomeNotifications().isNotificationAllowed().then((value) {
    //   if (!value) {
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });

    // final NotificationChannel awesomeChannelNewOrder = NotificationChannel(
    //   channelKey: 'high_importance_channel_new_order',
    //   channelName: 'High Importance Notifications New Order',
    //   channelDescription:
    //       'This channel is used for important notifications new order.',
    //   channelShowBadge: true,
    //   defaultColor: Colors.white,
    //   enableLights: true,
    //   enableVibration: true,
    //   importance: NotificationImportance.Max,
    //   playSound: true,
    //   soundSource: 'resource://raw/res_notif',
    // );

    // final NotificationChannel awesomeChannel = NotificationChannel(
    //   channelKey: 'high_importance_channel',
    //   channelName: 'High Importance Notifications',
    //   channelDescription: 'This channel is used for important notifications.',
    //   channelShowBadge: true,
    //   defaultColor: Colors.white,
    //   enableLights: true,
    //   enableVibration: true,
    //   importance: NotificationImportance.Max,
    //   playSound: true,
    // );

    // AwesomeNotifications().initialize(
    //   'resource://drawable/res_transparent',
    //   [
    //     awesomeChannel,
    //     awesomeChannelNewOrder,
    //   ],
    // );

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.defaultImportance,
      description: 'This channel is used for important notifications.',
    );

    final AndroidNotificationChannel channelNewOrder =
        AndroidNotificationChannel(
      'high_importance_channel_new',
      'High Importance Notifications New Order',
      importance: Importance.high,
      description: 'This channel is used for important notifications.',
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification: (
              int id,
              String? title,
              String? body,
              String? payload,
            ) async {
              didReceiveLocalNotificationSubject.add(
                ReceivedNotification(
                  id: id,
                  title: title,
                  body: body,
                  payload: payload,
                ),
              );
            });

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectedNotificationPayload = payload;
      selectNotificationSubject.add(payload);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      print("message recieved");
      debugPrint("Notif Body ${event.notification!.body}");
      debugPrint("Notif Data ${event.data}");

      RemoteNotification? notification = event.notification;
      AppleNotification? apple = event.notification?.apple;
      AndroidNotification? android = event.notification?.android;

      Map<String, String> convertedData =
          event.data.map((key, value) => MapEntry(key, value.toString()));

      var _imageUrl = '';

      if (Platform.isAndroid && android != null) {
        if (android.imageUrl != null) {
          _imageUrl = android.imageUrl!;
        }
      } else if (Platform.isIOS && apple != null) {
        if (apple.imageUrl != null) {
          _imageUrl = apple.imageUrl!;
        }
      }

      printLog(event.data['is_neworder'].toString(), name: "IS NEW ORDER");

      if (event.data['is_neworder'].toString() == 'true') {
        printLog("new order");
        if (notification != null) {
          if (_imageUrl.isNotEmpty) {
            String? _bigPicturePath = '';
            DateTime _dateNow = DateTime.now();
            if (Platform.isIOS) {
              _bigPicturePath = await _downloadAndSaveFile(
                  _imageUrl, 'notificationimg$_dateNow.jpg');
            }
            final IOSNotificationDetails iOSPlatformChannelSpecifics =
                IOSNotificationDetails(attachments: <IOSNotificationAttachment>[
              IOSNotificationAttachment(_bigPicturePath)
            ]);
            await showBigPictureNotificationURL(_imageUrl).then((value) {
              // AwesomeNotifications().createNotification(
              //     content: NotificationContent(
              //         id: notification.hashCode,
              //         channelKey: awesomeChannelNewOrder.channelKey!,
              //         title: notification.title,
              //         body: notification.body,
              //         bigPicture: _imageUrl,
              //         notificationLayout: NotificationLayout.BigPicture,
              //         customSound: 'resource://raw/res_notif',
              //         payload: convertedData));

              flutterLocalNotificationsPlugin.show(
                  notification.hashCode,
                  notification.title,
                  notification.body,
                  NotificationDetails(
                      android: AndroidNotificationDetails(
                        channelNewOrder.id,
                        channelNewOrder.name,
                        icon: 'res_transparent',
                        channelDescription: channelNewOrder.description,
                        sound: RawResourceAndroidNotificationSound("res_notif"),
                        styleInformation: value,
                        fullScreenIntent: true,
                      ),
                      iOS: iOSPlatformChannelSpecifics),
                  payload: json.encode(event.data));
            });
          } else {
            // AwesomeNotifications().createNotification(
            //     content: NotificationContent(
            //   id: notification.hashCode,
            //   channelKey: awesomeChannelNewOrder.channelKey!,
            //   title: notification.title,
            //   body: notification.body,
            //   customSound: 'resource://raw/res_notif',
            //   payload: convertedData,
            // ));
            flutterLocalNotificationsPlugin.show(
                notification.hashCode,
                notification.title,
                notification.body,
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    channelNewOrder.id,
                    channelNewOrder.name,
                    icon: 'res_transparent',
                    channelDescription: channelNewOrder.description,
                    sound: RawResourceAndroidNotificationSound("res_notif"),
                  ),
                ),
                payload: json.encode(event.data));
          }
        }
      }

      if (event.data['is_neworder'].toString() != 'true') {
        printLog("not new order");
        if (notification != null) {
          if (_imageUrl.isNotEmpty) {
            String? _bigPicturePath = '';
            DateTime _dateNow = DateTime.now();
            if (Platform.isIOS) {
              _bigPicturePath = await _downloadAndSaveFile(
                  _imageUrl, 'notificationimg$_dateNow.jpg');
            }
            final IOSNotificationDetails iOSPlatformChannelSpecifics =
                IOSNotificationDetails(attachments: <IOSNotificationAttachment>[
              IOSNotificationAttachment(_bigPicturePath)
            ]);
            await showBigPictureNotificationURL(_imageUrl).then((value) {
              // AwesomeNotifications().createNotification(
              //     content: NotificationContent(
              //         id: notification.hashCode,
              //         channelKey: awesomeChannel.channelKey!,
              //         title: notification.title,
              //         body: notification.body,
              //         bigPicture: _imageUrl,
              //         notificationLayout: NotificationLayout.BigPicture,
              //         payload: convertedData));

              flutterLocalNotificationsPlugin.show(
                  notification.hashCode,
                  notification.title,
                  notification.body,
                  NotificationDetails(
                      android: AndroidNotificationDetails(
                        channel.id,
                        channel.name,
                        icon: 'res_transparent',
                        channelDescription: channel.description,
                        styleInformation: value,
                        fullScreenIntent: true,
                      ),
                      iOS: iOSPlatformChannelSpecifics),
                  payload: json.encode(event.data));
            });
          } else {
            // AwesomeNotifications().createNotification(
            //     content: NotificationContent(
            //   id: notification.hashCode,
            //   channelKey: awesomeChannel.channelKey!,
            //   title: notification.title,
            //   body: notification.body,
            //   payload: convertedData,
            // ));
            flutterLocalNotificationsPlugin.show(
                notification.hashCode,
                notification.title,
                notification.body,
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    icon: 'res_transparent',
                    channelDescription: channel.description,
                  ),
                ),
                payload: json.encode(event.data));
          }
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print('Init onMessageOpenedApp!');
      debugPrint('onMessageOpenedApp Click ' + message.data.toString());
    });
  }

  static Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  static Future<BigPictureStyleInformation> showBigPictureNotificationURL(
      String url) async {
    final ByteArrayAndroidBitmap largeIcon =
        ByteArrayAndroidBitmap(await _getByteArrayFromUrl(url));
    final ByteArrayAndroidBitmap bigPicture =
        ByteArrayAndroidBitmap(await _getByteArrayFromUrl(url));

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(bigPicture, largeIcon: largeIcon);

    return bigPictureStyleInformation;
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static configureSelectNotificationSubject(context) {
    selectNotificationSubject.stream.listen((String? payload) async {
      debugPrint("Payload : $payload");
      var _payload = json.decode(payload!);
      if (_payload['type'] == 'order') {
        print("main");

        await Navigator.of(GlobalVariable.navState.currentContext!)
            .push(MaterialPageRoute(
                builder: (context) => const MainPage(
                      index: 3,
                    )));
      } else if (_payload['type'] == 'chat') {
        await Navigator.of(GlobalVariable.navState.currentContext!)
            .push(MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                      receiverID: int.parse(_payload['id']),
                      username: "",
                      chatID: 0,
                    )));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print('Reload onMessageOpenedApp!');
      debugPrint('Message Open Click ' + message.data.toString());

      if (message.data['type'] == 'order') {
        Navigator.of(GlobalVariable.navState.currentContext!)
            .push(MaterialPageRoute(
                builder: (context) => const MainPage(
                      index: 3,
                    )));
      } else if (message.data['type'] == 'chat') {
        Navigator.of(GlobalVariable.navState.currentContext!)
            .push(MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                      receiverID: int.parse(message.data['id']),
                      username: "",
                      chatID: 0,
                    )));
      }
    });
  }

  static configureDidReceiveLocalNotificationSubject(context) {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
