/// This library is customize from the woocommerce_api: ^0.0.8

import 'dart:async';
import "dart:collection";
import 'dart:convert';
import "dart:core";
import 'dart:io';
import "dart:math";

import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:revo_pos/core/utils/global_functions.dart';

class QueryString {
  static Map parse(String query) {
    var search = RegExp('([^&=]+)=?([^&]*)');
    var result = {};

    // Get rid off the beginning ? in query strings.
    if (query.startsWith('?')) query = query.substring(1);
    // A custom decoder.
    decode(String? s) => Uri.decodeComponent(s!.replaceAll('+', ' '));

    // Go through all the matches and build the result map.
    for (Match match in search.allMatches(query)) {
      result[decode(match.group(1))] = decode(match.group(2));
    }
    return result;
  }
}

class BaseWooAPI {
  String? url;
  String? consumerKey;
  String? consumerSecret;
  bool? isHttps;

  BaseWooAPI(this.url, this.consumerKey, this.consumerSecret) {
    if (url!.startsWith("https")) {
      isHttps = true;
    } else {
      isHttps = false;
    }
  }

  _getOAuthURL(String requestMethod, String endpoint, version, bool isCustom,
      bool isSetting, bool isOrder, bool isCustomRevoShop) {
    var consumerKey = this.consumerKey;
    var consumerSecret = this.consumerSecret;

    var token = "";
    var url = this.url! + "/wp-json/wc/v3/" + endpoint;

    if (isCustom) {
      url = this.url! + "/wp-json/revo-post/" + endpoint;
    }
    if (isCustomRevoShop) {
      url = this.url! + "/wp-json/revo-admin/v1/" + endpoint;
    }
    // Default one is v3
    if (version == 2) {
      url = this.url! + "/wp-json/wc/v2/" + endpoint;
    }
    if (isOrder || isSetting) {
      url = this.url! + endpoint;
    }
    var containsQueryParams = url.contains("?");
    printLog("url :${url}");
    // If website is HTTPS based, no need for OAuth, just return the URL with CS and CK as query params
    if (isHttps == true &&
        !isCustom &&
        !isCustomRevoShop &&
        !isSetting &&
        version != 2) {
      return url +
          (containsQueryParams == true
              ? "&consumer_key=" +
                  this.consumerKey! +
                  "&consumer_secret=" +
                  this.consumerSecret!
              : "?consumer_key=" +
                  this.consumerKey! +
                  "&consumer_secret=" +
                  this.consumerSecret!);
    }

    var rand = Random();
    var codeUnits = List.generate(10, (index) {
      return rand.nextInt(26) + 97;
    });

    var nonce = String.fromCharCodes(codeUnits);
    int timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();

    var method = requestMethod;
    var parameters = "oauth_consumer_key=" +
        consumerKey! +
        "&oauth_nonce=" +
        nonce +
        "&oauth_signature_method=HMAC-SHA1&oauth_timestamp=" +
        timestamp.toString() +
        "&oauth_version=1.0&";

    if (containsQueryParams == true) {
      parameters = parameters + url.split("?")[1];
    } else {
      parameters = parameters.substring(0, parameters.length - 1);
    }

    Map<dynamic, dynamic> params = QueryString.parse(parameters);
    Map<dynamic, dynamic> treeMap = SplayTreeMap<dynamic, dynamic>();
    treeMap.addAll(params);

    String parameterString = "";

    for (var key in treeMap.keys) {
      parameterString = parameterString +
          Uri.encodeQueryComponent(key) +
          "=" +
          treeMap[key] +
          "&";
    }

    parameterString = parameterString.substring(0, parameterString.length - 1);
    parameterString = parameterString.replaceAll(' ', '%20');

    var baseString = method +
        "&" +
        Uri.encodeQueryComponent(
            containsQueryParams == true ? url.split("?")[0] : url) +
        "&" +
        Uri.encodeQueryComponent(parameterString);

    var signingKey = consumerSecret! + "&" + token;

    var hmacSha1 =
        crypto.Hmac(crypto.sha1, utf8.encode(signingKey)); // HMAC-SHA1
    var signature = hmacSha1.convert(utf8.encode(baseString));

    var finalSignature = base64Encode(signature.bytes);

    var requestUrl = "";

    if (containsQueryParams == true) {
      requestUrl = url.split("?")[0] +
          "?" +
          parameterString +
          "&oauth_signature=" +
          Uri.encodeQueryComponent(finalSignature);
    } else {
      requestUrl = url +
          "?" +
          parameterString +
          "&oauth_signature=" +
          Uri.encodeQueryComponent(finalSignature);
    }
    return requestUrl;
  }

  Future<http.StreamedResponse> getStream(String endPoint) async {
    var client = http.Client();
    var request = http.Request('GET', Uri.parse(url!));
    return await client.send(request);
  }

  Future<dynamic> getAsync(String endPoint,
      {int version = 3,
      bool isCustom = false,
      bool isOrder = false,
      bool isSetting = false,
      bool printedLog = false,
      bool isCustomRevoShop = false}) async {
    String url = _getOAuthURL("GET", endPoint, version, isCustom, isSetting,
        isOrder, isCustomRevoShop);
    http.Response response;

    DateTime start = DateTime.now();
    if (printedLog) {
      printLog(
          "[api][${DateTime.now().toString().split(' ').last}] getAsync START [endPoint:$endPoint]");
    }

    if (isOrder) {
      return url;
    }

    response = await http.get(Uri.parse(url));

    DateTime end = DateTime.now();
    if (printedLog) {
      printLog(
          "[api][${DateTime.now().toString().split(' ').last}] getAsync END [endPoint:$endPoint] [url:$url] [responseTime:${end.difference(start).inSeconds}]");
    }

    if (printedLog) {
      printLog("Result : ${response.body}");
    }

    return response;
  }

  Future<dynamic> postAsync(String endPoint, Map data,
      {int version = 3,
      bool isCustom = false,
      bool isOrder = false,
      bool printedLog = false,
      bool isCustomRevoShop = false}) async {
    var url = _getOAuthURL(
        "POST", endPoint, version, isCustom, false, isOrder, isCustomRevoShop);

    DateTime start = DateTime.now();

    printLog(
        "[api][${DateTime.now().toString().split(' ').last}] postAsync START [endPoint:$endPoint] url:$url");

    http.Client client;

    client = http.Client();

    var request = http.Request('POST', Uri.parse(url));
    request.headers[HttpHeaders.contentTypeHeader] =
        'application/json; charset=utf-8';
    request.headers[HttpHeaders.cacheControlHeader] = "no-cache";
    request.body = json.encode(data);
    var response =
        await client.send(request).then((res) => res.stream.bytesToString());
    var dataResponse = await json.decode(response);

    DateTime end = DateTime.now();

    printLog(
        "[api][${DateTime.now().toString().split(' ').last}] postAsync END [endPoint:$endPoint] [responseTime:${end.difference(start).inSeconds}]");
    return dataResponse;
  }

  Future<dynamic> putAsync(String endPoint, Map data,
      {int version = 3,
      bool isCustom = false,
      bool isOrder = false,
      bool printedLog = false,
      bool isCustomRevoShop = false}) async {
    var url = _getOAuthURL(
        "PUT", endPoint, version, isCustom, false, isOrder, isCustomRevoShop);
    DateTime start = DateTime.now();

    printLog(
        "[api][${DateTime.now().toString().split(' ').last}] putAsync START [endPoint:$endPoint] url:$url");

    var request = await http.put(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(data));
    var dataResponse = await json.decode(request.body);
    DateTime end = DateTime.now();

    printLog(
        "[api][${DateTime.now().toString().split(' ').last}] putAsync END [endPoint:$endPoint] [responseTime:${end.difference(start).inSeconds}]");
    return dataResponse;
  }

  Future<dynamic> deleteAsync(String endPoint, Map data,
      {int version = 3,
      bool isCustom = false,
      bool isOrder = false,
      bool isCustomRevoShop = false}) async {
    var url = _getOAuthURL("DELETE", endPoint, version, isCustom, false,
        isOrder, isCustomRevoShop);
    DateTime start = DateTime.now();

    printLog(
        "[api][${DateTime.now().toString().split(' ').last}] deleteAsync START [endPoint:$endPoint] url:$url");
    var request = await http.delete(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(data));
    var dataResponse = await json.decode(request.body);

    DateTime end = DateTime.now();

    printLog(
        "[api][${DateTime.now().toString().split(' ').last}] deleteAsync END [endPoint:$endPoint] [responseTime:${end.difference(start).inSeconds}]");
    return dataResponse;
  }
}
