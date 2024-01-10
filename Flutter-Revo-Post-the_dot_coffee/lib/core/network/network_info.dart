import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<ConnectivityResult> get connectivity;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<ConnectivityResult> get connectivity => connectionChecker.checkConnectivity();
}
