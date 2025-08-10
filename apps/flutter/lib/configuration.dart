/// Global configuration for the system
class Configuration {
  // Application configuration
  static const String appName = 'Minima';
  static const String appVersion = '0.1.0';

  // Database configuration
  static const String databaseName = 'minima.db';
  static const int databaseVersion = 1;

  // API configuration
  static const int defaultApiPort = 4547;
  static const String apiHost = '0.0.0.0';

  // Sync configuration
  static const Duration syncInterval = Duration(seconds: 15);
  static const Duration syncTimeout = Duration(seconds: 30);

  // Tailscale configuration
  static const String tailscaleApiBaseUrl = 'https://api.tailscale.com/api/v2';
  static const String tailscaleDefaultTailnet = '-';
  static const Duration tailscaleTimeout = Duration(seconds: 10);

  // Node configuration
  static const String nodeIdPrefix = 'node';

  // Logging configuration
  static const bool enableDebugLogging = true;
  static const bool enableApiLogging = true;

  // Network configuration
  static const Duration httpTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
