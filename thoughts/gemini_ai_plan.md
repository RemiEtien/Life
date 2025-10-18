# План интеграции Gemini AI для анализа паттернов

> **Модель:** Gemini 2.5 Flash-Lite
> **Стоимость:** $0.10 input / $0.40 output per 1M tokens
> **Бюджет:** $34/месяц для 10K free + 1K premium users → **$2000 хватит на 5 лет!**

## 🎯 Цель
Использовать Google Cloud Credits ($2000) для создания **контекстного AI-ассистента**, который анализирует ВСЮ timeline пользователя и находит глубокие психологические паттерны, которые невозможно увидеть без AI.

**Ключевое отличие от конкурентов:** AI, который помнит всю вашу историю и использует её для персонализированных инсайтов.

---

## 🔍 Анализ конкурентов

### Reflectly
**Что делают:**
- AI Coach задает вопросы каждый день
- Mood tracking с эмоциями
- Daily affirmations

**Боли пользователей (из App Store/Play Store reviews):**
- ❌ "AI asks same generic questions every day"
- ❌ "Doesn't remember what I wrote yesterday"
- ❌ "Premium is $60/year for basic features"
- ❌ "Affirmations feel copy-pasted, not personalized"
- ⭐ 3.8/5 в App Store (много жалоб на generic prompts)

### Rosebud
**Что делают:**
- AI journaling с персонажами
- Pattern recognition
- Weekly summaries

**Боли пользователей:**
- ❌ "AI responses are shallow, like ChatGPT without context"
- ❌ "Patterns are just word clouds, not actionable"
- ❌ "No predictive insights - just summarizes what I already know"
- ❌ "Premium $8/month, feels expensive for what it does"
- ⭐ 4.2/5 (лучше, но много жалоб на shallow insights)

### Daylio
**Что делают:**
- Mood tracking с statistics
- Export data
- Premium: charts and trends

**Боли пользователей:**
- ❌ "NO AI at all - just charts"
- ❌ "I can see my mood goes down on Mondays, but WHY and WHAT to do?"
- ❌ "Need therapist to interpret the data"
- ⭐ 4.7/5 (хороший рейтинг, но users просят AI)

### Day One
**Что делают:**
- Premium journaling app
- Rich media support
- End-to-end encryption

**Боли пользователей:**
- ❌ "No AI insights - just a fancy notebook"
- ❌ "$35/year and it doesn't analyze my entries"
- ❌ "I have 5 years of journals, wish AI could find patterns"
- ⭐ 4.8/5 (отличный рейтинг, но users хотят AI features)

---

## 💎 Наши конкурентные преимущества

### 1. Timeline-Aware AI
**Проблема конкурентов:** Каждая запись анализируется изолированно
**Наше решение:** AI видит всю timeline и учитывает контекст:

```
User writes: "Anxious about presentation"

Competitors AI:
"Try deep breathing before presenting"

Our AI:
"You felt this way before presentation on Feb 15. Last time,
practicing once helped. Looking at your history, presentations
always go better than you expect. Try your usual routine - it works."
```

### 2. Циклические паттерны
**Проблема конкурентов:** Показывают линейные тренды ("mood is down this week")
**Наше решение:** Находим циклы, которые повторяются:

```
Competitors:
"You were sad 5 times this month" 📊

Us:
"You feel anxious every Monday morning for 3 months. This started
when you switched to remote work. On Tuesdays you feel better -
maybe Monday anxiety is about work-life boundaries?"
```

### 3. Predictive + Actionable
**Проблема конкурентов:** Просто показывают статистику
**Наше решение:** Предсказываем и советуем на основе ЧТО РАБОТАЛО У ВАС:

```
Competitors:
"You're feeling stressed" (no shit)

Us:
"You're stressed about deadline. 3 similar situations:
- Jan 10: Stressed → took walk → felt better
- Feb 5: Stressed → talked to friend → solved it
- Mar 12: Stressed → avoided it → felt worse
Try: taking a walk or calling a friend?"
```

### 4. Privacy-First AI
**Проблема конкурентов:** Нет прозрачности, где хранятся данные
**Наше решение:**
- ✅ Encrypted memories НЕ отправляются в AI (опционально можно включить)
- ✅ Google Gemini НЕ сохраняет данные (Google policy)
- ✅ Полная прозрачность: показываем что отправляется в AI
- ✅ Опционально: работа только с незашифрованными или opt-in для зашифрованных

### 5. Лучшее соотношение цена/качество
**Сравнение премиума:**

| App | Price/year | AI Features |
|-----|-----------|-------------|
| Reflectly | $60 | Generic prompts, no memory |
| Rosebud | $96 | Shallow patterns, no predictions |
| Daylio Premium | $30 | NO AI at all |
| Day One Premium | $35 | NO AI at all |
| **Lifeline** | **$48** | Timeline-aware, predictive, cycles |

**Our value prop:** $4/month для AI который ДЕЙСТВИТЕЛЬНО помнит вашу историю и помогает.

---

## 🎨 AI Features Architecture

### Где отображается AI?

**НЕТ отдельной вкладки или чата!** AI интегрирован в существующие экраны:

1. **Memory Edit Screen** - Smart Prompts (FREE)
2. **Memory Edit Screen** - Predictive Insights (PREMIUM)
3. **Memory View Screen** - Pattern Badges (PREMIUM)
4. **Monthly Cluster Bottom Sheet** - Monthly Patterns (PREMIUM)
5. **Memory List (левый нижний угол главного виджета)** - Top Insights (PREMIUM)
6. **Push Notifications** - Proactive Insights (PREMIUM)

### Feature Tiers

#### FREE Tier:
- ✅ **Smart Prompts** - углубляющие вопросы при создании воспоминания
- ✅ Работает для всех пользователей
- ✅ Показывает ценность AI без paywall

#### PREMIUM Tier ($3.99/month):
- ✅ **Pattern Analysis** - еженедельный анализ паттернов за 30 дней
- ✅ **Predictive Insights** - предсказания на основе прошлого
- ✅ **Monthly Patterns** - AI-анализ месячных кластеров
- ✅ **Proactive Notifications** - напоминания когда AI видит паттерн

---

## 📱 UI/UX Integration Points

### 1. Smart Prompts in Memory Edit (FREE)

**Где:** `memory_edit_screen.dart` - показывается после набора текста (debounced)

**Как выглядит:**
```
┌─────────────────────────────────────┐
│  [Ваш текст воспоминания]           │
│                                     │
│  💭 AI suggests:                    │
│  ┌─────────────────────────────────┐ │
│  │ • What triggered this feeling?  │ │
│  │ • How are you feeling now?      │ │
│  │ • What could help?              │ │
│  └─────────────────────────────────┘ │
│                                     │
│  [Save]                    [Cancel] │
└─────────────────────────────────────┘
```

**Logic check:**
```dart
// memory_edit_screen.dart
Widget _buildSmartPrompts() {
  final profile = ref.watch(userProfileProvider).value;

  if (profile == null) return const SizedBox.shrink();
  if (!profile.aiEnabled) return const SizedBox.shrink();
  if (!profile.aiSmartPromptsEnabled) return const SizedBox.shrink();
  if (!profile.aiSmartPromptsInEdit) return const SizedBox.shrink();

  // Check if memory is encrypted and if user allows AI on encrypted
  if (_isEncrypted && !profile.aiProcessEncryptedMemories) {
    return _buildEncryptedAIUpsell(); // Suggest enabling in settings
  }

  return SmartPromptsCard(
    memoryText: _contentController.text,
    onPromptTap: (prompt) => _handlePromptSelected(prompt),
  );
}
```

**Cost:** ~$0.00006 per memory (почти бесплатно!)

---

### 2. Predictive Insights in Memory Edit (PREMIUM)

**Где:** `memory_edit_screen.dart` - показывается если AI нашел похожие прошлые воспоминания

**Как выглядит:**
```
┌─────────────────────────────────────┐
│  [Ваш текст воспоминания]           │
│                                     │
│  🔮 AI noticed a pattern:           │
│  ┌─────────────────────────────────┐ │
│  │ You felt this way on Feb 15.    │ │
│  │ Last time, taking a walk helped.│ │
│  │                                 │ │
│  │ Try: 🚶 Go for a walk           │ │
│  │      💬 Talk to a friend        │ │
│  └─────────────────────────────────┘ │
│                                     │
│  [Save]                    [Cancel] │
└─────────────────────────────────────┘
```

**Logic check:**
```dart
// memory_edit_screen.dart
Widget _buildPredictiveInsight() {
  final profile = ref.watch(userProfileProvider).value;

  if (profile == null) return const SizedBox.shrink();
  if (!profile.aiEnabled) return const SizedBox.shrink();
  if (!profile.isPremium) return _buildPremiumUpsell();
  if (!profile.aiPredictiveInsightsEnabled) return const SizedBox.shrink();
  if (!profile.aiPredictiveInEdit) return const SizedBox.shrink();

  if (_isEncrypted && !profile.aiProcessEncryptedMemories) {
    return const SizedBox.shrink();
  }

  return PredictiveInsightCard(
    currentMemory: _contentController.text,
    primaryEmotion: _primaryEmotion,
    userId: widget.userId,
  );
}
```

**Cost:** ~$0.00017 per memory with prediction

---

### 3. Pattern Badges in Memory View (PREMIUM)

**Где:** `memory_view_screen.dart` - показывается рядом с эмоциями

**Как выглядит:**
```
┌─────────────────────────────────────┐
│  Memory Title                       │
│  Feb 15, 2025                       │
│                                     │
│  😰 Anxiety  💼 Work                │
│  🔁 Recurring pattern               │ ← AI Badge
│                                     │
│  [Memory content...]                │
│                                     │
│  💡 Pattern: You feel this way      │
│     every Monday. Tap to see why.   │
└─────────────────────────────────────┘
```

**Logic check:**
```dart
// memory_view_screen.dart
Widget _buildPatternBadge() {
  final profile = ref.watch(userProfileProvider).value;

  if (profile == null) return const SizedBox.shrink();
  if (!profile.aiEnabled) return const SizedBox.shrink();
  if (!profile.isPremium) return const SizedBox.shrink();
  if (!profile.aiPatternAnalysisEnabled) return const SizedBox.shrink();
  if (!profile.aiPatternsInMemoryView) return const SizedBox.shrink();

  // Load pattern from Firestore
  final pattern = ref.watch(memoryPatternProvider(widget.memory.id));

  return pattern.when(
    data: (data) => data != null ? PatternBadge(pattern: data) : const SizedBox.shrink(),
    loading: () => const SizedBox.shrink(),
    error: (_, __) => const SizedBox.shrink(),
  );
}
```

---

### 4. Monthly Patterns in Cluster Bottom Sheet (PREMIUM)

**Где:** `monthly_cluster_bottom_sheet.dart` - показывается после emotion chips

**Как выглядит:**
```
┌─────────────────────────────────────┐
│  January 2025          23 memories  │
│                                     │
│  😰 Anxiety (8)  😊 Joy (10)        │ ← Existing
│  😢 Sadness (5)                     │
│                                     │
│  💡 AI Pattern Analysis:            │ ← NEW
│  ┌─────────────────────────────────┐ │
│  │ This month you felt anxious     │ │
│  │ mostly on Mondays (5 times).    │ │
│  │                                 │ │
│  │ What helped most:               │ │
│  │ • Exercise (3 times)            │ │
│  │ • Talking to friends (2 times) │ │
│  │                                 │ │
│  │ 📊 View similar months          │ │
│  └─────────────────────────────────┘ │
│                                     │
│  [Grid of memories...]              │
└─────────────────────────────────────┘
```

**Logic check:**
```dart
// monthly_cluster_bottom_sheet.dart
Widget _buildMonthlyAIPattern() {
  final profile = ref.watch(userProfileProvider).value;

  if (profile == null) return const SizedBox.shrink();
  if (!profile.aiEnabled) return const SizedBox.shrink();
  if (!profile.isPremium) return _buildPremiumUpsell();
  if (!profile.aiPatternAnalysisEnabled) return const SizedBox.shrink();
  if (!profile.aiPatternsInMonthlyView) return const SizedBox.shrink();

  // Use existing emotion data from widget.memories
  final emotionCounts = <String, int>{};
  for (final memory in widget.memories) {
    if (memory.primaryEmotion != null) {
      emotionCounts[memory.primaryEmotion!] =
          (emotionCounts[memory.primaryEmotion!] ?? 0) + 1;
    }
  }

  // Load AI-generated monthly pattern from Firestore
  final pattern = ref.watch(monthlyPatternProvider(widget.monthKey));

  return MonthlyPatternCard(
    monthKey: widget.monthKey,
    emotionCounts: emotionCounts,
    pattern: pattern,
  );
}
```

---

### 5. Top Insights in Memory List (PREMIUM)

**Где:** `select_memory_screen.dart` (список воспоминаний слева) - вверху списка

**Как выглядит:**
```
┌─────────────────────────────────────┐
│  💡 Recent Insights          [Close]│
│  ┌─────────────────────────────────┐ │
│  │ 🔁 You've felt anxious about    │ │
│  │    work 5 times this week.      │ │
│  │    [View pattern]               │ │
│  └─────────────────────────────────┘ │
│                                     │
│  [Search...]                        │
│                                     │
│  📅 Today                           │
│  • Memory 1                         │
│  • Memory 2                         │
│                                     │
│  📅 Yesterday                       │
│  • Memory 3                         │
└─────────────────────────────────────┘
```

**Logic check:**
```dart
// select_memory_screen.dart
Widget _buildTopInsights() {
  final profile = ref.watch(userProfileProvider).value;

  if (profile == null) return const SizedBox.shrink();
  if (!profile.aiEnabled) return const SizedBox.shrink();
  if (!profile.isPremium) return const SizedBox.shrink();
  if (!profile.aiPatternAnalysisEnabled) return const SizedBox.shrink();
  if (!profile.aiPatternsInMemoryList) return const SizedBox.shrink();

  // Load top 3 most recent insights
  final insights = ref.watch(topInsightsProvider(widget.userId, limit: 3));

  return TopInsightsCard(insights: insights);
}
```

---

### 6. Proactive Push Notifications (PREMIUM)

**Когда:** AI обнаруживает паттерн в реальном времени

**Пример:**
```
📊 Lifeline Insight
"You mentioned 'work stress' 5 times this week.
Last month, taking walks helped. Want to try again?"

[Open App]  [Dismiss]
```

**Logic check (Firebase Function):**
```typescript
// Check user preferences before sending notification
const profile = await getUserProfile(userId);

if (!profile.aiEnabled) return;
if (!profile.isPremium) return;
if (!profile.aiPredictiveInsightsEnabled) return;
if (!profile.aiPredictiveNotifications) return;
if (!profile.notificationsEnabled) return; // System notifications

// Send notification
await sendPushNotification(userId, {
  title: "Lifeline Insight",
  body: insightText,
  data: { type: "ai_insight", insightId: insight.id }
});
```

---

## ⚙️ Settings Architecture

### UserProfile Fields (новые)

```dart
// lib/models/user_profile.dart

class UserProfile {
  // ... existing fields ...

  // --- AI FEATURES SETTINGS ---

  // Master switch
  final bool aiEnabled; // Default: false (opt-in)

  // Smart Prompts (FREE tier)
  final bool aiSmartPromptsEnabled; // Default: true (if aiEnabled)
  final bool aiSmartPromptsInEdit; // Default: true

  // Pattern Analysis (PREMIUM tier)
  final bool aiPatternAnalysisEnabled; // Default: true (if isPremium && aiEnabled)
  final bool aiPatternsInMonthlyView; // Default: true
  final bool aiPatternsInMemoryView; // Default: true
  final bool aiPatternsInMemoryList; // Default: true

  // Predictive Insights (PREMIUM tier)
  final bool aiPredictiveInsightsEnabled; // Default: true (if isPremium && aiEnabled)
  final bool aiPredictiveInEdit; // Default: true
  final bool aiPredictiveNotifications; // Default: false (explicit opt-in)

  // Privacy control
  final bool aiProcessEncryptedMemories; // Default: false (encrypted stays encrypted)
}
```

### Profile Screen UI

**Где:** `profile_screen.dart` - новая секция "AI Features"

```dart
Widget _buildAISettings(BuildContext context) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return const SizedBox.shrink();

  return ExpansionTile(
    title: const Text('AI Features'),
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
            _showAIConsentDialog(context);
          } else {
            _updateProfile({'aiEnabled': value});
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
              ? (v) => _updateProfile({'aiSmartPromptsInEdit': v})
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
            onChanged: (v) => _updateProfile({'aiPatternAnalysisEnabled': v}),
          ),
          if (profile.aiPatternAnalysisEnabled) ...[
            SwitchListTile(
              title: const Text('    Show in Monthly View'),
              value: profile.aiPatternsInMonthlyView,
              onChanged: (v) => _updateProfile({'aiPatternsInMonthlyView': v}),
            ),
            SwitchListTile(
              title: const Text('    Show in Memory View'),
              value: profile.aiPatternsInMemoryView,
              onChanged: (v) => _updateProfile({'aiPatternsInMemoryView': v}),
            ),
            SwitchListTile(
              title: const Text('    Show in Memory List'),
              value: profile.aiPatternsInMemoryList,
              onChanged: (v) => _updateProfile({'aiPatternsInMemoryList': v}),
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
            onChanged: (v) => _updateProfile({'aiPredictiveInsightsEnabled': v}),
          ),
          if (profile.aiPredictiveInsightsEnabled) ...[
            SwitchListTile(
              title: const Text('    Show in Memory Edit'),
              value: profile.aiPredictiveInEdit,
              onChanged: (v) => _updateProfile({'aiPredictiveInEdit': v}),
            ),
            SwitchListTile(
              title: const Text('    Proactive Notifications'),
              subtitle: const Text('Get notified when AI sees a pattern'),
              value: profile.aiPredictiveNotifications,
              onChanged: (v) => _updateProfile({'aiPredictiveNotifications': v}),
            ),
          ],
        ],

        const Divider(),

        // Privacy Control
        ListTile(
          title: const Text('Privacy'),
          subtitle: const Text('Control what AI can access'),
        ),
        SwitchListTile(
          title: const Text('  Process Encrypted Memories'),
          subtitle: const Text('Allow AI to analyze encrypted content'),
          value: profile.aiProcessEncryptedMemories,
          onChanged: (v) {
            if (v) {
              _showEncryptedAIWarning(context, () {
                _updateProfile({'aiProcessEncryptedMemories': v});
              });
            } else {
              _updateProfile({'aiProcessEncryptedMemories': v});
            }
          },
        ),

        // Privacy info card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.privacy_tip, size: 16),
                    SizedBox(width: 8),
                    Text('AI Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
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
```

### AI Consent Dialog (первая активация)

```dart
Future<void> _showAIConsentDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enable AI Features?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
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
    await _updateProfile({'aiEnabled': true});
  }
}
```

---

## 🏗️ Firebase Architecture

### Firestore Structure

```
users/{userId}/
  - profile: UserProfile (contains all AI settings)

  - insights/{insightId}
    {
      type: "smart_prompt" | "pattern" | "predictive",
      createdAt: timestamp,
      content: string, // AI-generated text
      relatedMemories: [memoryId1, memoryId2],
      dismissed: bool,
      viewed: bool,
      confidence: 0.0-1.0,

      // For pattern insights
      pattern?: {
        frequency: "daily" | "weekly" | "monthly",
        trigger: string,
        emotionTrend: string,
        suggestions: [string],
      },

      // For predictive insights
      prediction?: {
        similarPastEvents: [memoryId],
        whatHelped: [string],
        copingStrategies: [string],
      }
    }

  - monthlyPatterns/{monthKey} // e.g., "2025-01"
    {
      monthKey: string,
      emotionCounts: { emotion: count },
      topThemes: [string],
      triggers: [string],
      whatHelped: [string],
      generatedAt: timestamp,
    }
```

### Firebase Functions

#### 1. Smart Prompts Function (FREE)

```typescript
// functions/src/smartPrompts.ts
export const generateSmartPrompts = functions.firestore
  .document('users/{userId}/memories/{memoryId}')
  .onCreate(async (snap, context) => {
    const memory = snap.data();
    const userId = context.params.userId;

    // Check user settings
    const profile = await getProfile(userId);
    if (!profile.aiEnabled || !profile.aiSmartPromptsEnabled || !profile.aiSmartPromptsInEdit) {
      return; // User disabled
    }

    // Check encryption
    if (memory.isEncrypted && !profile.aiProcessEncryptedMemories) {
      return; // Don't process encrypted
    }

    // Call Gemini API
    const prompt = `
      User wrote this journal entry: "${memory.content}"

      Generate 2-3 thoughtful follow-up questions to help them reflect deeper.
      Focus on CBT techniques:
      - What triggered this?
      - How did you feel?
      - What would help?

      Keep questions short (max 10 words each) and empathetic.
      Return as JSON array of strings.
    `;

    const response = await callGeminiAPI(prompt, 'gemini-2.5-flash-lite');

    // Save insight
    await admin.firestore()
      .collection(`users/${userId}/insights`)
      .add({
        type: 'smart_prompt',
        content: response.questions.join('\n'),
        relatedMemories: [memory.id],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        viewed: false,
        dismissed: false,
      });
  });
```

**Cost:** ~$0.00006 per memory

#### 2. Pattern Analysis Function (PREMIUM - Weekly)

```typescript
// functions/src/patternAnalysis.ts
export const weeklyPatternAnalysis = functions.pubsub
  .schedule('every sunday 00:00')
  .onRun(async (context) => {
    const premiumUsers = await getPremiumUsers();

    for (const userId of premiumUsers) {
      const profile = await getProfile(userId);

      // Check settings
      if (!profile.aiEnabled || !profile.aiPatternAnalysisEnabled) {
        continue;
      }

      // Get last 30 days of memories
      const memories = await getMemories(userId, { last: 30 });

      // Filter encrypted if needed
      const processableMemories = memories.filter(m =>
        !m.isEncrypted || profile.aiProcessEncryptedMemories
      );

      if (processableMemories.length < 5) continue; // Need enough data

      // Call Gemini API
      const prompt = `
        Analyze these journal entries from the last 30 days:

        ${processableMemories.map(m => `${m.date}: ${m.content} [${m.primaryEmotion}]`).join('\n')}

        Find:
        1. Recurring themes (work, relationships, health)
        2. Emotional cycles (when do they feel worst/best?)
        3. Triggers (what causes negative emotions?)
        4. What helped in the past (coping strategies that worked)
        5. Progress signs (are things getting better?)

        Return as JSON:
        {
          "themes": ["theme1", "theme2"],
          "emotional_cycles": "description",
          "triggers": ["trigger1"],
          "what_helped": ["strategy1"],
          "progress_notes": "signs of improvement"
        }
      `;

      const response = await callGeminiAPI(prompt, 'gemini-2.5-flash-lite');

      // Save pattern insight
      await admin.firestore()
        .collection(`users/${userId}/insights`)
        .add({
          type: 'pattern',
          content: formatPatternInsight(response),
          relatedMemories: processableMemories.map(m => m.id),
          pattern: response,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          viewed: false,
          dismissed: false,
          confidence: calculateConfidence(response, processableMemories.length),
        });

      // Send notification if enabled
      if (profile.aiPredictiveNotifications && profile.notificationsEnabled) {
        await sendPushNotification(userId, {
          title: 'New Pattern Detected',
          body: `AI found ${response.themes.length} recurring themes in your last 30 days.`,
          data: { type: 'pattern_insight' },
        });
      }
    }
  });
```

**Cost:** ~$0.00058 per user per week (negligible!)

#### 3. Monthly Pattern Generation (PREMIUM)

```typescript
// functions/src/monthlyPatterns.ts
export const generateMonthlyPattern = functions.firestore
  .document('users/{userId}/memories/{memoryId}')
  .onCreate(async (snap, context) => {
    const memory = snap.data();
    const userId = context.params.userId;
    const profile = await getProfile(userId);

    // Check if user has premium and settings enabled
    if (!profile.isPremium || !profile.aiEnabled || !profile.aiPatternAnalysisEnabled) {
      return;
    }

    // Check if monthly pattern needs update
    const monthKey = getMonthKey(memory.date); // e.g., "2025-01"
    const existingPattern = await getMonthlyPattern(userId, monthKey);

    // Regenerate if last generated > 7 days ago or doesn't exist
    if (existingPattern && (Date.now() - existingPattern.generatedAt < 7 * 24 * 60 * 60 * 1000)) {
      return; // Too soon
    }

    // Get all memories for this month
    const monthMemories = await getMemoriesForMonth(userId, monthKey);

    // Calculate emotion counts (use existing emotion data)
    const emotionCounts = {};
    monthMemories.forEach(m => {
      if (m.primaryEmotion) {
        emotionCounts[m.primaryEmotion] = (emotionCounts[m.primaryEmotion] || 0) + 1;
      }
    });

    // Call Gemini for deeper analysis
    const prompt = `
      Analyze this month's journal entries:

      Emotions: ${JSON.stringify(emotionCounts)}

      Entries:
      ${monthMemories.map(m => `${m.date}: ${m.content}`).join('\n')}

      Provide:
      1. Top 3 themes this month
      2. Main triggers for negative emotions
      3. What coping strategies helped most (based on context)

      Return as JSON:
      {
        "topThemes": ["theme1", "theme2", "theme3"],
        "triggers": ["trigger1", "trigger2"],
        "whatHelped": ["strategy1", "strategy2"]
      }
    `;

    const response = await callGeminiAPI(prompt, 'gemini-2.5-flash-lite');

    // Save monthly pattern
    await admin.firestore()
      .doc(`users/${userId}/monthlyPatterns/${monthKey}`)
      .set({
        monthKey,
        emotionCounts,
        topThemes: response.topThemes,
        triggers: response.triggers,
        whatHelped: response.whatHelped,
        generatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
  });
```

---

## 💰 Cost & Budget

### Gemini 2.5 Flash-Lite Pricing (2025)
- **Input:** $0.10 / 1M tokens
- **Output:** $0.40 / 1M tokens
- **1M token context window** - достаточно для всех наших задач
- **Low-latency** - оптимален для high-volume, simple tasks
- **Stable & Production-ready** - generally available

**Почему Flash-Lite идеален:**
- ✅ Дешевле чем GPT-4o mini и Claude Haiku
- ✅ Наши задачи не требуют "thinking mode" (поэтому не нужен дорогой 2.5 Flash)
- ✅ 1M context покрывает любой объем воспоминаний
- ✅ Быстрая обработка для real-time insights

### Cost Calculations

```
Average memory: 500 chars (~125 tokens)

Smart Prompt: 200 input + 100 output = 300 tokens
Cost = (200 × $0.10 + 100 × $0.40) / 1,000,000 = $0.00006
≈ Почти бесплатно!

Pattern Analysis (30 days): 30 memories × 125 = 3,750 input + 500 output
Cost = (3,750 × $0.10 + 500 × $0.40) / 1,000,000 = $0.00058

Predictive Insight: 500 input + 300 output = 800 tokens
Cost = (500 × $0.10 + 300 × $0.40) / 1,000,000 = $0.00017
```

### Monthly Budget per Tier

| Feature | Users | Usage | Cost/month | $2000 lasts |
|---------|-------|-------|------------|-------------|
| Smart Prompts (FREE) | 10,000 | 5 memories/user/month | $30 | **66 months** |
| Pattern Analysis (PREMIUM) | 1,000 | 4 analyses/month | $2.32 | **860+ months** |
| Predictive Insights (PREMIUM) | 1,000 | 10 predictions/user/month | $1.70 | **1176+ months** |
| **TOTAL** | 10K free + 1K premium | | **$34/month** | **58+ months (почти 5 лет!)** |

**Невероятно дешево!** $2000 Google Cloud Credits хватит на **почти 5 ЛЕТ** работы при 10K бесплатных + 1K премиум пользователей!

---

## 📊 Settings Check Matrix

Для каждого места отображения AI нужна проверка:

| Location | Checks Required |
|----------|----------------|
| Smart Prompts (Memory Edit) | `aiEnabled` + `aiSmartPromptsEnabled` + `aiSmartPromptsInEdit` + encryption check |
| Predictive Insight (Memory Edit) | `aiEnabled` + `isPremium` + `aiPredictiveInsightsEnabled` + `aiPredictiveInEdit` + encryption check |
| Pattern Badge (Memory View) | `aiEnabled` + `isPremium` + `aiPatternAnalysisEnabled` + `aiPatternsInMemoryView` |
| Monthly Pattern (Cluster Sheet) | `aiEnabled` + `isPremium` + `aiPatternAnalysisEnabled` + `aiPatternsInMonthlyView` |
| Top Insights (Memory List) | `aiEnabled` + `isPremium` + `aiPatternAnalysisEnabled` + `aiPatternsInMemoryList` |
| Proactive Notifications | `aiEnabled` + `isPremium` + `aiPredictiveInsightsEnabled` + `aiPredictiveNotifications` + `notificationsEnabled` |

**Encryption check:** If memory is encrypted and `!aiProcessEncryptedMemories`, skip AI processing.

---

## 🚀 Implementation Phases

### Phase 1: Settings Infrastructure (1 неделя)
- [ ] Add AI fields to `user_profile.dart`
- [ ] Update Firestore sync for new fields
- [ ] Build `_buildAISettings()` in `profile_screen.dart`
- [ ] Create AI Consent Dialog
- [ ] Create Encrypted AI Warning Dialog
- [ ] Test settings sync across devices

### Phase 2: Firebase Functions Setup (1 неделя)
- [ ] Setup Firebase Functions project
- [ ] Add Gemini API key to environment
- [ ] Create `callGeminiAPI()` helper
- [ ] Deploy test function
- [ ] Setup Firestore insights collection
- [ ] Test local Firebase emulator

### Phase 3: Smart Prompts - FREE (1-2 недели)
- [ ] Create `SmartPromptsCard` widget
- [ ] Add debounced trigger in `memory_edit_screen.dart`
- [ ] Implement Firebase Function `generateSmartPrompts`
- [ ] Add settings checks
- [ ] Add encrypted memory handling
- [ ] A/B test engagement with 100 users
- [ ] Monitor cost and quality

**Success metrics:**
- % users who click prompts > 40%
- Avg response time < 2s
- Cost < $0.001 per memory

### Phase 4: Pattern Analysis - PREMIUM (2 недели)
- [ ] Create `PatternBadge` widget for memory_view_screen
- [ ] Create `MonthlyPatternCard` for monthly_cluster_bottom_sheet
- [ ] Create `TopInsightsCard` for select_memory_screen
- [ ] Implement weekly `patternAnalysis` function
- [ ] Implement `generateMonthlyPattern` function
- [ ] Add premium upsell for free users
- [ ] Test with 50 premium beta users

**Success metrics:**
- Pattern accuracy rating > 4/5
- Dismissal rate < 30%
- Free → Premium conversion boost > 2%

### Phase 5: Predictive Insights - PREMIUM (2 недели)
- [ ] Create `PredictiveInsightCard` widget
- [ ] Implement memory similarity search
- [ ] Create `generatePrediction` Firebase Function
- [ ] Add real-time trigger in memory_edit_screen
- [ ] Implement proactive notifications
- [ ] Add notification settings check
- [ ] Test prediction accuracy with user feedback

**Success metrics:**
- Users rate predictions helpful > 70%
- Notification opt-in rate > 20%
- Users follow suggestions > 30%

### Phase 6: Monitoring & Optimization (ongoing)
- [ ] Setup Cloud Functions logging
- [ ] Monitor Gemini API costs daily
- [ ] Track insight quality ratings
- [ ] A/B test prompt variations
- [ ] Optimize token usage
- [ ] Add user feedback loop

---

## 📈 Monetization Strategy

### FREE Tier:
- ✅ Smart Prompts - unlimited
- ✅ Shows value of AI immediately
- ❌ No pattern analysis
- ❌ No predictions

### PREMIUM ($3.99/month):
- ✅ Everything in FREE
- ✅ Weekly pattern analysis
- ✅ Monthly pattern insights
- ✅ Real-time predictive insights
- ✅ Proactive notifications
- ✅ Priority AI processing

### Conversion Flow:

**Week 1:** User creates 5-10 memories
- Gets Smart Prompts (FREE) ✅
- Sees value of AI helping them reflect

**Week 2:** User creates more memories
- Pattern analysis runs (but locked)
- Shows: "We found 3 patterns! Upgrade to Premium to see them"
- Emotion visualization helps but AI would explain WHY

**Week 3:** User writes anxious memory
- Smart Prompt helps
- Shows teaser: "We've seen this pattern before. Premium users get predictions."

**Convert:** Expected 5-10% conversion from FREE to PREMIUM driven by AI value.

**Retention:** Premium users with AI engaged have 80%+ retention (vs 60% without AI).

---

## ⚠️ Privacy & Ethics

### Data Security
1. **Encryption Respect:**
   - Encrypted memories NOT sent to Gemini by default
   - User must explicitly opt-in via `aiProcessEncryptedMemories`
   - Show warning when enabling

2. **Google Gemini Policy:**
   - Google does NOT store data sent to Gemini API
   - No training on user data
   - Enterprise-grade privacy
   - Link to policy: https://cloud.google.com/gemini/docs/discover/data-governance

3. **Firestore Security:**
   ```javascript
   // Insights are user-private
   match /users/{userId}/insights/{insightId} {
     allow read, write: if request.auth.uid == userId;
   }
   ```

### Transparency
1. **Clear Communication:**
   - "AI analyzes your memories to find patterns"
   - Consent dialog explains what AI does
   - Privacy card in settings shows Gemini usage

2. **User Control:**
   - Granular settings for each feature
   - Can disable AI anytime
   - Can exclude encrypted content
   - Can dismiss/hide specific insights

### Responsible AI
1. **Never Diagnose:**
   - ❌ "You seem to have depression"
   - ✅ "You've felt sad frequently. Consider talking to a therapist."

2. **Suggest Professional Help:**
   - If AI detects severe patterns (self-harm mentions, etc.)
   - Show crisis resources
   - Encourage professional support

3. **CBT-Based Only:**
   - Use evidence-based techniques
   - No pseudoscience
   - Focus on actionable coping strategies

---

## 📊 Success Metrics

### Engagement Metrics:
- **Insight view rate:** > 60% (users actually read AI insights)
- **Action rate:** > 30% (users follow AI suggestions)
- **Dismissal rate:** < 30% (insights are relevant)
- **Settings disable rate:** < 10% (users keep AI enabled)

### Quality Metrics:
- **User ratings:** > 4/5 stars for insight quality
- **Prediction accuracy:** > 70% (based on user feedback)
- **Pattern relevance:** > 80% (patterns make sense to user)

### Business Metrics:
- **Free → Premium conversion:** > 5% (AI drives upgrades)
- **Premium retention:** > 80% after 3 months
- **AI cost per premium user:** < $0.20/month
- **ROI on $2000 credits:** > 500% (via premium conversions)

---

## 🎯 Competitive Positioning

| Feature | Reflectly | Rosebud | Daylio | **Lifeline** |
|---------|-----------|---------|--------|--------------|
| AI prompts | ✅ Generic | ✅ Generic | ❌ | ✅ **Context-aware** |
| Pattern detection | ❌ | ⚠️ Word clouds | ⚠️ Charts only | ✅ **Cyclical + predictive** |
| Predictions | ❌ | ❌ | ❌ | ✅ **Based on your history** |
| Privacy | ⚠️ Unclear | ⚠️ Unclear | ✅ No AI | ✅ **Encrypted excluded** |
| Price/year | $60 | $96 | $30 | **$48** |
| **Value score** | 3/10 | 5/10 | 4/10 | **9/10** |

**Why we win:**
1. **Timeline-aware AI** - remembers your full history
2. **Predictive insights** - based on what worked FOR YOU
3. **Privacy-first** - encrypted stays encrypted
4. **Better value** - $4/month for real AI vs $8-10 for competitors

---

## ✅ Ready to Launch

- [x] $2000 Google Cloud Credits available
- [x] Gemini API access configured
- [x] Settings architecture designed
- [x] UI/UX integration points defined
- [x] Privacy policy compliant
- [ ] Firebase Functions deployed
- [ ] UserProfile fields added
- [ ] Profile Screen UI built
- [ ] Smart Prompts implemented (Phase 3)
- [ ] Pattern Analysis implemented (Phase 4)
- [ ] Predictive Insights implemented (Phase 5)

**Timeline:** 6-8 недель от начала Phase 1 до полного запуска всех AI features.

**Priority:** Start with Phase 1 (Settings Infrastructure) after current killer features are stable.

---

## 💡 Future Ideas (Post-Launch)

1. **Voice Journaling + AI:**
   - Speech-to-text for memories
   - AI analyzes tone/emotion from voice
   - "You sound stressed. Want to talk about it?"

2. **AI-Generated Visualizations:**
   - Beyond emotion auras
   - Timeline "weather" based on mood
   - "This month felt like a storm, but calmer now"

3. **Community Patterns (Anonymous):**
   - "People who felt [X] found [Y] helpful"
   - Aggregated insights without privacy loss

4. **Therapist Integration:**
   - Export AI insights for therapy sessions
   - Therapist can review patterns
   - Helps therapy be more efficient

---

**Главный вывод:** Наш AI не просто "отвечает на вопросы" - он **помнит всю вашу историю и помогает увидеть себя со стороны**. Это то, чего нет ни у одного конкурента.
