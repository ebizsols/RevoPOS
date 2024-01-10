import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';

class ItemTransactions extends StatelessWidget {
  final Function() onTap;
  final Orders? orders;

  const ItemTransactions({Key? key, required this.onTap, this.orders})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    final String date = formatter.format(DateTime.parse(orders!.dateCreated!));

    return Card(
      color: orders!.status == "on-hold"
          ? HexColor("FCEBF6")
          : orders!.status == "pending"
              ? HexColor("FAF8DF")
              : orders!.status == "processing"
                  ? HexColor("E8FBE1")
                  : orders!.status == "completed"
                      ? HexColor("ECE3FC")
                      : HexColor("DEE0E4"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            "${orders!.status}",
                            overflow: TextOverflow.clip,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                          ),
                        ),
                        Text(
                          "#${orders!.id}",
                          overflow: TextOverflow.clip,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${orders!.billing!.firstName} ${orders!.billing!.lastName}",
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          date,
                          overflow: TextOverflow.clip,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      RevoPosButton(
                        text: "Detail",
                        onPressed: onTap,
                        radius: 14,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 16),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
