# AI Features Testing Scenario

## Подготовка к тестированию

### 1. Проверка деплоя Firebase Functions
```bash
firebase functions:list
```
Должны быть активны:
- ✅ generateSmartPrompts (us-central1)
- ✅ weeklyPatternAnalysis (us-central1)
- ✅ generatePredictiveInsight (us-central1)

### 2. Запуск приложения
```bash
flutter run
```

### 3. Проверка начального состояния
- Войти в аккаунт (или создать новый тестовый)
- Открыть **Profile Screen**
- Проверить, что секция **AI Settings** отображается

---

## Тест 1: Активация AI (Master Switch)

### Цель
Проверить, что настройки AI корректно отображаются и сохраняются

### Шаги
1. Открыть **Profile → AI Settings**
2. Нажать на **Master AI Switch**
3. ✅ Должен появиться **AI Consent Dialog**
4. Нажать **"I Understand"** или **"Согласен"**
5. ✅ Switch должен включиться (aiEnabled = true)
6. ✅ Должны раскрыться подсекции:
   - Smart Prompts (FREE) - включена по умолчанию
   - Pattern Analysis (PREMIUM) - если isPremium
   - Predictive Insights (PREMIUM) - если isPremium

### Ожидаемый результат
- AI включен
- Настройки сохранены в Firestore
- Виджеты готовы к отображению

### Проверка в Firestore Console
```
users/{userId}/
  aiEnabled: true
  aiSmartPromptsEnabled: true
  aiSmartPromptsInEdit: true
  aiPatternAnalysisEnabled: true (если premium)
  aiPredictiveInsightsEnabled: true (если premium)
```

---

## Тест 2: Smart Prompts (FREE feature)

### Цель
Проверить генерацию умных вопросов на базе CBT

### Предусловия
- ✅ aiEnabled = true
- ✅ aiSmartPromptsEnabled = true
- ✅ aiSmartPromptsInEdit = true

### Шаги
1. Создать новое воспоминание:
   - Нажать **"+"** (Create Memory)
   - Заполнить **Title**: "Стресс на работе"
   - Заполнить **Content**: "Сегодня был сложный день. Начальник критиковал мою работу перед всей командой. Чувствую себя ужасно."
   - Выбрать **Emotion**: Sadness или Anxiety (интенсивность 0.7-0.9)

2. **НЕ сохранять сразу!** - остаться на экране редактирования

3. Подождать **2-5 секунд** после заполнения

4. ✅ Должна появиться **SmartPromptsCard** с 2-3 вопросами:
   - Пример: "Что именно в критике тебя задело больше всего?"
   - Пример: "Как бы ты поддержал друга в такой ситуации?"
   - Пример: "Что могло бы помочь тебе справиться прямо сейчас?"

5. Можно ответить на вопросы в поле Content (опционально)

6. Сохранить воспоминание

### Проверка в Firestore Console
```
users/{userId}/insights/{insightId}
  type: "smart_prompt"
  content: {
    questions: ["...", "...", "..."]
  }
  relatedMemories: ["{memoryId}"]
  dismissed: false
  createdAt: timestamp
```

### Проверка в Firebase Functions Logs
```bash
firebase functions:log --only generateSmartPrompts
```
Должны увидеть:
```
Smart Prompts triggered for user {userId}, memory {memoryId}
Generated smart prompts successfully
```

---

## Тест 3: Predictive Insights (PREMIUM feature)

### Цель
Проверить предиктивные инсайты на основе истории

### Предусловия
- ✅ isPremium = true
- ✅ aiEnabled = true
- ✅ aiPredictiveInsightsEnabled = true
- ✅ aiPredictiveInEdit = true
- ✅ Есть минимум 2-3 воспоминания с эмоцией Sadness

### Шаги
1. Создать новое воспоминание с **Sadness**:
   - Title: "Опять грустно"
   - Content: "Не знаю почему, но настроение плохое"
   - Emotion: Sadness (0.8)

2. Подождать **3-7 секунд**

3. ✅ Должна появиться **PredictiveInsightCard** под SmartPromptsCard:
   - Confidence indicator (High/Medium/Low)
   - Предсказание на основе паттернов
   - Количество похожих воспоминаний
   - Кнопка "View Similar Memories"

4. Пример инсайта:
   > "Based on 5 similar memories, you usually feel better after talking to a friend or going for a walk. Try reaching out to someone you trust."

### Проверка в Firestore
```
users/{userId}/insights/{insightId}
  type: "predictive"
  content: "..."
  confidence: 0.85
  relatedMemories: ["{memoryId}", "{similarMemoryId1}", ...]
  metadata: {
    similarMemoriesCount: 5
  }
```

### Проверка логов
```bash
firebase functions:log --only generatePredictiveInsight
```

---

## Тест 4: Pattern Analysis (PREMIUM - Weekly)

### Цель
Проверить еженедельный анализ паттернов

### Предусловия
- ✅ isPremium = true
- ✅ aiEnabled = true
- ✅ aiPatternAnalysisEnabled = true
- ✅ Есть минимум 5-10 воспоминаний за последние 30 дней

### Вариант A: Ручной запуск (для тестирования)

**ВАЖНО:** Функция weeklyPatternAnalysis запускается автоматически каждое воскресенье в 00:00 UTC. Для тестирования можно вызвать вручную:

```bash
# Вызов функции вручную через Firebase Console
# Functions → weeklyPatternAnalysis → Testing → Run function
```

Или через curl:
```bash
curl -X POST https://us-central1-lifeline-11615.cloudfunctions.net/weeklyPatternAnalysis \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Вариант B: Дождаться воскресенья 00:00 UTC

1. Создать 5-10 воспоминаний в течение недели с разными эмоциями
2. Дождаться воскресенья 00:00 UTC
3. В понедельник утром проверить результаты

### Проверка результатов

1. **Просмотр в MemoryViewScreen:**
   - Открыть любое воспоминание
   - Прокрутить вниз после Reflection Card
   - ✅ Должна появиться **PatternInsightCard** с:
     - Themes (темы из воспоминаний)
     - Emotional Cycles (паттерны эмоций)
     - Triggers (что вызывает эмоции)
     - What Helped (что помогало)

2. **Firestore:**
```
users/{userId}/insights/{insightId}
  type: "pattern"
  content: {
    themes: ["work stress", "relationships", ...],
    emotionalCycles: "...",
    triggers: "...",
    whatHelped: "..."
  }
  periodStart: timestamp (30 дней назад)
  periodEnd: timestamp (сейчас)
```

### Проверка логов
```bash
firebase functions:log --only weeklyPatternAnalysis
```

---

## Тест 5: Monthly Pattern Card

### Цель
Проверить отображение месячных паттернов в кластере

### Предусловия
- ✅ isPremium = true
- ✅ aiEnabled = true
- ✅ aiPatternsInMonthlyView = true
- ✅ Есть воспоминания за текущий месяц
- ✅ weeklyPatternAnalysis уже выполнялся

### Шаги
1. Перейти на **Lifeline** (главный экран)
2. Нажать на **месячный кластер** (круг с несколькими воспоминаниями)
3. Откроется **Monthly Cluster Bottom Sheet**
4. Прокрутить вниз после emotion chips
5. ✅ Должна появиться **MonthlyPatternCard** с:
   - Themes этого месяца
   - Top triggers
   - What helped
   - Emotion summary

### Проверка в Firestore
```
users/{userId}/monthlyPatterns/2025-10
  themes: ["..."]
  triggers: ["..."]
  whatHelped: ["..."]
  emotionCounts: {
    happiness: 5,
    sadness: 3,
    anxiety: 2
  }
  createdAt: timestamp
```

---

## Тест 6: Privacy Controls (Encrypted Memories)

### Цель
Проверить, что AI не обрабатывает зашифрованные воспоминания по умолчанию

### Шаги
1. Создать **зашифрованное** воспоминание:
   - Enable encryption toggle при создании
   - Заполнить title и content
   - Сохранить

2. Подождать 5 секунд

3. ✅ SmartPromptsCard **НЕ должна** появиться
4. ✅ PredictiveInsightCard **НЕ должна** появиться

### Проверка логов
```bash
firebase functions:log --only generateSmartPrompts
```
Должен быть лог:
```
Memory is encrypted and user doesn't allow AI on encrypted content
```

### Тест с разрешением обработки зашифрованных
1. Открыть **Profile → AI Settings**
2. Включить **"Process Encrypted Memories"** (aiProcessEncryptedMemories = true)
3. Появится предупреждение об отправке зашифрованного контента в Gemini API
4. Подтвердить
5. Создать новое зашифрованное воспоминание
6. ✅ Теперь AI виджеты **должны** появиться

---

## Тест 7: Granular Location Controls

### Цель
Проверить детальные настройки отображения по локациям

### Тест A: Отключить Smart Prompts в Edit
1. **Profile → AI Settings → Smart Prompts**
2. Отключить **"Show in Memory Edit"** (aiSmartPromptsInEdit = false)
3. Создать новое воспоминание
4. ✅ SmartPromptsCard **НЕ должна** появиться в MemoryEditScreen

### Тест B: Отключить Patterns в Memory View
1. **Profile → AI Settings → Pattern Analysis**
2. Отключить **"Show in Memory View"** (aiPatternsInMemoryView = false)
3. Открыть существующее воспоминание
4. ✅ PatternInsightCard **НЕ должна** появиться

### Тест C: Отключить Patterns в Monthly View
1. Отключить **"Show in Monthly View"** (aiPatternsInMonthlyView = false)
2. Открыть monthly cluster
3. ✅ MonthlyPatternCard **НЕ должна** появиться

---

## Тест 8: Dismissal (отклонение инсайтов)

### Цель
Проверить, что пользователь может скрыть AI инсайты

### Шаги
1. Открыть воспоминание с PatternInsightCard
2. Нажать кнопку **"Dismiss"** или "X"
3. ✅ Карточка должна исчезнуть
4. Закрыть и снова открыть это воспоминание
5. ✅ PatternInsightCard **НЕ должна** появиться снова

### Проверка в Firestore
```
users/{userId}/insights/{insightId}
  dismissed: true  // было false
```

---

## Чек-лист всех функций

### FREE Features:
- [ ] Smart Prompts отображаются в MemoryEditScreen
- [ ] Smart Prompts генерируются на базе CBT
- [ ] Smart Prompts можно отключить по локациям
- [ ] Зашифрованные воспоминания не обрабатываются (по умолчанию)

### PREMIUM Features:
- [ ] Predictive Insights отображаются в MemoryEditScreen
- [ ] Predictive Insights основаны на похожих воспоминаниях
- [ ] Pattern Analysis отображается в MemoryViewScreen
- [ ] Monthly Pattern Card отображается в cluster bottom sheet
- [ ] Weekly Pattern Analysis запускается автоматически по воскресеньям

### Privacy & Controls:
- [ ] AI Consent Dialog при первом включении
- [ ] Master switch включает/отключает весь AI
- [ ] Granular controls работают (per-feature, per-location)
- [ ] Encrypted memories warning при включении обработки
- [ ] Dismissal инсайтов работает корректно

---

## Мониторинг и отладка

### Просмотр логов всех AI функций
```bash
# Все AI функции
firebase functions:log | grep -E "(generateSmartPrompts|weeklyPatternAnalysis|generatePredictiveInsight)"

# Только Smart Prompts
firebase functions:log --only generateSmartPrompts

# Только Pattern Analysis
firebase functions:log --only weeklyPatternAnalysis

# Только Predictive Insights
firebase functions:log --only generatePredictiveInsight
```

### Firestore Console
Проверить коллекции:
- `users/{userId}/insights` - все AI инсайты
- `users/{userId}/monthlyPatterns/{monthKey}` - месячные паттерны
- `users/{userId}` - userProfile с настройками AI

### Проверка расходов Gemini API
```bash
# Google Cloud Console → APIs & Services → Gemini API → Quotas
```
Или в Firebase Console:
```
Extensions → Usage
```

---

## Известные ограничения

1. **weeklyPatternAnalysis запускается раз в неделю** - для тестирования нужен ручной вызов
2. **Gemini API имеет rate limits** - не создавать 100+ воспоминаний подряд
3. **AI требует минимум данных:**
   - Smart Prompts: нужен title + content
   - Predictive: нужно 2+ похожих воспоминания
   - Pattern Analysis: нужно 5+ воспоминаний за 30 дней

---

## Успешное завершение тестирования

Все тесты пройдены, если:
- ✅ AI включается через настройки
- ✅ Smart Prompts появляются в течение 2-5 секунд
- ✅ Predictive Insights работают для premium
- ✅ Pattern Analysis отображается корректно
- ✅ Monthly patterns показывают статистику
- ✅ Privacy controls работают
- ✅ Dismissal работает
- ✅ Нет ошибок в Firebase Functions logs

**Готово к продакшену!** 🎉
