import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_store_config.dart';
import 'subscription_service.dart';

/// Premium on iPhone, sold through Apple In-App Purchase. The App Store
/// doesn't allow Stripe for digital subscriptions (guideline 3.1.1).
///
/// StoreKit only tells the app that a purchase happened; the backend checks
/// it with Apple and decides access, just like Stripe's webhook on Android.
class AppleSubscription {
  static final _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _updates;
  static ProductDetails? _product;

  /// Set while the paywall waits on the purchase it started.
  static Completer<bool>? _buying;

  /// Backend checks started by a restore, so restore() can wait for them.
  static List<Future<bool>>? _restoring;

  /// Listens for purchases for the whole app run. Must start at launch:
  /// renewals and interrupted purchases are delivered then, and a
  /// transaction that is never finished gets redelivered forever.
  static void start() {
    _updates ??= _iap.purchaseStream.listen(
      _onUpdates,
      onError: (Object e) => _finishBuying(error: e),
    );
  }

  /// The subscription as configured in App Store Connect, with the price
  /// already localised for the user's storefront. Null if unavailable.
  static Future<ProductDetails?> product() async {
    if (_product != null) return _product;
    if (!await _iap.isAvailable()) return null;
    final resp =
        await _iap.queryProductDetails({AppStoreConfig.premiumProductId});
    if (resp.productDetails.isNotEmpty) _product = resp.productDetails.first;
    return _product;
  }

  /// Opens Apple's purchase sheet. Returns true once the backend has granted
  /// access and false if the user backed out.
  static Future<bool> buy() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('You must be signed in to subscribe');
    final details = await product();
    if (details == null) {
      throw Exception('The App Store is not available right now');
    }

    final completer = _buying = Completer<bool>();
    // Tags the purchase with the account (Apple's appAccountToken) so the
    // backend can tell whose subscription it is.
    final started = await _iap.buyNonConsumable(
      purchaseParam:
          PurchaseParam(productDetails: details, applicationUserName: userId),
    );
    if (!started) {
      _buying = null;
      return false;
    }
    return completer.future;
  }

  /// "Restore Purchases" (required by App Review): re-links a subscription
  /// bought earlier with this Apple ID. Returns true if access came back.
  static Future<bool> restore() async {
    final restoring = _restoring = [];
    try {
      await _iap.restorePurchases();
      // Restored transactions reach the stream just after this returns.
      await Future<void>.delayed(const Duration(seconds: 1));
      final results = await Future.wait(restoring);
      return results.any((granted) => granted);
    } finally {
      _restoring = null;
    }
  }

  static Future<void> _onUpdates(List<PurchaseDetails> purchases) async {
    // Apple reports the whole subscription for any one of its transactions,
    // so a batch of renewals needs only one backend check.
    Future<bool>? check;

    for (final purchase in purchases) {
      var finish = true;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          continue; // e.g. Ask to Buy — wait for the final status
        case PurchaseStatus.canceled:
          _finishBuying(result: false);
        case PurchaseStatus.error:
          _finishBuying(error: purchase.error?.message ?? 'Purchase failed');
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          check ??= _verify(purchase);
          _restoring?.add(check);
          try {
            final granted = await check;
            if (purchase.status == PurchaseStatus.purchased) {
              _finishBuying(result: granted);
            }
          } on PurchaseRejected catch (e) {
            _finishBuying(error: e.message);
          } catch (e) {
            // Backend unreachable: leave the transaction unfinished so
            // StoreKit hands it to us again on the next launch.
            finish = false;
            _finishBuying(error: e);
          }
      }
      if (finish && purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  static Future<bool> _verify(PurchaseDetails purchase) async {
    final transactionId = purchase.purchaseID;
    if (transactionId == null) throw Exception('Purchase has no transaction id');
    final status = await SubscriptionService.verifyApplePurchase(transactionId);
    return status.hasAccess;
  }

  static void _finishBuying({bool result = false, Object? error}) {
    final completer = _buying;
    if (completer == null || completer.isCompleted) return;
    _buying = null;
    if (error != null) {
      completer.completeError(error is String ? Exception(error) : error);
    } else {
      completer.complete(result);
    }
  }
}
