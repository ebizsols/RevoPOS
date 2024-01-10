import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/detail_order_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:revo_pos/layers/presentation/main/page/main_page.dart';
import 'package:revo_pos/layers/presentation/revo_pos_image.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../revo_pos_dialog.dart';
import '../../revo_pos_text_field.dart';

class LoginPage extends StatefulWidget {
  final Future Function()? onLinkClicked;
  const LoginPage({Key? key, this.onLinkClicked}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;
  DetailOrderNotifier? detailOrderNotifier;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    detailOrderNotifier =
        Provider.of<DetailOrderNotifier>(context, listen: false);
    if (widget.onLinkClicked != null) {
      widget.onLinkClicked!();
    }
    if (AppConfig.data!.containsKey("isLogin") &&
        AppConfig.data!.containsKey("isRememberMe")) {
      if (AppConfig.data!.getBool("isLogin")! &&
          AppConfig.data!.getBool("isRememberMe")!) {
        isLoading = true;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<LoginNotifier>().getVersion();
      context.read<DetailOrderNotifier>().getUserSettings().then((value) {
        if (!detailOrderNotifier!.userSetting!.liveChat!) {
          context.read<MainNotifier>().removePageChat();
        }
      });
      if (AppConfig.data!.containsKey("isLogin") &&
          AppConfig.data!.containsKey("isRememberMe")) {
        if (AppConfig.data!.getBool("isLogin")! &&
            AppConfig.data!.getBool("isRememberMe")!) {
          context.read<LoginNotifier>().setUserData();

          context.read<LoginNotifier>().getSettings(onSubmit: (loading) {
            if (!loading) {
              Navigator.pushReplacement(
                  context, RevoPosRouteBuilder.routeBuilder(const MainPage()));
              isLoading = false;
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final version = context.select((LoginNotifier n) => n.version);

    final isHidePassword =
        context.select((LoginNotifier n) => n.isHidePassword);
    final isRememberMe = context.select((LoginNotifier n) => n.isRememberMe);
    final isEnabled = context.select((LoginNotifier n) => n.isEnabled);
    final loading = context.select((DetailOrderNotifier n) => n.loadingSetting);

    return loading
        ? const RevoPosLoading()
        : Scaffold(
            body: SafeArea(
              child: isLoading
                  ? const RevoPosLoading()
                  : SingleChildScrollView(
                      child: GestureDetector(
                        onTap: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus)
                            currentFocus.unfocus();
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
                                  child: RevoPosImage(
                                      url: detailOrderNotifier!
                                          .userSetting!.logo!.image),
                                  // Image.asset(
                                  //   "assets/images/icon.png",
                                  //   fit: BoxFit.cover,
                                  // ),
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
                              _buildForm(
                                  isHidePassword: isHidePassword,
                                  isRememberMe: isRememberMe,
                                  isEnabled: isEnabled),
                              const SizedBox(height: 32),
                              Text("version $version",
                                  style: Theme.of(context).textTheme.bodyText1),
                              const SizedBox(height: 32),
                              Visibility(
                                  visible: url.contains("revoapps.id"),
                                  child: demoPurpose()),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          );
  }

  Widget _buildForm(
      {required bool isHidePassword,
      bool? isRememberMe,
      required bool isEnabled}) {
    var selectedStore = context.select((StoreNotifier n) => n.selectedStore);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Username",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          RevoPosTextField(
            controller: usernameController,
            maxLines: 1,
            hintText: "Username",
            onChanged: (value) {
              context.read<LoginNotifier>().setEnabled(
                  usernameController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty);
            },
            validator: (value) {
              if (value != null && value.isEmpty) {
                return "Username cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Text(
            "Password",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          RevoPosTextField(
            controller: passwordController,
            maxLines: 1,
            hintText: "Password",
            onChanged: (value) {
              context.read<LoginNotifier>().setEnabled(
                  usernameController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty);
            },
            obscureText: isHidePassword,
            suffixIcon: GestureDetector(
              onTap: () {
                context.read<LoginNotifier>().setShowPassword(!isHidePassword);
              },
              child: Icon(
                isHidePassword ? Icons.visibility : Icons.visibility_off,
                color: isHidePassword
                    ? Colors.grey
                    : Theme.of(context).primaryColor,
              ),
            ),
            validator: (value) {
              if (value != null && value.isEmpty) {
                return "Password cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                  value: isRememberMe,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<LoginNotifier>().setRememberMe(value);
                    }
                  }),
              Text(
                "Remember me",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
          const SizedBox(height: 20),
          FractionallySizedBox(
            widthFactor: 1,
            child: RevoPosButton(
                text: "Login",
                color:
                    isEnabled ? Theme.of(context).primaryColor : colorDisabled,
                onPressed: () {
                  if (isEnabled && formKey.currentState!.validate()) {
                    setState(() {});
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return const RevoPosLoading();
                        });
                    context.read<LoginNotifier>().login(context,
                        username: usernameController.text,
                        password: passwordController.text,
                        onSubmit: (user, isLoading, result) {
                      if (!isLoading) {
                        Navigator.pop(context);
                        if (result['code'] == 'incorrect_password' ||
                            result['code'] == 'invalid_username') {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Username or password not match")));
                        } else if (result['status'] == 'error' ||
                            result['code'] == 'rest_no_route') {
                          _showAlert();
                        }
                      } else {
                        if (user.cookie != '') {
                          if (user.user!.role!.first == 'administrator' ||
                              user.user!.role!.first == 'shop_manager') {
                            printLog('Login Success');
                            AppConfig.data?.setBool('isLogin', true);
                            context.read<LoginNotifier>().getSettings(
                                onSubmit: (loading) {
                              if (!loading) {
                                Navigator.pop(context);
                                //printLog(selectedStore!.consumerSecret
                                //.toString());
                                // context
                                //     .read<StoreNotifier>()
                                //     .updateStoreData(user);
                                Navigator.pushReplacement(
                                    context,
                                    RevoPosRouteBuilder.routeBuilder(
                                        const MainPage()));
                              }
                            });
                          } else {
                            AppConfig.data!.remove('cookie');
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "User role is not an Administrator or Shop Manager")));
                          }
                        } else {
                          AppConfig.data!.remove('cookie');
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Login invalid")));
                        }
                      }
                    });
                  }
                }),
          ),
        ],
      ),
    );
  }

  demoPurpose() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(), color: Colors.grey),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "For Demo Purpose,",
          style: TextStyle(fontSize: 16),
        ),
        Text(
          "Use The Following Account:",
          style: TextStyle(fontSize: 16),
        ),
        Text(
          "Username : demotest",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          "Password : demotest",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ]),
    );
  }

  _showAlert() {
    showDialog(
        context: context,
        builder: (_) => RevoPosDialog(
              titleIcon: FontAwesomeIcons.circleExclamation,
              primaryColor: Colors.amber,
              title: "RevoPOS",
              content:
                  "Hello, make sure that the RevoPOS plugin is installed and activated on your woocommerce website. Or you can buy it here:",
              actions: [
                RevoPosDialogAction(
                    text: "Buy Plugin",
                    onPressed: () async {
                      String _url = 'https://bit.ly/buy-revopos-plugin-now';
                      if (!await launch(_url)) throw 'Could not launch $_url';
                    }),
              ],
            ));
  }
}
