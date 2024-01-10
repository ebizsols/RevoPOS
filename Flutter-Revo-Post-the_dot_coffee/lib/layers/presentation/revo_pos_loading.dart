import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:revo_pos/core/constant/constants.dart';

class RevoPosLoading extends StatelessWidget {
  const RevoPosLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spinKit = WillPopScope(
      child: Center(
          child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: SpinKitFadingCircle(
          itemBuilder: (BuildContext context, int index) {
            return Icon(
              Icons.circle,
              size: 10,
              color: colorPrimary,
            );
          },
        ),
      )),
      onWillPop: null,
    );
    return spinKit;
  }
}
