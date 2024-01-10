import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';

class ItemDraft extends StatelessWidget {
  const ItemDraft({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colorWhite,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Customer: Andre",
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: colorBlack
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Total product: ",
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 16
                        )
                      ),
                      TextSpan(
                        text: "3",
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: colorBlack
                        )
                      ),
                    ]
                  ),
                )
              ],
            ),

            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 2,
                    itemBuilder: (_, index) => Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                          ),
                        ),
                        Text(
                          "Ice Capuccino",
                          style: Theme.of(context).textTheme.bodyText1,
                        )
                      ],
                    ),
                  )
                ),
                Text(
                  "Grand Total: Rp 33.300",
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
