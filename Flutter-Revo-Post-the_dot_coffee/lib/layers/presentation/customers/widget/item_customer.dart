import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';

class ItemCustomer extends StatelessWidget {
  final Customer? customer;
  final Function() onTap;

  const ItemCustomer({Key? key, this.customer, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? name;
    String? address;
    String? phone;

    if (customer != null) {
      name = "${customer!.firstName} ${customer!.lastName}";
      address = "${customer!.billing!.address1}";
      phone = "${customer!.billing!.phone}";
    }

    return Card(
      color: colorWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        "assets/images/placeholder_user.png",
                        fit: BoxFit.contain,
                        width: RevoPosMediaQuery.getWidth(context) * 0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text(
                        phone ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text(
                        address ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  )),
                  const SizedBox(width: 12),
                  RevoPosButton(
                    text: "Detail",
                    onPressed: onTap,
                    radius: 14,
                    fontSize: 11,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
