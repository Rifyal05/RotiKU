import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AppConstants {
  static const String appName = 'RotiKu';
  static const String appVersion = 'v1.0.0';

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  static const String bucketPaymentProofs = 'payment-proofs';
  static const String bucketProductImages = 'product-images';

  static const String tableUsers = 'users';
  static const String tableProducts = 'products';
  static const String tableOrders = 'orders';

  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';

  static const String statusPending = 'pending';
  static const String statusProcessed = 'processed';
  static const String statusShipped = 'shipped';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
}
