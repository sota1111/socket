import '../config.dart';

class SocketConfig {
  final String env;
  final String addressLinux;
  final String addressAndroid;
  final int port;
  final int waitTimeBeforeConnecting;
  final int waitTimeAfterConnecting;
  final int sendInterval;
  final int retryInterval;
  final int connectionTimeout;

  SocketConfig({
    required this.env,
    this.addressLinux = '127.0.0.1',
    this.addressAndroid = '192.168.42.100',
    this.port = 55001,
    this.waitTimeBeforeConnecting = 1000,
    this.waitTimeAfterConnecting = 5000,
    this.sendInterval = 1000,
    this.retryInterval = 5000,
    this.connectionTimeout = 5000,
  });

  String get address => (env == 'linux') ? addressLinux : addressAndroid;
}

final socketConfig = SocketConfig(
  env: env,
);
