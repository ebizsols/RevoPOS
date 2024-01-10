import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../revo_pos_text_field.dart';

class FormStorePage extends StatefulWidget {
  const FormStorePage({Key? key}) : super(key: key);

  @override
  _FormStorePageState createState() => _FormStorePageState();
}

class _FormStorePageState extends State<FormStorePage> {
  TextEditingController storeNameController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController ckController = TextEditingController();
  TextEditingController csController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String urlContact = "https://api.whatsapp.com/send?phone=62811369000&text=Hi%20Revo%20Apps.%20I%20want%20to%20buy%20Revo%20POS%20plugin.";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<LoginNotifier>().getVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final version = context.select((LoginNotifier n) => n.version);

    final isEnabled = context.select((LoginNotifier n) => n.isEnabled);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 1 / 4,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(
                        "assets/images/icon.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: Text(
                      "Welcome !",
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontWeight: FontWeight.normal),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: Text(
                      "Woocommerce Point of Sales",
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildForm(isEnabled: isEnabled),
                  const SizedBox(height: 32),
                  Text("version $version",
                      style: Theme.of(context).textTheme.bodyText1)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm({required bool isEnabled}) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Store name",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          RevoPosTextField(
            controller: storeNameController,
            maxLines: 1,
            hintText: "Store name",
            onChanged: (value) {
              context.read<LoginNotifier>().setEnabled(
                  storeNameController.text.isNotEmpty &&
                      urlController.text.isNotEmpty &&
                      ckController.text.isNotEmpty &&
                      csController.text.isNotEmpty);
            },
            validator: (value) {
              if (value != null && value.isEmpty) {
                return "Store name cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Text(
            "URL",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          RevoPosTextField(
            controller: urlController,
            maxLines: 1,
            hintText: "URL",
            onChanged: (value) {
              context.read<LoginNotifier>().setEnabled(
                  storeNameController.text.isNotEmpty &&
                      urlController.text.isNotEmpty &&
                      ckController.text.isNotEmpty &&
                      csController.text.isNotEmpty);
            },
            validator: (value) {
              bool _valid = Uri.parse(value!).isAbsolute;
              if (_valid) {
                return null;
              } else {
                return 'Enter a valid url';
              }
            },
          ),
          const SizedBox(height: 12),
          Text(
            "Consumer Key (CK)",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          RevoPosTextField(
            controller: ckController,
            maxLines: 1,
            hintText: "Consumer Key (CK)",
            onChanged: (value) {
              context.read<LoginNotifier>().setEnabled(
                  storeNameController.text.isNotEmpty &&
                      urlController.text.isNotEmpty &&
                      ckController.text.isNotEmpty &&
                      csController.text.isNotEmpty);
            },
            validator: (value) {
              bool _valid = value!.contains('ck_');
              if (_valid) {
                return null;
              } else {
                return 'Consumer Key must contain (ck_xxxxxxxx)';
              }
            },
          ),
          const SizedBox(height: 12),
          Text(
            "Consumer Service (CS)",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          RevoPosTextField(
            controller: csController,
            maxLines: 1,
            hintText: "Consumer Service (CS)",
            onChanged: (value) {
              context.read<LoginNotifier>().setEnabled(
                  storeNameController.text.isNotEmpty &&
                      urlController.text.isNotEmpty &&
                      ckController.text.isNotEmpty &&
                      csController.text.isNotEmpty);
            },
            validator: (value) {
              bool _valid = value!.contains('cs_');
              if (_valid) {
                return null;
              } else {
                return 'Consumer Key must contain (cs_xxxxxxxx)';
              }
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "REVO APPS - Woocommerce POS requires the Revo POS plugin that has been installed and activated on your website. "
              "Contact our support for more info.",
              style: TextStyle(
                fontWeight: FontWeight.w900
              ),
            ),
          ),
          const SizedBox(height: 20),
          FractionallySizedBox(
            widthFactor: 1,
            child: Row(
              children: [
                Expanded(
                  child: RevoPosButton(
                    text: "Save Store",
                    color: isEnabled ? Theme.of(context).primaryColor : colorDisabled,
                    onPressed: () {
                      if (isEnabled) {
                        if (formKey.currentState!.validate()) {
                          if (urlController.text.startsWith('http://')) {
                            setState(() {
                              urlController.text = urlController.text
                                  .replaceFirst('http://', 'https://');
                            });
                          }
                          if (urlController.text.endsWith('/')) {
                            setState(() {
                              urlController.text = urlController.text
                                  .substring(0, urlController.text.length - 1);
                            });
                          }
                          context.read<StoreNotifier>().addStore(
                              storeName: storeNameController.text,
                              url: urlController.text,
                              consumerKey: ckController.text,
                              consumerSecret: csController.text,
                              isLogin: false,
                              cookie: '');
                          Navigator.pop(context);
                        }
                      }
                    }
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RevoPosButton(
                    text: "Contact Support",
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      if (!await launch(urlContact)) throw 'Could not launch $urlContact';
                    }
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
