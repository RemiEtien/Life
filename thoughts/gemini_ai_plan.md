# План интеграции Gemini AI для анализа паттернов

## 🎯 Цель
Использовать Google Cloud Credits ($2000) для создания контекстного AI который анализирует ВСЮ timeline и находит глубокие паттерны.

## 💡 Киллер-фича

**Проблема конкурентов:**
- Generic prompts: "How do you feel today?"
- AI не помнит историю
- Поверхностные insights

**Наше решение:**
- AI анализирует всю timeline (все воспоминания)
- Находит циклические паттерны
- Предсказывает триггеры
- CBT-based вопросы на основе истории

## 💰 Бюджет и стоимость

### Gemini 1.5 Flash (оптимальный выбор)
- Input: $0.075 / 1M tokens
- Output: $0.30 / 1M tokens
- **2x дешевле** чем GPT-4o mini

### Расчеты:
```
Среднее воспоминание: 500 chars (~125 tokens)
Insight generation: 200 tokens prompt + 300 tokens response = 500 tokens
Стоимость 1 insight: $0.000125 (почти бесплатно!)

$2000 = ~16 МИЛЛИОНОВ insights 🤯
```

### Реальный бюджет на пользователя:

| Feature | Users | Cost/month | $2000 lasts |
|---------|-------|------------|-------------|
| Smart Prompts (Free) | 10,000 | $40 | 50 months |
| Pattern Analysis (Premium) | 1,000 | $43 | 46 months |
| Predictive Insights (Premium) | 1,000 | $150 | 13 months |
| **TOTAL** | 10K free + 1K premium | $233/month | **8.5 months** |

## 🎨 Типы AI Insights

### 1. Smart Prompts (FREE tier)
**Когда:** При создании нового воспоминания
**Что делает:** Задает углубляющие вопросы

```dart
// Пример
User writes: "Had a fight with mom today"

AI Prompt:
"""
User just wrote this journal entry: "Had a fight with mom today"

Generate 2-3 thoughtful follow-up questions to help them reflect deeper.
Focus on CBT techniques:
- What triggered this?
- How did you feel?
- What would help?

Keep questions short and empathetic.
"""

AI Response:
"What triggered the fight? How are you feeling now? What could help mend this?"
```

**Cost:** ~$0.0002 per memory (negligible)

---

### 2. Pattern Analysis (PREMIUM - Weekly)
**Когда:** Раз в неделю batch analysis
**Что делает:** Анализирует последние 30 дней, находит паттерны

```dart
// Пример
final memories = getUserMemories(userId, last30days);

AI Prompt:
"""
You are a therapist AI analyzing journal entries.

Journal entries from the last 30 days:
${memories.map((m) => '${m.date}: ${m.content}').join('\n')}

Analyze and find:
1. **Recurring themes** - what topics appear frequently?
2. **Emotional cycles** - are there patterns in mood?
3. **Triggers** - what situations cause negative emotions?
4. **People/places** - who/where affects mood most?
5. **Progress** - any signs of healing or growth?

Format response as JSON:
{
  "themes": ["theme1", "theme2"],
  "emotional_cycles": "description",
  "triggers": ["trigger1"],
  "key_relationships": ["person1: positive/negative"],
  "progress_notes": "healing signs"
}
"""

AI Response:
{
  "themes": ["work stress", "relationship with mother"],
  "emotional_cycles": "Anxiety peaks on Mondays, better on weekends",
  "triggers": ["confrontation", "feeling unheard"],
  "key_relationships": ["mom: complex, improving", "friend Sarah: positive"],
  "progress_notes": "Using more coping strategies, less catastrophizing"
}
```

**Cost:** ~$0.01 per user per week
**Хранение:** Save в Firestore как `UserInsight` document

---

### 3. Predictive Insights (PREMIUM - Real-time)
**Когда:** При создании нового воспоминания
**Что делает:** Сравнивает с прошлым, предсказывает и советует

```dart
// Пример
New memory: "Feeling anxious about work presentation tomorrow"
Past similar: getUserSimilarMemories(userId, "anxiety", "work")

AI Prompt:
"""
You are a CBT therapist providing evidence-based insights.

**Current situation:**
User just wrote: "Feeling anxious about work presentation tomorrow"

**Past similar events:**
- 2024-03-15: "Anxious about meeting. It went fine."
- 2024-02-10: "Work presentation stress. Breathed through it."
- 2023-12-05: "Panicking before review. Used affirmations."

**Task:**
1. Recognize the pattern (work-related anxiety)
2. What helped in the past?
3. Suggest 2-3 CBT-based coping strategies
4. Offer perspective based on past outcomes

Keep response concise (3-4 sentences), empathetic, actionable.
"""

AI Response:
"I notice work presentations often trigger anxiety for you, but looking at your history,
they typically go better than you expect. Last time, breathing exercises helped.
This time, try: 1) Practice aloud once, 2) Remember past successes,
3) Use 4-7-8 breathing if anxious. You've got this - your track record shows it."
```

**Cost:** ~$0.005 per new memory with analysis
**Display:** Show as notification or in-app insight card

---

### 4. Connection Discovery (PREMIUM)
**Когда:** Background job, раз в месяц
**Что делает:** Находит неочевидные связи между воспоминаниями

```dart
AI Prompt:
"""
Analyze these journal entries and find non-obvious connections:

${allUserMemories}

Look for:
- Seasonal patterns (do they feel worse in winter?)
- Anniversary reactions (trauma dates)
- Relationship dynamics
- Coping strategy effectiveness
- Long-term trends

Return top 5 insights as:
{
  "insight": "description",
  "confidence": 0.8,
  "supporting_evidence": ["memory_id1", "memory_id2"]
}
"""
```

**Example output:**
```json
{
  "insight": "You tend to feel more anxious every April since 2020. This might be related to anniversary of your dad's passing.",
  "confidence": 0.9,
  "supporting_evidence": ["mem_123", "mem_456", "mem_789"]
}
```

---

## 🏗️ Архитектура

### Firebase Functions + Gemini API

```
User creates memory
    ↓
Firebase Trigger
    ↓
Cloud Function
    ↓
Gemini API (analyze)
    ↓
Save insight to Firestore
    ↓
Push notification / In-app display
```

### Структура Firestore:

```
users/{userId}/insights/{insightId}
{
  type: "pattern" | "predictive" | "connection",
  createdAt: timestamp,
  content: "insight text",
  relatedMemories: ["id1", "id2"],
  confidence: 0.85,
  dismissed: false,
  premium: true
}
```

---

## 🚀 План реализации

### Phase 1: Setup (неделя 1)
- [ ] Firebase Functions setup
- [ ] Gemini API integration
- [ ] Environment variables (API key)
- [ ] Test function locally

### Phase 2: Smart Prompts - FREE (неделя 1-2)
- [ ] On memory create trigger
- [ ] Generate follow-up questions
- [ ] Display in memory_edit_screen
- [ ] A/B test engagement

### Phase 3: Pattern Analysis - PREMIUM (неделя 2-3)
- [ ] Weekly scheduled function
- [ ] Batch analyze last 30 days
- [ ] Save insights to Firestore
- [ ] Display in Insights screen

### Phase 4: Predictive Insights - PREMIUM (неделя 3-4)
- [ ] Find similar past memories
- [ ] Real-time analysis on new memory
- [ ] Push notification
- [ ] Insight card UI

### Phase 5: Connection Discovery (неделя 4-5)
- [ ] Monthly background job
- [ ] Deep pattern analysis
- [ ] Confidence scoring
- [ ] Premium paywall

### Phase 6: UI & UX (неделя 5-6)
- [ ] Insights screen/tab
- [ ] Notification handling
- [ ] Dismiss/save insights
- [ ] Premium upgrade prompts

---

## 📱 UI/UX Design

### Insights Screen (новая вкладка)

```
┌─────────────────────────────┐
│  📊 Your Insights            │
├─────────────────────────────┤
│                             │
│  💡 New Pattern Detected    │
│  You feel anxious every     │
│  Monday. This started 3     │
│  months ago when...         │
│                             │
│  [View Related Memories]    │
│  [Dismiss]                  │
│                             │
├─────────────────────────────┤
│  🔮 Prediction              │
│  Similar to Feb 15. Last    │
│  time breathing helped.     │
│                             │
│  [Try Technique]            │
│                             │
└─────────────────────────────┘
```

### Push Notification
```
📊 Lifeline Insight
"You mentioned 'work stress' 5 times this week.
Last month, taking walks helped. Want to try again?"
```

---

## 💰 Монетизация Strategy

### FREE Tier:
- ✅ Smart Prompts (при создании)
- ✅ 1 Pattern Insight/month
- ❌ Real-time predictions
- ❌ Connection discovery

### PREMIUM ($3.99/month):
- ✅ Unlimited smart prompts
- ✅ Weekly pattern analysis
- ✅ Real-time predictive insights
- ✅ Monthly connection discovery
- ✅ Priority processing

### Conversion Flow:
```
Week 1: User creates 10 memories, gets smart prompts (FREE) ✅
Week 2: First pattern insight: "We found 3 patterns!" → Shows 1, locks 2
        → "Unlock all insights with Premium"
Week 3: User writes anxious memory → "We've seen this before. Unlock prediction?"
Convert: 5-10% expected conversion rate
```

---

## ⚠️ Privacy & Ethics

1. **Data Security**
   - Never send encrypted memories without user decrypt
   - Use Firestore security rules
   - Gemini doesn't store data (Google policy)

2. **Transparency**
   - "AI analyzes your entries to find patterns"
   - Option to opt-out
   - Clear about what data is used

3. **Responsible AI**
   - Never diagnose ("seems like depression" ❌)
   - Suggest professional help when needed
   - CBT-based, evidence-backed advice

---

## 📊 Метрики успеха

### Engagement:
- % users who read insights: target > 60%
- % users who act on suggestions: target > 30%
- Time to first premium conversion: target < 2 weeks

### Quality:
- User ratings of insights: target > 4/5 stars
- Dismissal rate: target < 30%
- Accuracy of predictions (user feedback): target > 70%

### Business:
- Free → Premium conversion: target > 5%
- Retention of premium users: target > 80% after 3 months
- AI cost per premium user: target < $0.50/month

---

## 🎯 MVP для Launch

**Минимальный набор:**
1. ✅ Smart Prompts (FREE) - быстро показывает ценность AI
2. ✅ Weekly Pattern Analysis (PREMIUM) - conversion driver
3. ❌ Predictive + Connection (post-launch)

**Launch plan:**
- Week 1-2: Smart prompts only
- Week 3-4: Add pattern analysis, test conversion
- Month 2: Add predictive if conversion good

---

## 🔧 Техническая реализация

### Firebase Function Example:

```typescript
// functions/src/generateSmartPrompts.ts
export const onMemoryCreated = functions.firestore
  .document('users/{userId}/memories/{memoryId}')
  .onCreate(async (snap, context) => {
    const memory = snap.data();
    const userId = context.params.userId;

    // Call Gemini API
    const prompt = `User wrote: "${memory.content}"\n\nGenerate 2 CBT-based follow-up questions.`;

    const response = await geminiAPI.generateText({
      model: 'gemini-1.5-flash',
      prompt: prompt,
      maxTokens: 100,
    });

    // Save to Firestore
    await admin.firestore()
      .collection(`users/${userId}/insights`)
      .add({
        type: 'smart_prompt',
        content: response.text,
        relatedMemory: memory.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
  });
```

---

## ✅ Готовность к старту

- [x] $2000 Google Cloud Credits
- [x] Gemini API доступ
- [ ] Firebase Functions setup
- [ ] UI для insights
- [ ] Premium paywall

**Можем начинать через 2-3 недели после emotion visualization MVP!**
