import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lifeline/l10n/app_localizations.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/services/purchase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // ИСПРАВЛЕНИЕ 1: Слушаем состояние (PurchaseState), а не сам сервис.
    final purchaseState = ref.watch(purchaseServiceProvider);
    // Получаем notifier для вызова методов (buyProduct, restorePurchases).
    final purchaseNotifier = ref.read(purchaseServiceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.premiumScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, l10n),
              const SizedBox(height: 32),
              _buildFeatureList(context, l10n),
              const SizedBox(height: 32),
              // ИСПРАВЛЕНИЕ 1 (продолжение): Используем purchaseState для отображения UI.
              if (purchaseState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (!purchaseState.isAvailable)
                Center(
                  child: Text(
                    "In-app purchases are not available on this device.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else if (purchaseState.products.isEmpty)
                Center(
                  child: Text(
                    "Could not load products. Please check your connection and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else
                ...purchaseState.products.map((p) =>
                    _buildProductCard(context, p, purchaseNotifier, l10n)),
              const SizedBox(height: 24),
              _buildFooter(context, purchaseNotifier, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Icon(Icons.star_purple500_outlined,
            size: 64, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n.premiumScreenHeaderTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.premiumScreenHeaderSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildFeatureList(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        _FeatureItem(
            icon: Icons.photo_library_outlined,
            text: l10n.premiumFeatureUnlimitedPhotos),
        _FeatureItem(
            icon: Icons.mic_none_outlined,
            text: l10n.premiumFeatureUnlimitedAudio),
        _FeatureItem(
            icon: Icons.music_note_outlined,
            text: l10n.premiumFeatureUnlimitedSpotify),
        _FeatureItem(
            icon: Icons.psychology_outlined,
            text: l10n.premiumFeatureAdvancedCbt),
        _FeatureItem(
            icon: Icons.notifications_active_outlined,
            text: l10n.premiumFeatureActionReminders),
        _FeatureItem(
            icon: Icons.public_outlined,
            text: l10n.premiumFeatureHistoricalContext),
        _FeatureItem(
            icon: Icons.waves_outlined, text: l10n.premiumFeatureSoundLibrary),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ProductDetails product,
      PurchaseService service, AppLocalizations l10n) {
    final bool isYearly = product.id.contains('yearly');
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: isYearly
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2),
          borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => service.buyProduct(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(product.title,
                      style: Theme.of(context).textTheme.titleLarge)),
              const SizedBox(height: 8),
              Text(product.price,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              if (isYearly)
                Text(l10n.premiumScreenYearlyPopular,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(
      BuildContext context, PurchaseService service, AppLocalizations l10n) {
    return Column(
      children: [
        TextButton(
          onPressed: service.restorePurchases,
          child: Text(l10n.premiumScreenRestore),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16.0,
          runSpacing: 8.0,
          children: [
            TextButton(
                onPressed: () =>
                    launchUrl(Uri.parse("https://lifeline-ai.web.app/terms.html")),
                child: Text(l10n.premiumScreenTerms)),
            TextButton(
                onPressed: () => launchUrl(
                    Uri.parse("https://lifeline-ai.web.app/privacy.html")),
                child: Text(l10n.premiumScreenPrivacy)),
          ],
        )
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // ИСПРАВЛЕНИЕ 2: Заменен устаревший withOpacity.
          Icon(icon,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha((255 * 0.8).round())),
          const SizedBox(width: 16),
          Expanded(
              child:
                  Text(text, style: Theme.of(context).textTheme.titleMedium)),
        ],
      ),
    );
  }
}

