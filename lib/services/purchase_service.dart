import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lifeline/providers/application_providers.dart';

// Идентификаторы ваших подписок в Google Play и App Store
const String _monthlySubscriptionId = 'lifeline_premium_monthly';
const String _yearlySubscriptionId = 'lifeline_premium_yearly';
const Set<String> _productIds = {_monthlySubscriptionId, _yearlySubscriptionId};

@immutable
class PurchaseState {
  final List<ProductDetails> products;
  final bool isAvailable;
  final bool isLoading;

  const PurchaseState({
    this.products = const [],
    this.isAvailable = false,
    this.isLoading = true,
  });

  PurchaseState copyWith({
    List<ProductDetails>? products,
    bool? isAvailable,
    bool? isLoading,
  }) {
    return PurchaseState(
      products: products ?? this.products,
      isAvailable: isAvailable ?? this.isAvailable,
      isLoading: isLoading ?? this.isLoading,
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
      debugPrint("[PurchaseService] Purchase stream error: $error");
    });
    initialize();
  }

  Future<void> initialize() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      state = state.copyWith(isAvailable: false, isLoading: false);
      debugPrint("[PurchaseService] In-app purchases not available.");
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
      debugPrint("[PurchaseService] Not found IDs: ${response.notFoundIDs}");
    }
    final products = response.productDetails;
    // Сортируем, чтобы годовая подписка всегда была второй
    products.sort((a, b) => a.id == _yearlySubscriptionId ? 1 : -1);
    state = state.copyWith(products: products);
  }

  Future<void> buyProduct(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Покупка в процессе...
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint(
              "[PurchaseService] Purchase error: ${purchaseDetails.error}");
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

      debugPrint("[PurchaseService] Calling verifyPurchase function with receipt for product ${purchaseDetails.productID}...");
      
      final result = await callable.call({
        'platform': platform,
        'receipt': receipt,
        'productId': purchaseDetails.productID,
      });

      debugPrint("[PurchaseService] Cloud function call successful. Result: ${result.data}");
      
    } catch (e) {
      // ИЗМЕНЕНИЕ: Более детальное логирование ошибок
      debugPrint("[PurchaseService] Error verifying purchase with cloud function: $e");
      if (e is FirebaseFunctionsException) {
          debugPrint("[PurchaseService] Cloud function error details: code=${e.code}, message=${e.message}, details=${e.details}");
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

