import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/application_providers.dart';
import '../screens/premium_screen.dart';

/// A prominent banner card to be placed on the profile screen.
class PremiumBannerCard extends ConsumerWidget {
  const PremiumBannerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);

    // Не показывать баннер, если пользователь уже Premium
    if (isPremium) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen()));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: Theme.of(context).colorScheme.primary, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.premiumBannerTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.premiumBannerSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact tile to show instead of a disabled premium feature.
class PremiumFeatureLockTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const PremiumFeatureLockTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(text, style: const TextStyle(color: Colors.grey)),
      trailing: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
      onTap: () {
         Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen()));
      },
    );
  }
}

/// Shows a dialog prompting the user to upgrade to premium.
Future<void> showPremiumDialog(BuildContext context, String feature) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.premiumDialogTitle),
        content: Text(l10n.premiumDialogContent(feature)),
        actions: [
          TextButton(
            child: Text(l10n.profileCancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text(l10n.premiumDialogGoPremium),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen()));
            },
          ),
        ],
      );
    },
  );
}

/// A card to display the user's current premium status.
class PremiumStatusCard extends StatelessWidget {
  final DateTime? premiumUntil;

  const PremiumStatusCard({super.key, this.premiumUntil});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formattedDate = premiumUntil != null
        ? DateFormat.yMMMMd(l10n.localeName).format(premiumUntil!)
        : null;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.amber.shade700, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.amber.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Colors.amber.shade600, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.premiumStatusTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade200,
                        ),
                  ),
                  if (formattedDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.premiumStatusExpiresOn(formattedDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

