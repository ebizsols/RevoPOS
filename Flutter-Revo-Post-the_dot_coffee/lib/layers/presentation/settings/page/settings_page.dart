import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/widget/drawer_main.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:revo_pos/layers/presentation/settings/notifier/settings_notifier.dart';

import '../../revo_pos_button.dart';
import '../../revo_pos_text_field.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController ipController = TextEditingController();
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _pressed = false;

  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            _pressed = false;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkValidateCookie();
      context.read<SettingsNotifier>().loadIp();
    });
    initPlatformState();
  }

  newLogoutPopDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                height: 150,
                width: 330,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Your Session is expired, Please Login again",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Container(
                        child: Column(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 2,
                        ),
                        GestureDetector(
                          onTap: () => logout(),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15)),
                                color: Theme.of(context).primaryColor),
                            child: Text(
                              "Ok",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ))
                  ],
                ),
              );
            },
          )),
    );
  }

  logout() async {
    context.read<StoreNotifier>().logout().then((value) {
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, RevoPosRouteBuilder.routeBuilder(const LoginPage()));
    });
  }

  checkValidateCookie() {
    context.read<PosNotifier>().checkValidateCookie().then((value) {
      if (value.toString().contains("error")) {
        newLogoutPopDialog();
      }
    });
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('None'),
      ));
    } else {
      items.add(DropdownMenuItem(
        child: Text("Paired Device"),
      ));
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name!),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!_connected) {
          bluetooth.connect(_device!).catchError((error) {
            setState(() => _pressed = false);
          });
          setState(() => _pressed = true);
        }
        context.read<SettingsNotifier>().updateBluetooth(_device);
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _pressed = true);
    context.read<SettingsNotifier>().updateBluetooth(null);
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }

  void _tesPrint() async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT
    bluetooth.isConnected.then((isConnected) {
      if (_connected) {
        bluetooth.printNewLine();
        bluetooth.printCustom("Thank You", 2, 1);
        bluetooth.printNewLine();
        bluetooth.printQRcode("Insert Your Own Text to Generate", 200, 200, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

  void testPrint(String printerIp, BuildContext ctx) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: 9100);

    if (res == PosPrintResult.success) {
      // DEMO RECEIPT
      await printDemoReceipt(printer);
      // TEST PRINT
      // await testReceipt(printer);
      printer.disconnect();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res.msg),
        backgroundColor: Colors.black,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res.msg),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  Future<void> printDemoReceipt(NetworkPrinter printer) async {
    printer.text("Test Print Success !",
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    printer.feed(2);
    printer.cut();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMenu = context.select((MainNotifier n) => n.selected);
    final menus = context.select((MainNotifier n) => n.menus);
    final ip = context.select((SettingsNotifier n) => n.ipAddress);
    final bluetooth = context.select((SettingsNotifier n) => n.connected);

    if (ip != null) {
      ipController.text = ip;
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "IP ADDRESS",
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: colorPrimary),
            ),
            SizedBox(
              height: 50,
              child: RevoPosTextField(
                controller: ipController,
                enabled: ip != null && ip.isNotEmpty ? false : true,
                hintText: "e.g. 192.168.1.100",
                maxLines: 1,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {},
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: RevoPosMediaQuery.getWidth(context),
              child: RevoPosButton(
                  text: ip != null && ip.isNotEmpty ? "DISCONNECT" : "CONNECT",
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    if (ip != null && ip.isNotEmpty) {
                      setState(() {
                        ipController.clear();
                      });
                    }
                    context
                        .read<SettingsNotifier>()
                        .updateIp(ipController.text);
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            Visibility(
                visible: ip != null && ip.isNotEmpty,
                child: SizedBox(
                  width: RevoPosMediaQuery.getWidth(context),
                  child: RevoPosButton(
                      text: "Print Test",
                      color: colorDisabled,
                      onPressed: () {
                        printLog(ip!);
                        testPrint(ip, context);
                      }),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Device:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      borderRadius: BorderRadius.circular(10),
                      isExpanded: true,
                      items: _getDeviceItems(),
                      onChanged: (value) =>
                          setState(() => _device = value as BluetoothDevice?),
                      value: _device,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _pressed
                      ? null
                      : _connected
                          ? _disconnect
                          : _connect,
                  child: Text(
                    _connected ? 'Disconnect' : 'Connect',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: RevoPosMediaQuery.getWidth(context),
              child: RevoPosButton(
                  text: "Test Print Bluetooth",
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    _tesPrint();
                  }),
            ),
          ],
        ),
      ),
      drawer: DrawerMain(menus: menus, selected: selectedMenu),
    );
  }

  _buildAppBar() => AppBar(
        backgroundColor: colorWhite,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 4),
                Text(
                  "MENU",
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColor,
                      ),
                )
              ],
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "PRINTER SETTING",
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: colorBlack),
        ),
      );
}
