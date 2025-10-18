import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'analytics_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/application_providers.dart';
import '../utils/safe_logger.dart';

// Идентификаторы ваших подписок в Google Play и App Store
const String _monthlySubscriptionId = 'lifeline_premium_monthly';
const String _yearlySubscriptionId = 'lifeline_premium_yearly';
const Set<String> _productIds = {_monthlySubscriptionId, _yearlySubscriptionId};

@immutable
class PurchaseState {
  final List<ProductDetails> products;
  final bool isAvailable;
  final bool isLoading;
  final bool purchaseSuccess;
  final String? errorMessage;

  const PurchaseState({
    this.products = const [],
    this.isAvailable = false,
    this.isLoading = true,
    this.purchaseSuccess = false,
    this.errorMessage,
  });

  PurchaseState copyWith({
    List<ProductDetails>? products,
    bool? isAvailable,
    bool? isLoading,
    bool? purchaseSuccess,
    String? errorMessage,
  }) {
    return PurchaseState(
      products: products ?? this.products,
      isAvailable: isAvailable ?? this.isAvailable,
      isLoading: isLoading ?? this.isLoading,
      purchaseSuccess: purchaseSuccess ?? this.purchaseSuccess,
      errorMessage: errorMessage,
    );
  }
}

class PurchaseService extends StateNotifier<PurchaseState> {
  final Ref _ref;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  PurchaseService(this._ref) : super(const PurchaseState()) {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _handlePurchaseUpdates(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      SafeLogger.error('Purchase stream error', error: error, tag: 'PurchaseService');
    });
    initialize();
  }

  Future<void> initialize() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      state = state.copyWith(isAvailable: false, isLoading: false);
      SafeLogger.warning('In-app purchases not available on this device', tag: 'PurchaseService');
      return;
    }
    state = state.copyWith(isAvailable: true);
    await _loadProducts();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadProducts() async {
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      SafeLogger.warning('Product IDs not found: ${response.notFoundIDs}', tag: 'PurchaseService');
    }
    final products = response.productDetails;
    // Сортируем, чтобы годовая подписка всегда была второй
    products.sort((a, b) => a.id == _yearlySubscriptionId ? 1 : -1);
    state = state.copyWith(products: products);
  }

  Future<bool> buyProduct(ProductDetails productDetails) async {
    try {
      // Log analytics - purchase initiated
      await AnalyticsService.logPurchaseInitiated(productDetails.id);

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);

      // NOTE: Known issue in com.android.billingclient:billing@7.1.1
      // Sometimes ProxyBillingActivity crashes with NullPointerException on PendingIntent.getIntentSender()
      // This is a Google Play Billing SDK bug, not our fault. Error is non-fatal and purchase still works.
      // See: https://issuetracker.google.com/issues/264882610
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        SafeLogger.warning('Failed to initiate purchase for product', tag: 'PurchaseService');
      }

      return success;
    } catch (e, stackTrace) {
      SafeLogger.error('Exception during buyProduct', error: e, stackTrace: stackTrace, tag: 'PurchaseService');

      // Log to Crashlytics as non-fatal
      if (!kDebugMode) {
        unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Purchase initiation failed'));
      }

      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      SafeLogger.debug('Purchases restored successfully', tag: 'PurchaseService');
    } catch (e, stackTrace) {
      SafeLogger.error('Error restoring purchases', error: e, stackTrace: stackTrace, tag: 'PurchaseService');

      // Log to Crashlytics as non-fatal
      if (!kDebugMode) {
        unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Restore purchases failed'));
      }
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Покупка в процессе...
        state = state.copyWith(isLoading: true, purchaseSuccess: false, errorMessage: null);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          SafeLogger.warning('Purchase error: ${purchaseDetails.error?.message ?? "Unknown"}', tag: 'PurchaseService');

          // Log analytics - purchase failed
          unawaited(AnalyticsService.logPurchaseFailed(
            purchaseDetails.productID,
            reason: purchaseDetails.error?.message ?? 'Unknown error',
          ));

          state = state.copyWith(
            isLoading: false,
            purchaseSuccess: false,
            errorMessage: purchaseDetails.error?.message ?? 'Purchase failed',
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          unawaited(_verifyAndGrantPremium(purchaseDetails));
        }

        if (purchaseDetails.pendingCompletePurchase) {
          unawaited(_inAppPurchase.completePurchase(purchaseDetails));
        }
      }
    }
  }

  Future<void> _verifyAndGrantPremium(PurchaseDetails purchaseDetails) async {
    try {
      final functions = _ref.read(firebaseFunctionsProvider);
      // ИЗМЕНЕНИЕ: Добавляем таймаут для вызова функции
      final callable = functions.httpsCallable(
        'verifyPurchase',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );

      final platform =
          defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios';
      final receipt = purchaseDetails.verificationData.serverVerificationData;

      SafeLogger.debug('Calling verifyPurchase cloud function', tag: 'PurchaseService');

      await callable.call({
        'platform': platform,
        'receipt': receipt,
        'productId': purchaseDetails.productID,
      });

      SafeLogger.debug('Purchase verification successful', tag: 'PurchaseService');

      // Extract price from ProductDetails (we'll need to get it from state.products)
      final product = state.products.firstWhere(
        (p) => p.id == purchaseDetails.productID,
        orElse: () => throw Exception('Product not found'),
      );
      final price = double.tryParse(product.rawPrice.toString()) ?? 0.0;
      final currency = product.currencyCode;

      // Log analytics - purchase completed
      await AnalyticsService.logPurchaseCompleted(
        purchaseDetails.productID,
        purchaseDetails.purchaseID ?? 'unknown',
        price,
        currency: currency,
      );

      // ИЗМЕНЕНИЕ: Принудительно обновляем профиль пользователя после успешной покупки
      // Это заставит isPremiumProvider пересчитаться
      _ref.invalidate(userProfileProvider);
      SafeLogger.debug('User profile invalidated to refresh premium status', tag: 'PurchaseService');

      // Notify UI of successful purchase
      state = state.copyWith(
        isLoading: false,
        purchaseSuccess: true,
        errorMessage: null,
      );

    } catch (e) {
      // ИЗМЕНЕНИЕ: Более детальное логирование ошибок
      if (e is FirebaseFunctionsException) {
        SafeLogger.error('Cloud function error: ${e.code} - ${e.message}', error: e, tag: 'PurchaseService');
      } else {
        SafeLogger.error('Error verifying purchase', error: e, tag: 'PurchaseService');
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

