import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline/widgets/premium_upsell_widgets.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/l10n/app_localizations.dart';

void main() {
  group('PremiumBannerCard Widget Tests', () {
    testWidgets('shows banner when user is not premium', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isPremiumProvider.overrideWith((ref) => false),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PremiumBannerCard()),
          ),
        ),
      );

      // Banner should be visible
      expect(find.byType(Card), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    });

    testWidgets('hides banner when user is premium', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isPremiumProvider.overrideWith((ref) => true),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PremiumBannerCard()),
          ),
        ),
      );

      // Banner should NOT be visible (renders SizedBox.shrink)
      expect(find.byType(Card), findsNothing);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('banner is tappable with InkWell', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isPremiumProvider.overrideWith((ref) => false),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PremiumBannerCard()),
          ),
        ),
      );

      // Banner should have InkWell for tapping
      expect(find.byType(InkWell), findsOneWidget);

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNotNull);
    });

    testWidgets('displays correct styling', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isPremiumProvider.overrideWith((ref) => false),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PremiumBannerCard()),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(4));
      expect(card.margin, equals(const EdgeInsets.symmetric(vertical: 16)));

      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.circular(12)));
    });
  });

  group('PremiumFeatureLockTile Widget Tests', () {
    testWidgets('displays icon and text correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumFeatureLockTile(
              icon: Icons.cloud_upload,
              text: 'Cloud Backup',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
      expect(find.text('Cloud Backup'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('shows lock icon in trailing position', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumFeatureLockTile(
              icon: Icons.edit,
              text: 'Edit Feature',
            ),
          ),
        ),
      );

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.leading, isA<Icon>());
      expect(listTile.trailing, isA<Icon>());

      final trailingIcon = listTile.trailing as Icon;
      expect(trailingIcon.icon, equals(Icons.lock_outline));
    });

    testWidgets('tile is tappable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumFeatureLockTile(
              icon: Icons.edit,
              text: 'Locked Feature',
            ),
          ),
        ),
      );

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.onTap, isNotNull);
    });

    testWidgets('displays greyed out style for disabled feature', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumFeatureLockTile(
              icon: Icons.star,
              text: 'Premium Only',
            ),
          ),
        ),
      );

      final leadingIcon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(leadingIcon.color, equals(Colors.grey));

      final text = tester.widget<Text>(find.text('Premium Only'));
      expect(text.style?.color, equals(Colors.grey));
    });
  });

  group('PremiumStatusCard Widget Tests', () {
    testWidgets('displays premium status with expiry date', (tester) async {
      final expiryDate = DateTime(2025, 12, 31);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PremiumStatusCard(premiumUntil: expiryDate),
          ),
        ),
      );

      expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
      // The formatted date should be visible
      expect(find.textContaining('December'), findsOneWidget);
      expect(find.textContaining('2025'), findsOneWidget);
    });

    testWidgets('displays premium status without date when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PremiumStatusCard(premiumUntil: null),
          ),
        ),
      );

      expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
      // No date text should be visible
      expect(find.textContaining('December'), findsNothing);
    });

    testWidgets('has correct styling with amber border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PremiumStatusCard(premiumUntil: null),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;

      expect(card.elevation, equals(4));
      expect(shape.side.width, equals(2));
      expect(shape.side.color, equals(Colors.amber.shade700));
      expect(shape.borderRadius, equals(BorderRadius.circular(12)));
    });

    testWidgets('displays premium icon in amber color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PremiumStatusCard(premiumUntil: null),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.workspace_premium_rounded));
      expect(icon.color, equals(Colors.amber.shade600));
      expect(icon.size, equals(40));
    });
  });

  group('showPremiumDialog Function Tests', () {
    testWidgets('displays dialog with correct content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox()),
        ),
      );

      final context = tester.element(find.byType(Scaffold));

      // Show the dialog
      showPremiumDialog(context, 'Cloud Sync');
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.byType(AlertDialog), findsOneWidget);
      // Feature name is embedded in localized string via l10n.premiumDialogContent(feature)
      expect(find.textContaining('Cloud Sync'), findsOneWidget);
    });

    testWidgets('has cancel and go premium buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox()),
        ),
      );

      final context = tester.element(find.byType(Scaffold));

      showPremiumDialog(context, 'Test Feature');
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('cancel button closes dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox()),
        ),
      );

      final context = tester.element(find.byType(Scaffold));

      showPremiumDialog(context, 'Feature');
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('go premium button has onPressed callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox()),
        ),
      );

      final context = tester.element(find.byType(Scaffold));

      showPremiumDialog(context, 'Feature');
      await tester.pumpAndSettle();

      // Go premium button should have an action
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });
  });
}
