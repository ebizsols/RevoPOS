import 'package:flutter/material.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';

class ItemSearchCustomer extends StatelessWidget {
  final Function() onTap;
  final Customer? customer;

  const ItemSearchCustomer({Key? key, required this.onTap, this.customer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    "assets/images/placeholder_user.png",
                    fit: BoxFit.contain,
                    width: 50,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${customer!.firstName} ${customer!.lastName}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Text(
                      "${customer!.billing!.phone}",
                      overflow: TextOverflow.clip,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Text(
                      "${customer!.billing!.address1}",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                )),
                const SizedBox(width: 12),
              ],
            ),
            // Container(
            //   width: double.infinity,
            //   height: 1,
            //   color: Colors.black26,
            // )
            const Divider(
              thickness: 1,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
