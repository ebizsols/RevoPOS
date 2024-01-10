import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:revo_pos/services/base_api.dart';

// Colors
Map<int, Color> colorPrimaryMap = {
  50: const Color.fromRGBO(117, 52, 34, .05),
  100: const Color.fromRGBO(117, 52, 34, .1),
  200: const Color.fromRGBO(117, 52, 34, .2),
  300: const Color.fromRGBO(117, 52, 34, .3),
  400: const Color.fromRGBO(117, 52, 34, .4),
  500: const Color.fromRGBO(117, 52, 34, .5),
  600: const Color.fromRGBO(117, 52, 34, .6),
  700: const Color.fromRGBO(117, 52, 34, .7),
  800: const Color.fromRGBO(117, 52, 34, .8),
  900: const Color.fromRGBO(117, 52, 34, .9),
};

Map<int, Color> colorAccentMap = {
  50: const Color.fromRGBO(255, 235, 201, .05),
  100: const Color.fromRGBO(255, 235, 201, .1),
  200: const Color.fromRGBO(255, 235, 201, .2),
  300: const Color.fromRGBO(255, 235, 201, .3),
  400: const Color.fromRGBO(255, 235, 201, .4),
  500: const Color.fromRGBO(255, 235, 201, .5),
  600: const Color.fromRGBO(255, 235, 201, .6),
  700: const Color.fromRGBO(255, 235, 201, .7),
  800: const Color.fromRGBO(255, 235, 201, .8),
  900: const Color.fromRGBO(255, 235, 201, .9),
};

var colorPrimary = MaterialColor(0xFF753422, colorPrimaryMap);
var colorAccent = MaterialColor(0xFFFFEBC9, colorAccentMap);

var colorDanger = const Color(0xFFC60000);
var colorDisabled = const Color(0xFFD2D2D2);
var colorWhite = const Color(0xFFF1F1F1);
var colorBlack = const Color(0xFF1F1F1F);

var currencyFormat =
    NumberFormat.currency(locale: "ID", symbol: "Rp ", decimalDigits: 0);

// baseurl
String url = "https://thedotcoffee.com";

// oauth_consumer_key
String consumerKey = "ck_2f03677031813314eb5dd02068e93187c4213b53";
String consumerSecret = "cs_0a17c80b786d3427f49015029f0a81984f3225b7";

//Store name for printer
String storeName = "The Dot Coffee POS";

BaseWooAPI? baseAPI = BaseWooAPI(url, consumerKey, consumerSecret);
