import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/data/models/store_model.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/page/form_store_page.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/main/page/main_page.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:revo_pos/services/base_api.dart';

import '../../revo_pos_loading.dart';
import '../../settings/notifier/settings_notifier.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<SettingsNotifier>().loadIp();
      context.read<LoginNotifier>().getVersion();
      context.read<StoreNotifier>().getStores();
      context.read<StoreNotifier>().checkIsLogin().then((value) {
        if (value) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return const RevoPosLoading();
              });
          context.read<LoginNotifier>().setUserData();
          context.read<LoginNotifier>().getSettings(onSubmit: (loading) {
            if (!loading) {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context, RevoPosRouteBuilder.routeBuilder(const MainPage()));
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final version = context.select((LoginNotifier n) => n.version);
    final stores = context.select((StoreNotifier n) => n.stores);

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
          },
          child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, top: 12),
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
                        _buildSelect(stores: stores),
                        _buildAddStore(),
                        const SizedBox(height: 12),
                        /*Text(
                    "Logout all account",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontWeight: FontWeight.w900),
                  ),*/
                        const SizedBox(height: 32),
                        Text("version $version",
                            style: Theme.of(context).textTheme.bodyText1)
                      ],
                    ),
                  )),
                  InkWell(
                    onTap: () {
                      setState(() {
                        baseAPI = BaseWooAPI(
                            'https://demoadmin.revoapps.id',
                            'ck_7b687d0719b5099cd0ccd01357141ef34d4689fc',
                            'cs_671ffa12413b7facbac59f00bfca31aff40553a6');
                      });
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return const RevoPosLoading();
                          });
                      context.read<LoginNotifier>().login(context,
                          onSubmit: (user, isLoading, result) {
                        if (!isLoading) {
                          Navigator.pop(context);
                          if (result['code'] == 'incorrect_password') {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Username or password not match")));
                          }
                          if (result['status'] == 'error') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(result['message']),
                              backgroundColor: Colors.black,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(
                                  bottom: 60.0, left: 5, right: 5),
                              duration: const Duration(milliseconds: 1500),
                            ));
                          }
                        } else {
                          if (user.cookie != '') {
                            printLog('Login Success');
                            context.read<StoreNotifier>().changeDemoStatus();
                            context.read<LoginNotifier>().getSettings(
                                onSubmit: (loading) {
                              if (!loading) {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    RevoPosRouteBuilder.routeBuilder(
                                        const MainPage()));
                              }
                            });
                          }
                        }
                      }, password: '12345678', username: 'adminrevo');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: RevoPosMediaQuery.getHeight(context) * 0.06,
                      width: RevoPosMediaQuery.getWidth(context),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Text("Try RevoPOS Demo Store",
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: colorWhite, fontSize: 14)),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildSelect({List<StoreModel?>? stores}) {
    stores ??= List.generate(0, (index) => null);

    return Visibility(
      visible: stores.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select your store account",
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: colorBlack),
          ),
          const SizedBox(height: 8),
          stores.isEmpty
              ? Container()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stores.length,
                  itemBuilder: (_, index) => FractionallySizedBox(
                    widthFactor: 1,
                    child: RevoPosButton(
                        text: stores![index]!.storeName,
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          setState(() {
                            baseAPI = BaseWooAPI(
                                stores![index]!.url,
                                stores[index]!.consumerKey,
                                stores[index]!.consumerSecret);
                          });
                          context
                              .read<StoreNotifier>()
                              .onSelectedStore(stores![index]);
                          // log(stores[index]!.cookie.toString());
                          await Navigator.push(
                              context,
                              RevoPosRouteBuilder.routeBuilder(
                                  const LoginPage()));
                          /*if (stores[index]!.cookie == null ||
                              stores[index]!.cookie!.isEmpty) {
                            await Navigator.push(
                                context,
                                RevoPosRouteBuilder.routeBuilder(
                                    const LoginPage()));
                          } else {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return const RevoPosLoading();
                                });
                            AppConfig.data!
                                .setString('cookie', stores[index]!.cookie!);
                            context
                                .read<LoginNotifier>()
                                .setUserData(stores[index]!.user!);
                            context.read<LoginNotifier>().getSettings(
                                onSubmit: (loading) {
                              if (!loading) {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    RevoPosRouteBuilder.routeBuilder(
                                        const MainPage()));
                              }
                            });
                          }*/
                        }),
                  ),
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                ),
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 20),
            color: colorDisabled,
          ),
        ],
      ),
    );
  }

  Widget _buildAddStore() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create new store account",
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: colorBlack),
        ),
        const SizedBox(height: 8),
        FractionallySizedBox(
          widthFactor: 1,
          child: RevoPosButton(
              text: "Add New Store",
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                await Navigator.push(context,
                        RevoPosRouteBuilder.routeBuilder(const FormStorePage()))
                    .then((value) => context.read<StoreNotifier>().getStores());
              }),
        ),
      ],
    );
  }
}
