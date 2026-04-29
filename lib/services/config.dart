/// Application Configuration
class AppConfig {
  // API Configuration
  // Note: Using 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.38:5001/api',
  );

  // Debug Mode
  static const bool isDebug = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );

  // Shipping Fees
  static const double shippingFeeNormal = 50.0;
  static const double shippingFeeExpress = 100.0;

  // Bank Information
  static const String bankName = 'Kasikorn Bank';
  static const String bankAccountNumber = '1234567890';
  static const String bankAccountName = 'Click & Clack';

  // App Information
  static const String appName = 'Click & Clack';
  static const String appSubtitle = 'Gaming Gear New & Used';

  // Product Categories
  static const List<String> categories = [
    'Mouse',
    'Keyboard',
    'Headphones',
    'Mousepad',
    'Others',
  ];

  // Order Status
  static const String statusPending = 'pending';
  static const String statusPaid = 'paid';
  static const String statusShipping = 'shipping';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
}
