
class SocketConfig {
  final String env;
  final String addressDev;
  final String addressProd;
  final int port;
  final int waitTimeBeforeConnecting;
  final int waitTimeAfterConnecting;
  final int sendInterval;
  final int retryInterval;
  final int connectionTimeout;

  SocketConfig({
    required this.env,
    this.addressDev = '127.0.0.1',
    this.addressProd = '192.168.42.100',
    this.port = 55001,
    this.waitTimeBeforeConnecting = 1000,
    this.waitTimeAfterConnecting = 5000,
    this.sendInterval = 1000,
    this.retryInterval = 5000,
    this.connectionTimeout = 5000,
  });

  String get address => (env == 'dev') ? addressDev : addressProd;
}

final socketConfig = SocketConfig(
  env: const String.fromEnvironment('ENV', defaultValue: 'dev'),
);
