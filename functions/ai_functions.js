/**
 * AI Functions powered by Google Gemini 2.5 Flash-Lite
 *
 * Features:
 * - Smart Prompts (FREE): Suggests thoughtful follow-up questions
 * - Pattern Analysis (PREMIUM): Weekly analysis of memory patterns
 * - Predictive Insights (PREMIUM): Predicts based on user's history
 *
 * Cost: $0.10 input / $0.40 output per 1M tokens
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {defineSecret} = require("firebase-functions/params");
const admin = require("firebase-admin");
const {GoogleGenerativeAI} = require("@google/generative-ai");

// Define Gemini API key secret
const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

/**
 * Helper function to call Gemini API
 * @param {string} prompt - The prompt to send to Gemini
 * @param {string} modelName - Model name (default: gemini-2.5-flash-lite)
 * @param {string} apiKey - Gemini API key
 * @return {Promise<string>} - Generated text response
 */
async function callGeminiAPI(prompt, modelName = "gemini-2.5-flash-lite", apiKey) {
  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({model: modelName});

  const result = await model.generateContent(prompt);
  const response = result.response;
  return response.text();
}

/**
 * Smart Prompts Function (FREE)
 * Triggered when a new memory is created
 * Generates thoughtful follow-up questions using CBT techniques
 */
exports.generateSmartPrompts = onDocumentCreated(
    {
      document: "users/{userId}/memories/{memoryId}",
      secrets: [GEMINI_API_KEY],
      region: "europe-west1",
    },
    async (event) => {
      const userId = event.params.userId;
      const memoryId = event.params.memoryId;
      const memory = event.data.data();

      console.log(`Smart Prompts triggered for user ${userId}, memory ${memoryId}`);

      try {
        // Get user profile
        const profileDoc = await admin.firestore().collection("users").doc(userId).get();
        if (!profileDoc.exists) {
          console.log("User profile not found");
          return;
        }

        const profile = profileDoc.data();

        // Check if AI is enabled
        if (!profile.aiEnabled || !profile.aiSmartPromptsEnabled || !profile.aiSmartPromptsInEdit) {
          console.log("Smart Prompts disabled in user settings");
          return;
        }

        // Check if memory is encrypted and if user allows processing encrypted
        if (memory.isEncrypted && !profile.aiProcessEncryptedMemories) {
          console.log("Memory is encrypted and user doesn't allow AI on encrypted content");
          return;
        }

        // Don't process if title or content is missing
        if (!memory.title || !memory.content) {
          console.log("Memory missing title or content");
          return;
        }

        // Build prompt for Gemini
        const prompt = `
You are a thoughtful journaling assistant using CBT (Cognitive Behavioral Therapy) techniques.

User wrote this journal entry:
Title: "${memory.title}"
Content: "${memory.content}"
${memory.primaryEmotion ? `Primary Emotion: ${memory.primaryEmotion}` : ""}

Generate 2-3 thoughtful follow-up questions to help them reflect deeper.
Focus on:
- What triggered this? (Situation)
- How did you feel? (Emotion/Thought)
- What would help? (Action/Coping)

Keep questions short (max 10 words each) and empathetic.
Return ONLY a JSON array of strings, nothing else.

Example output:
["What triggered this feeling?", "How are you feeling now?", "What could help you feel better?"]
`;

        // Call Gemini API
        const responseText = await callGeminiAPI(prompt, "gemini-2.5-flash-lite", GEMINI_API_KEY.value());

        // Parse JSON response
        let questions;
        try {
          // Remove markdown code blocks if present
          const cleanedText = responseText.replace(/```json\n?/g, "").replace(/```\n?/g, "").trim();
          questions = JSON.parse(cleanedText);
        } catch (parseError) {
          console.error("Failed to parse Gemini response as JSON:", responseText);
          // Fallback: treat as plain text and split by newlines
          questions = responseText.split("\n").filter((q) => q.trim().length > 0).slice(0, 3);
        }

        // Save insight to Firestore
        await admin.firestore().collection(`users/${userId}/insights`).add({
          type: "smart_prompt",
          content: questions.join("\n"),
          questions: questions,
          relatedMemories: [memoryId],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          viewed: false,
          dismissed: false,
          confidence: 1.0,
        });

        console.log(`Smart Prompts generated for memory ${memoryId}:`, questions);
      } catch (error) {
        console.error("Error generating Smart Prompts:", error);
        // Don't throw - this is a non-critical feature
      }
    },
);

/**
 * Pattern Analysis Function (PREMIUM)
 * Runs weekly on Sundays at midnight UTC
 * Analyzes last 30 days of memories to find patterns
 */
exports.weeklyPatternAnalysis = onSchedule(
    {
      schedule: "every sunday 00:00",
      timeZone: "UTC",
      secrets: [GEMINI_API_KEY],
      region: "europe-west1",
    },
    async (context) => {
      console.log("Weekly Pattern Analysis started");

      try {
        // Get all premium users
        const usersSnapshot = await admin.firestore()
            .collection("users")
            .where("isPremium", "==", true)
            .get();

        console.log(`Found ${usersSnapshot.size} premium users`);

        for (const userDoc of usersSnapshot.docs) {
          const userId = userDoc.id;
          const profile = userDoc.data();

          // Check if pattern analysis is enabled
          if (!profile.aiEnabled || !profile.aiPatternAnalysisEnabled) {
            console.log(`Pattern analysis disabled for user ${userId}`);
            continue;
          }

          try {
            await analyzeUserPatterns(userId, profile, GEMINI_API_KEY.value());
          } catch (error) {
            console.error(`Error analyzing patterns for user ${userId}:`, error);
            // Continue with other users
          }
        }

        console.log("Weekly Pattern Analysis completed");
      } catch (error) {
        console.error("Error in weeklyPatternAnalysis:", error);
      }
    },
);

/**
 * Helper function to analyze patterns for a single user
 * @param {string} userId - User ID
 * @param {Object} profile - User profile
 * @param {string} apiKey - Gemini API key
 * @return {Promise<void>}
 */
async function analyzeUserPatterns(userId, profile, apiKey) {
  console.log(`Analyzing patterns for user ${userId}`);

  // Get last 30 days of memories
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  const memoriesSnapshot = await admin.firestore()
      .collection(`users/${userId}/memories`)
      .where("date", ">=", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
      .orderBy("date", "desc")
      .get();

  console.log(`Found ${memoriesSnapshot.size} memories in last 30 days for user ${userId}`);

  if (memoriesSnapshot.size < 5) {
    console.log(`Not enough memories for pattern analysis (need at least 5, got ${memoriesSnapshot.size})`);
    return;
  }

  // Filter processable memories
  const processableMemories = [];
  memoriesSnapshot.forEach((doc) => {
    const memory = doc.data();
    // Skip encrypted unless user allows
    if (memory.isEncrypted && !profile.aiProcessEncryptedMemories) {
      return;
    }
    // Skip if missing content
    if (!memory.title || !memory.content) {
      return;
    }
    processableMemories.push({
      id: doc.id,
      ...memory,
      date: memory.date.toDate().toISOString().split("T")[0], // Format date
    });
  });

  if (processableMemories.length < 5) {
    console.log(`Not enough processable memories (need 5, got ${processableMemories.length})`);
    return;
  }

  // Build prompt for pattern analysis
  const memoriesSummary = processableMemories.map((m) =>
    `${m.date}: "${m.title}" - ${m.content.substring(0, 200)} [Emotion: ${m.primaryEmotion || "none"}]`,
  ).join("\n\n");

  const prompt = `
Analyze these journal entries from the last 30 days and find meaningful patterns:

${memoriesSummary}

Identify:
1. Recurring themes (work, relationships, health, etc.)
2. Emotional cycles (when do they feel worst/best? any patterns?)
3. Triggers (what causes negative emotions?)
4. What helped in the past (coping strategies that worked)
5. Signs of progress (are things getting better?)

Return ONLY a JSON object with this structure:
{
  "themes": ["theme1", "theme2"],
  "emotional_cycles": "description of patterns",
  "triggers": ["trigger1", "trigger2"],
  "what_helped": ["strategy1", "strategy2"],
  "progress_notes": "signs of improvement or concerns"
}
`;

  // Call Gemini API
  const responseText = await callGeminiAPI(prompt, "gemini-2.5-flash-lite", apiKey);

  // Parse JSON response
  let patternData;
  try {
    const cleanedText = responseText.replace(/```json\n?/g, "").replace(/```\n?/g, "").trim();
    patternData = JSON.parse(cleanedText);
  } catch (parseError) {
    console.error("Failed to parse pattern analysis response:", responseText);
    return;
  }

  // Format insight text
  const insightText = `
📊 Pattern Analysis (Last 30 Days)

Themes: ${patternData.themes.join(", ")}

${patternData.emotional_cycles}

Triggers: ${patternData.triggers.join(", ")}

What helped: ${patternData.what_helped.join(", ")}

${patternData.progress_notes}
`.trim();

  // Save pattern insight
  await admin.firestore().collection(`users/${userId}/insights`).add({
    type: "pattern",
    content: insightText,
    relatedMemories: processableMemories.map((m) => m.id),
    pattern: patternData,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    viewed: false,
    dismissed: false,
    confidence: 0.8,
    periodDays: 30,
  });

  console.log(`Pattern analysis completed for user ${userId}`);

  // Send notification if enabled
  if (profile.aiPredictiveNotifications && profile.notificationsEnabled) {
    // TODO: Implement push notification via FCM
    console.log(`Would send notification to user ${userId} about new pattern`);
  }
}

/**
 * Predictive Insights Function (PREMIUM)
 * Triggered when a new memory is created
 * Finds similar past memories and suggests what helped before
 */
exports.generatePredictiveInsight = onDocumentCreated(
    {
      document: "users/{userId}/memories/{memoryId}",
      secrets: [GEMINI_API_KEY],
      region: "europe-west1",
    },
    async (event) => {
      const userId = event.params.userId;
      const memoryId = event.params.memoryId;
      const currentMemory = event.data.data();

      console.log(`Predictive Insight triggered for user ${userId}, memory ${memoryId}`);

      try {
        // Get user profile
        const profileDoc = await admin.firestore().collection("users").doc(userId).get();
        if (!profileDoc.exists) return;

        const profile = profileDoc.data();

        // Check if predictive insights enabled
        if (!profile.aiEnabled || !profile.isPremium ||
            !profile.aiPredictiveInsightsEnabled || !profile.aiPredictiveInEdit) {
          console.log("Predictive insights disabled");
          return;
        }

        // Skip encrypted unless allowed
        if (currentMemory.isEncrypted && !profile.aiProcessEncryptedMemories) {
          return;
        }

        // Skip if no emotion (can't find similar without emotion)
        if (!currentMemory.primaryEmotion) {
          console.log("No primary emotion - skipping predictive insight");
          return;
        }

        // Find similar past memories (same emotion, older than 7 days)
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        const similarMemoriesSnapshot = await admin.firestore()
            .collection(`users/${userId}/memories`)
            .where("primaryEmotion", "==", currentMemory.primaryEmotion)
            .where("date", "<", admin.firestore.Timestamp.fromDate(sevenDaysAgo))
            .orderBy("date", "desc")
            .limit(5)
            .get();

        if (similarMemoriesSnapshot.size === 0) {
          console.log("No similar past memories found");
          return;
        }

        const similarMemories = [];
        similarMemoriesSnapshot.forEach((doc) => {
          const memory = doc.data();
          if (memory.isEncrypted && !profile.aiProcessEncryptedMemories) return;
          if (!memory.title || !memory.content) return;

          similarMemories.push({
            id: doc.id,
            date: memory.date.toDate().toISOString().split("T")[0],
            title: memory.title,
            content: memory.content.substring(0, 200),
            reflectionAction: memory.reflectionAction,
          });
        });

        if (similarMemories.length === 0) {
          console.log("No processable similar memories");
          return;
        }

        // Build prompt for prediction
        const prompt = `
Current situation:
"${currentMemory.title}" - ${currentMemory.content.substring(0, 200)}
Emotion: ${currentMemory.primaryEmotion}

Similar past situations:
${similarMemories.map((m) =>
    `${m.date}: "${m.title}" - ${m.content}${m.reflectionAction ? `\nAction taken: ${m.reflectionAction}` : ""}`,
  ).join("\n\n")}

Based on their history, what helped before? Provide specific, actionable advice.
Keep response concise (max 100 words) and empathetic.
Return ONLY plain text, no JSON.
`;

        const prediction = await callGeminiAPI(prompt, "gemini-2.5-flash-lite", GEMINI_API_KEY.value());

        // Save predictive insight
        await admin.firestore().collection(`users/${userId}/insights`).add({
          type: "predictive",
          content: prediction,
          relatedMemories: [memoryId, ...similarMemories.map((m) => m.id)],
          prediction: {
            currentEmotion: currentMemory.primaryEmotion,
            similarPastCount: similarMemories.length,
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          viewed: false,
          dismissed: false,
          confidence: Math.min(0.5 + (similarMemories.length * 0.1), 0.9),
        });

        console.log(`Predictive insight generated for memory ${memoryId}`);
      } catch (error) {
        console.error("Error generating predictive insight:", error);
      }
    },
);
