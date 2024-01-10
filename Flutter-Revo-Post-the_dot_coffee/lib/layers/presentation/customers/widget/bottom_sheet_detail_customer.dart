import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/presentation/chat/page/chat_detail_page.dart';
import 'package:revo_pos/layers/presentation/customers/notifier/customers_notifier.dart';
import 'package:revo_pos/layers/presentation/customers/page/form_customer_page.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/detail_order_notifier.dart';

import '../../revo_pos_dialog.dart';
import '../../revo_pos_loading.dart';

class BottomSheetDetailCustomer extends StatefulWidget {
  final Customer? customer;
  final Function() onRefresh;

  const BottomSheetDetailCustomer(
      {Key? key, this.customer, required this.onRefresh})
      : super(key: key);

  @override
  _BottomSheetDetailCustomerState createState() =>
      _BottomSheetDetailCustomerState();
}

class _BottomSheetDetailCustomerState extends State<BottomSheetDetailCustomer> {
  DetailOrderNotifier? detailOrderNotifier;

  void initState() {
    super.initState();
    detailOrderNotifier =
        Provider.of<DetailOrderNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    "assets/images/placeholder_user.png",
                    fit: BoxFit.cover,
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${widget.customer!.firstName} ${widget.customer!.lastName}",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Visibility(
                  visible: detailOrderNotifier!.userSetting!.liveChat!,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/live_chat.png',
                      height: 20,
                      width: 20,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          RevoPosRouteBuilder.routeBuilder(ChatDetailPage(
                            receiverID: widget.customer!.id!,
                            chatID: 0,
                            username: widget.customer!.username,
                          )));
                    },
                  ),
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.userEdit,
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        RevoPosRouteBuilder.routeBuilder(FormCustomerPage(
                          customer: Customer(
                              firstName: "${widget.customer!.firstName}",
                              lastName: "${widget.customer!.lastName}",
                              email: "${widget.customer!.email}",
                              username: "${widget.customer!.username}",
                              id: widget.customer!.id,
                              billing: Billing(
                                  phone: widget.customer!.billing!.phone,
                                  address1: widget.customer!.billing!.address1,
                                  city: widget.customer!.billing!.city,
                                  company: widget.customer!.billing!.company,
                                  country: widget.customer!.billing!.country,
                                  state: widget.customer!.billing!.state)),
                        ))).then((value) {
                      if (value == 200) {
                        widget.onRefresh();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.trash,
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
                  onPressed: () {
                    _showDeleteDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: Text(
                      "First name",
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    "${widget.customer!.firstName}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: Text(
                      "Last name",
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    "${widget.customer!.lastName}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: Text(
                      "Phone Number",
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    "${widget.customer!.billing!.phone}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: Text(
                      "Email",
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    "${widget.customer!.email}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _showDeleteDialog() {
    showDialog(
        context: context,
        builder: (_) => RevoPosDialog(
              titleIcon: FontAwesomeIcons.trash,
              primaryColor: colorDanger,
              title: "Delete Item",
              content: "Do you want to delete customer?",
              actions: [
                RevoPosDialogAction(
                    text: "No", onPressed: () => Navigator.pop(context)),
                RevoPosDialogAction(
                    text: "Yes",
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return const RevoPosLoading();
                          });
                      context.read<CustomersNotifier>().deleteCustomer(
                          id: widget.customer!.id!,
                          onSubmit: (result, isLoading) {
                            if (!isLoading) {
                              Navigator.pop(context);
                              if (result['id'] != null) {
                                Navigator.pop(context, 200);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Customer deleted"),
                                  backgroundColor: Colors.green,
                                ));
                                widget.onRefresh();
                              } else if (result['message'] != null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            }
                          });
                    })
              ],
            ));
  }
}
