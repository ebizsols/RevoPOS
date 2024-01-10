import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';

class RevoPosDashLine extends StatelessWidget {
  const RevoPosDashLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(600~/10, (index) => Expanded(
        child: Container(
          color: index % 2 == 0 ? Colors.transparent : colorBlack,
          height: 1,
        ),
      )),
    );
  }
}
