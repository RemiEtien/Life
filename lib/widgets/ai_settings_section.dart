import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../providers/application_providers.dart';
import '../services/user_service.dart';
import '../utils/safe_logger.dart';

/// AI Settings Section Widget for ProfileScreen
///
/// Displays granular AI feature controls with:
/// - Master AI enable switch with consent dialog
/// - Smart Prompts settings (FREE tier)
/// - Pattern Analysis settings (PREMIUM tier)
/// - Predictive Insights settings (PREMIUM tier)
/// - Privacy controls
class AISettingsSection extends ConsumerWidget {
  const AISettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        return _buildAISettingsContent(context, ref, profile);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAISettingsContent(BuildContext context, WidgetRef ref, UserProfile profile) {
    return ExpansionTile(
      title: const Text('AI Features'),
      subtitle: Text(
        profile.aiEnabled ? 'Enabled' : 'Disabled',
        style: TextStyle(
          color: profile.aiEnabled ? Colors.green : Colors.grey,
          fontSize: 12,
        ),
      ),
      leading: const Icon(Icons.auto_awesome),
      children: [
        // Master Switch
        SwitchListTile(
          title: const Text('Enable AI Features'),
          subtitle: const Text('AI analyzes your memories to find patterns'),
          value: profile.aiEnabled,
          onChanged: (value) {
            if (value && !profile.aiEnabled) {
              // First time activation - show consent dialog
              _showAIConsentDialog(context, ref, profile);
            } else {
              _updateProfile(ref, profile, {'aiEnabled': value});
            }
          },
        ),

        if (profile.aiEnabled) ...[
          const Divider(),

          // Smart Prompts (FREE)
          ListTile(
            title: Row(
              children: [
                const Text('Smart Prompts'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('FREE', style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ),
            subtitle: const Text('AI suggests questions while you write'),
          ),
          SwitchListTile(
            title: const Text('  Show in Memory Edit'),
            value: profile.aiSmartPromptsEnabled && profile.aiSmartPromptsInEdit,
            onChanged: profile.aiSmartPromptsEnabled
                ? (v) => _updateProfile(ref, profile, {'aiSmartPromptsInEdit': v})
                : null,
          ),

          const Divider(),

          // Pattern Analysis (PREMIUM)
          ListTile(
            title: Row(
              children: [
                const Text('Pattern Analysis'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('PREMIUM', style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ),
            subtitle: const Text('Weekly analysis of patterns and cycles'),
            trailing: !profile.isPremium
                ? TextButton(
                    onPressed: () => _showPremiumUpgrade(context),
                    child: const Text('Upgrade'),
                  )
                : null,
          ),
          if (profile.isPremium) ...[
            SwitchListTile(
              title: const Text('  Enable Pattern Analysis'),
              value: profile.aiPatternAnalysisEnabled,
              onChanged: (v) => _updateProfile(ref, profile, {'aiPatternAnalysisEnabled': v}),
            ),
            if (profile.aiPatternAnalysisEnabled) ...[
              SwitchListTile(
                title: const Text('    Show in Monthly View'),
                value: profile.aiPatternsInMonthlyView,
                onChanged: (v) => _updateProfile(ref, profile, {'aiPatternsInMonthlyView': v}),
              ),
              SwitchListTile(
                title: const Text('    Show in Memory View'),
                value: profile.aiPatternsInMemoryView,
                onChanged: (v) => _updateProfile(ref, profile, {'aiPatternsInMemoryView': v}),
              ),
              SwitchListTile(
                title: const Text('    Show in Memory List'),
                value: profile.aiPatternsInMemoryList,
                onChanged: (v) => _updateProfile(ref, profile, {'aiPatternsInMemoryList': v}),
              ),
            ],
          ],

          const Divider(),

          // Predictive Insights (PREMIUM)
          ListTile(
            title: Row(
              children: [
                const Text('Predictive Insights'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('PREMIUM', style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ),
            subtitle: const Text('AI predicts based on your history'),
            trailing: !profile.isPremium
                ? TextButton(
                    onPressed: () => _showPremiumUpgrade(context),
                    child: const Text('Upgrade'),
                  )
                : null,
          ),
          if (profile.isPremium) ...[
            SwitchListTile(
              title: const Text('  Enable Predictive Insights'),
              value: profile.aiPredictiveInsightsEnabled,
              onChanged: (v) => _updateProfile(ref, profile, {'aiPredictiveInsightsEnabled': v}),
            ),
            if (profile.aiPredictiveInsightsEnabled) ...[
              SwitchListTile(
                title: const Text('    Show in Memory Edit'),
                value: profile.aiPredictiveInEdit,
                onChanged: (v) => _updateProfile(ref, profile, {'aiPredictiveInEdit': v}),
              ),
              SwitchListTile(
                title: const Text('    Proactive Notifications'),
                subtitle: const Text('Get notified when AI sees a pattern'),
                value: profile.aiPredictiveNotifications,
                onChanged: (v) => _updateProfile(ref, profile, {'aiPredictiveNotifications': v}),
              ),
            ],
          ],

          const Divider(),

          // Privacy Control
          const ListTile(
            title: Text('Privacy'),
            subtitle: Text('Control what AI can access'),
          ),
          SwitchListTile(
            title: const Text('  Process Encrypted Memories'),
            subtitle: const Text('Allow AI to analyze encrypted content'),
            value: profile.aiProcessEncryptedMemories,
            onChanged: (v) {
              if (v) {
                _showEncryptedAIWarning(context, ref, profile);
              } else {
                _updateProfile(ref, profile, {'aiProcessEncryptedMemories': v});
              }
            },
          ),

          // Privacy info card
          const Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.privacy_tip, size: 16),
                      SizedBox(width: 8),
                      Text('AI Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Powered by Google Gemini AI\n'
                    '• Google does NOT store your data\n'
                    '• Encrypted memories stay encrypted by default\n'
                    '• You can disable AI anytime',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showAIConsentDialog(BuildContext context, WidgetRef ref, UserProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable AI Features?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI will analyze your memories to:'),
            SizedBox(height: 8),
            Text('• Suggest thoughtful questions'),
            Text('• Find recurring patterns'),
            Text('• Predict and help prevent negative cycles'),
            SizedBox(height: 16),
            Text('Privacy guarantee:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Powered by Google Gemini'),
            Text('• Your data is NOT stored by Google'),
            Text('• Encrypted memories stay encrypted'),
            Text('• You control what AI can see'),
            SizedBox(height: 16),
            Text(
              'You can disable AI anytime in Settings.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable AI'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateProfile(ref, profile, {'aiEnabled': true});
    }
  }

  void _showEncryptedAIWarning(BuildContext context, WidgetRef ref, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Encrypted Memories?'),
        content: const Text(
          'This will send your encrypted memories to Google Gemini AI for analysis.\n\n'
          'While Gemini does NOT store your data, this means your encrypted content '
          'will be temporarily processed by Google servers.\n\n'
          'Are you sure you want to enable this?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProfile(ref, profile, {'aiProcessEncryptedMemories': true});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showPremiumUpgrade(BuildContext context) {
    // TODO: Navigate to premium upgrade screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Premium features coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updateProfile(WidgetRef ref, UserProfile profile, Map<String, dynamic> updates) async {
    try {
      final userService = ref.read(userServiceProvider);

      // Create updated profile using copyWith
      UserProfile updatedProfile = profile;

      updates.forEach((key, value) {
        switch (key) {
          case 'aiEnabled':
            updatedProfile = updatedProfile.copyWith(aiEnabled: value as bool);
            break;
          case 'aiSmartPromptsEnabled':
            updatedProfile = updatedProfile.copyWith(aiSmartPromptsEnabled: value as bool);
            break;
          case 'aiSmartPromptsInEdit':
            updatedProfile = updatedProfile.copyWith(aiSmartPromptsInEdit: value as bool);
            break;
          case 'aiPatternAnalysisEnabled':
            updatedProfile = updatedProfile.copyWith(aiPatternAnalysisEnabled: value as bool);
            break;
          case 'aiPatternsInMonthlyView':
            updatedProfile = updatedProfile.copyWith(aiPatternsInMonthlyView: value as bool);
            break;
          case 'aiPatternsInMemoryView':
            updatedProfile = updatedProfile.copyWith(aiPatternsInMemoryView: value as bool);
            break;
          case 'aiPatternsInMemoryList':
            updatedProfile = updatedProfile.copyWith(aiPatternsInMemoryList: value as bool);
            break;
          case 'aiPredictiveInsightsEnabled':
            updatedProfile = updatedProfile.copyWith(aiPredictiveInsightsEnabled: value as bool);
            break;
          case 'aiPredictiveInEdit':
            updatedProfile = updatedProfile.copyWith(aiPredictiveInEdit: value as bool);
            break;
          case 'aiPredictiveNotifications':
            updatedProfile = updatedProfile.copyWith(aiPredictiveNotifications: value as bool);
            break;
          case 'aiProcessEncryptedMemories':
            updatedProfile = updatedProfile.copyWith(aiProcessEncryptedMemories: value as bool);
            break;
        }
      });

      await userService.updateUserProfile(updatedProfile);
      SafeLogger.debug('AI settings updated: $updates', tag: 'AISettingsSection');
    } catch (e, stackTrace) {
      SafeLogger.error('Failed to update AI settings', error: e, stackTrace: stackTrace, tag: 'AISettingsSection');
    }
  }
}
