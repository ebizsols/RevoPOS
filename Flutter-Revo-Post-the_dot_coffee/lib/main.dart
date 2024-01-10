import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/config/global_variable.dart';
import 'package:revo_pos/core/config/pos_notification.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/deeplink/deeplink_config.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:revo_pos/core/di/injection_container.dart' as di;
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/auth/page/store_page.dart';
import 'package:revo_pos/layers/presentation/chat/notifier/chat_notifier.dart';
import 'package:revo_pos/layers/presentation/customers/notifier/customers_notifier.dart';
import 'package:revo_pos/layers/presentation/main/page/main_page.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/orders_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/categories_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/payment_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:revo_pos/layers/presentation/products/notifier/attribute_notifier.dart';
import 'package:revo_pos/layers/presentation/products/notifier/form_product_notifier.dart';
import 'package:revo_pos/layers/presentation/products/notifier/products_notifier.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/settings/notifier/settings_notifier.dart';
import 'package:uni_links/uni_links.dart';

import 'core/utils/media_query.dart';
import 'layers/presentation/orders/notifier/detail_order_notifier.dart';
import 'layers/presentation/pos/notifier/draft_notifier.dart';
import 'layers/presentation/main/notifier/main_notifier.dart';
import 'package:http/http.dart' as http;

Future<void> _messageHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  await Firebase.initializeApp();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String initialRoute = "Initial Route";
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    initialRoute = "Initial Route : $selectedNotificationPayload";
    print(initialRoute);
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<BigPictureStyleInformation> showBigPictureNotificationURL(
      String url) async {
    final ByteArrayAndroidBitmap largeIcon =
        ByteArrayAndroidBitmap(await _getByteArrayFromUrl(url));
    final ByteArrayAndroidBitmap bigPicture =
        ByteArrayAndroidBitmap(await _getByteArrayFromUrl(url));

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(bigPicture, largeIcon: largeIcon);

    return bigPictureStyleInformation;
  }

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

  final AndroidNotificationChannel channelNewOrder = AndroidNotificationChannel(
    'high_importance_channel_new',
    'High Importance Notifications New Order',
    importance: Importance.high,
    description: 'This channel is used for important notifications.',
  );

  print("message recieved");
  debugPrint("Notif Body ${message.notification!.body}");
  debugPrint("Notif Data ${message.data}");

  RemoteNotification? notification = message.notification;
  AppleNotification? apple = message.notification?.apple;
  AndroidNotification? android = message.notification?.android;

  Map<String, String> convertedData =
      message.data.map((key, value) => MapEntry(key, value.toString()));

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
  if (message.data['is_neworder'].toString() == 'true') {
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
              payload: json.encode(message.data));
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
            payload: json.encode(message.data));
      }
    }
  }
  if (message.data['is_neworder'].toString() != 'true') {
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
              payload: json.encode(message.data));
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
            payload: json.encode(message.data));
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await AppConfig.init();
  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  await Firebase.initializeApp();
  await POSNotification.init();
  await Future.delayed(const Duration(milliseconds: 1500));

  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  void initState() {
    super.initState();
    POSNotification.requestPermissions();
    POSNotification.configureDidReceiveLocalNotificationSubject(context);
    POSNotification.configureSelectNotificationSubject(context);
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('Uri: $uri');
        DeeplinkConfig().pathUrl(uri!, context, false);
      }, onError: (Object err) {
        if (!mounted) return;
        print('Error: $err');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    _sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider<LoginNotifier>(
          create: (_) => di.sl<LoginNotifier>(),
        ),

        // Home
        ChangeNotifierProvider<MainNotifier>(
          create: (_) => di.sl<MainNotifier>(),
        ),
        ChangeNotifierProvider<PosNotifier>(
          create: (_) => di.sl<PosNotifier>(),
        ),

        // Pos
        ChangeNotifierProvider<DraftNotifier>(
          create: (_) => di.sl<DraftNotifier>(),
        ),
        ChangeNotifierProvider<PaymentNotifier>(
          create: (_) => di.sl<PaymentNotifier>(),
        ),
        ChangeNotifierProvider<CategoriesNotifier>(
          create: (_) => di.sl<CategoriesNotifier>(),
        ),

        // Products
        ChangeNotifierProvider<ProductsNotifier>(
          create: (_) => di.sl<ProductsNotifier>(),
        ),
        ChangeNotifierProvider<FormProductNotifier>(
          create: (_) => di.sl<FormProductNotifier>(),
        ),
        ChangeNotifierProvider<AttributeNotifier>(
          create: (_) => di.sl<AttributeNotifier>(),
        ),

        // Reports
        ChangeNotifierProvider<ReportsNotifier>(
          create: (_) => di.sl<ReportsNotifier>(),
        ),

        // Orders
        ChangeNotifierProvider<DetailOrderNotifier>(
          create: (_) => di.sl<DetailOrderNotifier>(),
        ),
        ChangeNotifierProvider<OrdersNotifier>(
          create: (_) => di.sl<OrdersNotifier>(),
        ),

        // Store
        ChangeNotifierProvider<StoreNotifier>(
          create: (_) => di.sl<StoreNotifier>(),
        ),

        // Customer
        ChangeNotifierProvider<CustomersNotifier>(
          create: (_) => di.sl<CustomersNotifier>(),
        ),

        // Settings
        ChangeNotifierProvider<SettingsNotifier>(
          create: (_) => di.sl<SettingsNotifier>(),
        ),

        // Chat
        ChangeNotifierProvider<ChatNotifier>(
          create: (_) => di.sl<ChatNotifier>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: GlobalVariable.navState,
        title: 'The Dot Coffee POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: colorPrimary,
          colorScheme: ColorScheme.fromSwatch(accentColor: colorAccent),
          scaffoldBackgroundColor: colorWhite,
          fontFamily: 'Nunito',
          textTheme: TextTheme(
            headline1: TextStyle(
                fontSize: 20.0, fontWeight: FontWeight.bold, color: colorBlack),
            headline6: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: colorPrimary),
            bodyText2: TextStyle(fontSize: 12.0, color: colorBlack),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: colorWhite,
            elevation: 0,
            iconTheme: IconThemeData(color: colorBlack),
            actionsIconTheme: IconThemeData(color: colorPrimary),
            titleTextStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: colorBlack,
                fontFamily: 'Nunito'),
          ),
        ),
        home: Builder(builder: (context) {
          return FutureBuilder(
            future: DeeplinkConfig().initUniLinks(context),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              return snapshot.data as Widget;
            },
          );
        }),
      ),
    );
    // return FutureBuilder(
    //   future: Init.instance.initialize(),
    //   builder: (context, AsyncSnapshot snapshot) {
    //     // Show splash screen while waiting for app resources to load:
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const MaterialApp(home: Splash());
    //     } else {
    //       // Loading is done, return the app:

    //     }
    //   },
    // );
  }
}

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: RevoPosMediaQuery.getWidth(context),
        height: RevoPosMediaQuery.getHeight(context),
        child: Image.asset(
          'assets/images/splashscreen.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class Init {
  Init._();
  static final instance = Init._();

  Future initialize() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    await Future.delayed(const Duration(seconds: 3));
  }
}
