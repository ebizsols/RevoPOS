import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/widget/item_product_scan.dart';

import '../../revo_pos_dialog.dart';
import '../../revo_pos_loading.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  TextEditingController searchController = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool flashOn = false;

  bool productAvailable = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productScan = context.select((PosNotifier n) => n.productScan);

    return Scaffold(
      body: Stack(
        children: [
          buildQrScan(),
          // Visibility(visible: searchProvider.loadingQr, child: customLoading()),
          Positioned(
            top: 35,
            left: 15,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5)),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 35,
            right: 15,
            child: InkWell(
              onTap: () async {
                await controller?.toggleFlash();
                setState(() {
                  flashOn = !flashOn;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5)),
                child: flashOn
                    ? const Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.flash_off_rounded,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
          Visibility(
            visible: productAvailable && productScan != null,
            child: productScan == null
                ? Container()
                : Positioned(
                    bottom: 35,
                    right: 10,
                    left: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: RevoPosMediaQuery.getHeight(context) * 0.15,
                      width: RevoPosMediaQuery.getWidth(context),
                      child: !productAvailable && productScan.isEmpty
                          ? const Text('Product not found')
                          : ItemProductScan(
                              product: productScan.first,
                              onTap: onTap,
                            ),
                    )),
          )
        ],
      ),
    );
  }

  Widget buildQrScan() {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.white,
          borderRadius: 25,
          borderLength: 45,
          borderWidth: 25,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      reassemble();
    });
    controller.scannedDataStream.listen((scanData) async {
      await controller.pauseCamera();
      setState(() {
        result = scanData;
      });
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const RevoPosLoading();
          });
      context.read<PosNotifier>().scanBarcode(
          sku: result!.code,
          onSubmit: (status, loading, available) async {
            if (!loading) {
              Navigator.pop(context);
            }
            setState(() {
              productAvailable = available;
            });
            await controller.resumeCamera();
            if (!available) {
              _showAlert();
            }
          });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  onTap() {
    setState(() {
      controller!.resumeCamera();
    });
  }

  _showAlert() {
    showDialog(
        context: context,
        builder: (_) => RevoPosDialog(
              titleIcon: FontAwesomeIcons.info,
              primaryColor: Colors.amber,
              title: "Scan Product",
              content:
                  "Product not found, make sure your barcode match with SKU product",
              actions: [
                RevoPosDialogAction(
                    text: "Close",
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop()),
              ],
            ));
  }
}
