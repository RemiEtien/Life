import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/application_providers.dart';

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
      debugPrint('[PurchaseService] Purchase stream error: $error');
    });
    initialize();
  }

  Future<void> initialize() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      state = state.copyWith(isAvailable: false, isLoading: false);
      debugPrint('[PurchaseService] In-app purchases not available.');
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
      debugPrint('[PurchaseService] Not found IDs: ${response.notFoundIDs}');
    }
    final products = response.productDetails;
    // Сортируем, чтобы годовая подписка всегда была второй
    products.sort((a, b) => a.id == _yearlySubscriptionId ? 1 : -1);
    state = state.copyWith(products: products);
  }

  Future<bool> buyProduct(ProductDetails productDetails) async {
    try {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);

      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        debugPrint('[PurchaseService] Failed to initiate purchase for ${productDetails.id}');
      }

      return success;
    } catch (e, stackTrace) {
      debugPrint('[PurchaseService] Exception during buyProduct: $e');
      debugPrint('[PurchaseService] Stack trace: $stackTrace');

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
      debugPrint('[PurchaseService] Purchases restored successfully');
    } catch (e, stackTrace) {
      debugPrint('[PurchaseService] Error restoring purchases: $e');
      debugPrint('[PurchaseService] Stack trace: $stackTrace');

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
          debugPrint('[PurchaseService] Purchase error: ${purchaseDetails.error}');
          state = state.copyWith(
            isLoading: false,
            purchaseSuccess: false,
            errorMessage: purchaseDetails.error?.message ?? 'Purchase failed',
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _verifyAndGrantPremium(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
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

      debugPrint('[PurchaseService] Calling verifyPurchase function with receipt for product ${purchaseDetails.productID}...');

      final result = await callable.call({
        'platform': platform,
        'receipt': receipt,
        'productId': purchaseDetails.productID,
      });

      debugPrint('[PurchaseService] Cloud function call successful. Result: ${result.data}');

      // ИЗМЕНЕНИЕ: Принудительно обновляем профиль пользователя после успешной покупки
      // Это заставит isPremiumProvider пересчитаться
      _ref.invalidate(userProfileProvider);
      debugPrint('[PurchaseService] User profile invalidated to refresh premium status');

      // Notify UI of successful purchase
      state = state.copyWith(
        isLoading: false,
        purchaseSuccess: true,
        errorMessage: null,
      );

    } catch (e) {
      // ИЗМЕНЕНИЕ: Более детальное логирование ошибок
      debugPrint('[PurchaseService] Error verifying purchase with cloud function: $e');
      if (e is FirebaseFunctionsException) {
          debugPrint('[PurchaseService] Cloud function error details: code=${e.code}, message=${e.message}, details=${e.details}');
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

