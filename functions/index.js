/**
 * Cloud Functions для Firebase
 */
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const functions = require("firebase-functions"); // Используем основной импорт для v1
const axios = require("axios");
const admin = require("firebase-admin");
const {GoogleAuth} = require("google-auth-library");
const {getStorage} = require("firebase-admin/storage");
const crypto = require("crypto");

admin.initializeApp();

// Определяем секреты
const SPOTIFY_ID = defineSecret("SPOTIFY_ID");
const SPOTIFY_SECRET = defineSecret("SPOTIFY_SECRET");
// **НОВОЕ:** Секрет для проверки покупок в App Store
const APPLE_SHARED_SECRET = defineSecret("APPLE_SHARED_SECRET");

/**
 * Rate limiting helper function
 * @param {string} userId - User ID to check
 * @param {string} functionName - Name of the function being rate limited
 * @param {number} maxCalls - Maximum calls allowed in the time window
 * @param {number} windowMs - Time window in milliseconds
 * @return {Promise<void>} Throws HttpsError if rate limit exceeded
 */
async function checkRateLimit(userId, functionName, maxCalls, windowMs) {
  const now = Date.now();
  const rateLimitRef = admin.firestore()
      .collection("rate_limits")
      .doc(`${userId}_${functionName}`);

  const doc = await rateLimitRef.get();

  if (doc.exists) {
    const data = doc.data();
    const windowStart = data.windowStart.toMillis();

    // Check if we're still in the same time window
    if (now - windowStart < windowMs) {
      if (data.callCount >= maxCalls) {
        const resetTime = new Date(windowStart + windowMs);
        console.warn(`Rate limit exceeded for user ${userId} on ${functionName}. Resets at ${resetTime.toISOString()}`);
        throw new HttpsError(
            "resource-exhausted",
            "Too many requests. Please try again later.",
        );
      }

      // Increment call count
      await rateLimitRef.update({
        callCount: admin.firestore.FieldValue.increment(1),
      });
    } else {
      // New time window
      await rateLimitRef.set({
        windowStart: admin.firestore.Timestamp.fromMillis(now),
        callCount: 1,
      });
    }
  } else {
    // First call
    await rateLimitRef.set({
      windowStart: admin.firestore.Timestamp.fromMillis(now),
      callCount: 1,
    });
  }
}


// Кеш для Spotify токена
let spotifyTokenCache = {
  token: null,
  expiresAt: null,
};

/**
 * Получение Spotify токена
 */
async function getSpotifyToken() {
  if (spotifyTokenCache.token && spotifyTokenCache.expiresAt > Date.now()) {
    console.log("Returning cached Spotify token.");
    return spotifyTokenCache.token;
  }

  console.log("Fetching new Spotify token.");
  const clientId = SPOTIFY_ID.value();
  const clientSecret = SPOTIFY_SECRET.value();

  if (!clientId || !clientSecret) {
    console.error("Spotify credentials are not defined in the environment.");
    throw new HttpsError(
        "failed-precondition",
        "Spotify API credentials are not configured.",
    );
  }

  try {
    const response = await axios.post(
        "https://accounts.spotify.com/api/token",
        "grant_type=client_credentials",
        {
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization":
            "Basic " + Buffer.from(`${clientId}:${clientSecret}`).toString("base64"),
          },
        },
    );

    const token = response.data.access_token;
    const expiresIn = response.data.expires_in;

    spotifyTokenCache = {
      token: token,
      expiresAt: Date.now() + (expiresIn - 300) * 1000,
    };

    return token;
  } catch (error) {
    const errorMessage = (error.response && error.response.data) || error.message;
    console.error("Error fetching Spotify token:", errorMessage);
    spotifyTokenCache = {token: null, expiresAt: null};
    throw new HttpsError("internal", "Could not retrieve Spotify token.");
  }
}

/**
 * Поиск треков на Spotify
 */
exports.searchTracks = onCall(
    {
      secrets: [SPOTIFY_ID, SPOTIFY_SECRET],
      enforceAppCheck: true,
      cors: true,
      maxInstances: 10,
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
      }

      const uid = request.auth.uid;

      // --- RATE LIMITING: Максимум 30 поисковых запросов в час ---
      await checkRateLimit(uid, "searchTracks", 30, 60 * 60 * 1000); // 30 calls per hour
      // --- КОНЕЦ RATE LIMITING ---

      const query = request.data.query;
      if (!query) {
        throw new HttpsError("invalid-argument", "The function must be called with a 'query' parameter.");
      }

      // Validate query string to prevent injection
      if (typeof query !== "string" || query.length > 200) {
        throw new HttpsError("invalid-argument", "Invalid query parameter.");
      }

      try {
        console.log(`Searching for: ${query}`);
        const token = await getSpotifyToken();

        const resp = await axios.get("https://api.spotify.com/v1/search", {
          headers: {Authorization: `Bearer ${token}`},
          params: {q: query, type: "track", limit: 20},
        });

        const tracks = (resp.data.tracks.items || []).map((item) => ({
          id: item.id,
          name: item.name,
          artist: (item.artists || []).map((a) => a.name).join(", "),
          albumArtUrl: item.album.images.length ? item.album.images[0].url : null,
          trackUrl: item.external_urls.spotify,
        }));

        console.log(`Found ${tracks.length} tracks for query: ${query}`);
        return {tracks};
      } catch (err) {
        const errorMessage = (err.response && err.response.data) || err.message;
        console.error("Error searching Spotify tracks:", errorMessage);
        throw new HttpsError("internal", "Failed to search for tracks.", err.message);
      }
    },
);

/**
 * Получение деталей трека
 */
exports.getTrackDetails = onCall(
    {
      secrets: [SPOTIFY_ID, SPOTIFY_SECRET],
      enforceAppCheck: true,
      cors: true,
      maxInstances: 10,
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
      }

      const uid = request.auth.uid;

      // --- RATE LIMITING: Максимум 50 запросов деталей в час ---
      await checkRateLimit(uid, "getTrackDetails", 50, 60 * 60 * 1000); // 50 calls per hour
      // --- КОНЕЦ RATE LIMITING ---

      const trackId = request.data.trackId;
      if (!trackId) {
        throw new HttpsError("invalid-argument", "The function must be called with a 'trackId' parameter.");
      }

      // Validate trackId format (Spotify IDs are alphanumeric, max 22 chars)
      if (typeof trackId !== "string" || !/^[a-zA-Z0-9]{1,22}$/.test(trackId)) {
        throw new HttpsError("invalid-argument", "Invalid trackId format.");
      }

      try {
        console.log(`Getting details for track: ${trackId}`);
        const token = await getSpotifyToken();

        const resp = await axios.get(`https://api.spotify.com/v1/tracks/${trackId}`, {
          headers: {Authorization: `Bearer ${token}`},
        });

        const item = resp.data;
        const details = {
          id: item.id,
          name: item.name,
          artist: (item.artists || []).map((a) => a.name).join(", "),
          albumArtUrl: item.album.images.length ? item.album.images[0].url : null,
          trackUrl: item.external_urls.spotify,
        };

        console.log(`Successfully retrieved details for track: ${item.name}`);
        return {details};
      } catch (err) {
        const errorMessage = (err.response && err.response.data) || err.message;
        console.error("Error getting Spotify track details:", errorMessage);
        throw new HttpsError("internal", "Failed to get track details.", err.message);
      }
    },
);

/**
 * Верификация покупок
 */
exports.verifyPurchase = onCall(
    {
      enforceAppCheck: true,
      secrets: [APPLE_SHARED_SECRET],
      cors: true,
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
      }

      const {platform, receipt, productId} = request.data;
      const uid = request.auth.uid;

      // --- RATE LIMITING: Максимум 5 попыток в час ---
      await checkRateLimit(uid, "verifyPurchase", 5, 60 * 60 * 1000); // 5 calls per hour
      // --- КОНЕЦ RATE LIMITING ---

      if (!platform || !receipt || !productId) {
        throw new HttpsError("invalid-argument", "Missing required parameters for purchase verification.");
      }

      const VALID_PRODUCT_IDS = ["lifeline_premium_monthly", "lifeline_premium_yearly"];
      if (!VALID_PRODUCT_IDS.includes(productId)) {
        console.warn(`User ${uid} tried to verify an invalid productId: ${productId}`);
        throw new HttpsError("invalid-argument", "The provided product ID is not valid.");
      }

      // --- ЗАЩИТА ОТ REPLAY АТАК: Проверяем, использовался ли receipt ранее ---
      // Используем SHA-256 для предотвращения коллизий
      const receiptHash = crypto.createHash("sha256").update(receipt).digest("hex");
      const receiptRef = admin.firestore().collection("used_receipts").doc(receiptHash);

      const receiptDoc = await receiptRef.get();
      if (receiptDoc.exists) {
        const existingData = receiptDoc.data();
        console.warn(`Receipt replay attempt detected. Receipt already used by user ${existingData.userId} at ${existingData.usedAt.toDate().toISOString()}`);
        throw new HttpsError("already-exists", "This receipt has already been used.");
      }
      // --- КОНЕЦ ЗАЩИТЫ ---

      let isValid = false;
      let expiryDate = new Date();
      let transactionId = null; // Для более точной идентификации
      const expectedPackageName = "com.momentic.lifeline";
      const expectedBundleId = "com.momentic.lifeline";

      try {
        if (platform === "android") {
          console.log(`[Android] Starting purchase verification for user ${uid}, product ${productId}`);
          console.log(`[Android] Environment check - Project: ${process.env.GCLOUD_PROJECT}, Function: ${process.env.FUNCTION_NAME}`);

          const auth = new GoogleAuth({
            scopes: "https://www.googleapis.com/auth/androidpublisher",
          });

          console.log("[Android] GoogleAuth instance created");

          let authClient;
          try {
            authClient = await auth.getClient();
            console.log(`[Android] Auth client obtained successfully, type: ${authClient.constructor.name}`);
          } catch (authError) {
            console.error("[Android] Failed to get auth client:", authError);
            throw authError;
          }

          const credentials = await auth.getCredentials();
          const projectId = await auth.getProjectId();

          console.log(`[Android] Service account: ${credentials.client_email || "unknown"}`);
          console.log(`[Android] Project ID: ${projectId}`);
          console.log(`[Android] Scopes: ${JSON.stringify(auth.scopes)}`);
          console.log(`[Android] Credentials type: ${credentials.type || "unknown"}`);
          console.log(`[Android] Has private key: ${!!credentials.private_key}`);

          const url = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/" +
            `${expectedPackageName}/purchases/subscriptions/${productId}/tokens/${receipt}`;

          console.log(`[Android] Request URL: ${url}`);
          console.log(`[Android] Package name: ${expectedPackageName}`);
          console.log("[Android] Making API request...");

          let response;
          try {
            response = await authClient.request({url});
          } catch (apiError) {
            console.error("[Android] API request failed at HTTP level");
            console.error(`[Android] API Error name: ${apiError.name}`);
            console.error(`[Android] API Error message: ${apiError.message}`);
            if (apiError.response) {
              console.error(`[Android] API Error response headers: ${JSON.stringify(apiError.response.headers)}`);
            }
            throw apiError;
          }

          console.log(`[Android] API response status: ${response.status}`);
          console.log("[Android] API response received successfully");

          // --- ИЗМЕНЕНИЕ: Усиленная проверка ответа от Google Play ---
          if (response.data && response.data.expiryTimeMillis) {
            const purchase = response.data;
            const isExpired = parseInt(purchase.expiryTimeMillis) <= Date.now();

            // purchaseState может отсутствовать для некоторых типов подписок
            // Если поле отсутствует, считаем покупку валидной если она не истекла
            const hasPurchaseState = purchase.purchaseState !== undefined;
            const isPurchaseStateValid = hasPurchaseState ? purchase.purchaseState === 0 : true;

            const isAcknowledged = purchase.acknowledgementState === 1; // 1 = ACKNOWLEDGED

            console.log(`[Android] Purchase validation: expired=${isExpired}, stateValid=${isPurchaseStateValid}, acknowledged=${isAcknowledged}, hasPurchaseState=${hasPurchaseState}`);

            if (!isExpired && isPurchaseStateValid) {
              isValid = true;
              expiryDate = new Date(parseInt(purchase.expiryTimeMillis));
              transactionId = purchase.orderId; // Сохраняем orderId для логирования
              console.log(`[Android] Purchase is VALID. Expiry: ${expiryDate.toISOString()}, OrderId: ${transactionId}`);
            } else {
              // Логируем, почему покупка недействительна, даже если ответ получен
              console.warn(`[Android] Purchase for user ${uid} is invalid. Details:`, {
                productId: productId,
                isExpired: isExpired,
                expiryTimeMillis: purchase.expiryTimeMillis,
                isPurchaseStateValid: isPurchaseStateValid,
                purchaseState: purchase.purchaseState,
                isAcknowledged: isAcknowledged,
                acknowledgementState: purchase.acknowledgementState,
              });
            }
          }
          // --- КОНЕЦ ИЗМЕНЕНИЯ ---
        } else if (platform === "ios") {
          const isSandbox = (process.env.FUNCTIONS_EMULATOR === "true");
          const url = isSandbox ? "https://sandbox.itunes.apple.com/verifyReceipt" : "https://buy.itunes.apple.com/verifyReceipt";
          const secret = APPLE_SHARED_SECRET.value();
          if (!secret) {
              throw new HttpsError("failed-precondition", "Apple Shared Secret is not configured.");
          }

          const response = await axios.post(url, {
              "receipt-data": receipt,
              "password": secret,
              "exclude-old-transactions": true,
          });

          if (response.data && response.data.status === 0) {
             const receiptData = response.data.receipt;
             if (receiptData && receiptData.bundle_id === expectedBundleId && response.data.latest_receipt_info) {
                 // --- ИЗМЕНЕНИЕ: Фильтруем по productId и берем самую последнюю транзакцию ---
                 const sortedReceipts = response.data.latest_receipt_info
                    .filter((t) => t.product_id === productId) // Фильтруем по ID продукта
                    .sort((a, b) => parseInt(b.expires_date_ms) - parseInt(a.expires_date_ms));

                 const latestTransaction = sortedReceipts.length > 0 ? sortedReceipts[0] : null;
                 // --- КОНЕЦ ИЗМЕНЕНИЯ ---

                 if (latestTransaction && latestTransaction.expires_date_ms) {
                     const expiryTimestamp = parseInt(latestTransaction.expires_date_ms);
                     if (expiryTimestamp > Date.now()) {
                        isValid = true;
                        expiryDate = new Date(expiryTimestamp);
                        transactionId = latestTransaction.transaction_id; // Сохраняем transaction_id для логирования
                     } else {
                       console.warn(`[iOS] Latest transaction for user ${uid} and product ${productId} is expired.`);
                     }
                 } else {
                    console.warn(`[iOS] No matching active transaction found for user ${uid} and product ${productId}.`);
                 }
             }
          } else {
             // --- ИЗМЕНЕНИЕ: Улучшенное логирование ошибок от Apple ---
             console.warn(`[iOS] Apple receipt verification failed for user ${uid}. Status: ${response.data.status}`);
             // В реальном проекте здесь можно было бы отправить ошибку в систему мониторинга.
             // --- КОНЕЦ ИЗМЕНЕНИЯ ---
          }
        }
      } catch (error) {
        // --- ИЗМЕНЕНИЕ: Улучшенное логирование ошибок ---
        console.error(`[${platform}] Purchase verification FAILED for user ${uid}`);
        console.error(`[${platform}] Error code: ${error.code || "unknown"}`);
        console.error(`[${platform}] Error status: ${error.status || "unknown"}`);

        if (error.response) {
          console.error(`[${platform}] Response status: ${error.response.status}`);
          console.error(`[${platform}] Response data: ${JSON.stringify(error.response.data)}`);
        }

        const errorMessage = (error.response && error.response.data) ? JSON.stringify(error.response.data) : error.message;
        console.error(`Purchase verification failed for user ${uid} on platform ${platform}. Error: ${errorMessage}`, {
          uid: uid,
          productId: productId,
          platform: platform,
        });

        throw new HttpsError("internal", "Verification request failed.");
        // --- КОНЕЦ ИЗМЕНЕНИЯ ---
      }

      if (isValid) {
        // --- СОХРАНЕНИЕ ИСПОЛЬЗОВАННОГО RECEIPT ДЛЯ ПРЕДОТВРАЩЕНИЯ REPLAY АТАК ---
        await receiptRef.set({
          userId: uid,
          productId: productId,
          platform: platform,
          transactionId: transactionId,
          usedAt: admin.firestore.FieldValue.serverTimestamp(),
          expiryDate: admin.firestore.Timestamp.fromDate(expiryDate),
        });
        // --- КОНЕЦ СОХРАНЕНИЯ ---

        await admin.firestore().collection("users").doc(uid).set({
          isPremium: true,
          premiumUntil: admin.firestore.Timestamp.fromDate(expiryDate),
        }, {merge: true});

        console.log(
            `Successfully verified purchase for user ${uid}. ` +
            `Premium expires on ${expiryDate.toISOString()}. TransactionId: ${transactionId}`,
        );
        return {success: true, premiumUntil: expiryDate.toISOString()};
      } else {
        console.warn(`Invalid purchase receipt for user ${uid}.`);
        throw new HttpsError("permission-denied", "The purchase receipt is not valid.");
      }
    },
);


/**
 * Удаление данных пользователя при удалении аккаунта
 */
exports.deleteUserData = functions.auth.user().onDelete(async (user) => {
  const {uid} = user;
  const db = admin.firestore();
  const bucket = getStorage().bucket();

  console.log(`Starting cleanup for user UID: ${uid}`);

  const firestoreRef = db.collection("users").doc(uid);
  const storageFolder = `users/${uid}`;

  const deletePromises = [];

  // --- 1. Удаление данных Firestore ---
  const deleteFirestorePromise = db.recursiveDelete(firestoreRef)
      .then(() => {
        console.log(`Successfully deleted Firestore data for user: ${uid}`);
      })
      .catch((error) => {
        console.error(`Error deleting Firestore data for user: ${uid}`, error);
      });
  deletePromises.push(deleteFirestorePromise);

  // --- 2. Удаление данных Storage ---
  const deleteStoragePromise = bucket.deleteFiles({prefix: storageFolder})
      .then(() => {
        console.log(`Successfully deleted Storage folder: ${storageFolder}`);
      })
      .catch((error) => {
        if (error.code === 404) {
          console.log(`Storage folder not found for user ${uid}, skipping.`);
        } else {
          console.error(`Error deleting Storage folder for user: ${uid}`, error);
        }
      });
  deletePromises.push(deleteStoragePromise);

  // Ожидаем завершения всех операций удаления
  await Promise.all(deletePromises);

  console.log(`Finished cleanup for user: ${uid}`);
  return null;
});

/**
 * Scheduled function для очистки старых использованных чеков (старше 90 дней)
 * Запускается каждый день в 3:00 UTC
 */
exports.cleanupOldReceipts = functions.pubsub.schedule("0 3 * * *")
    .timeZone("UTC")
    .onRun(async (context) => {
      const db = admin.firestore();
      const now = admin.firestore.Timestamp.now();
      const ninetyDaysAgo = admin.firestore.Timestamp.fromMillis(
          now.toMillis() - (90 * 24 * 60 * 60 * 1000), // 90 дней в миллисекундах
      );

      console.log(`[cleanupOldReceipts] Starting cleanup of receipts older than ${ninetyDaysAgo.toDate().toISOString()}`);

      try {
        // Находим все старые чеки
        const oldReceiptsQuery = db.collection("used_receipts")
            .where("usedAt", "<", ninetyDaysAgo)
            .limit(500); // Обрабатываем по 500 за раз для избежания таймаутов

        const snapshot = await oldReceiptsQuery.get();

        if (snapshot.empty) {
          console.log("[cleanupOldReceipts] No old receipts found to delete.");
          return null;
        }

        // Удаляем найденные документы батчами
        const batch = db.batch();
        let deleteCount = 0;

        snapshot.docs.forEach((doc) => {
          batch.delete(doc.ref);
          deleteCount++;
        });

        await batch.commit();

        console.log(`[cleanupOldReceipts] Successfully deleted ${deleteCount} old receipt(s).`);

        // Если были найдены 500 документов, возможно есть еще - логируем предупреждение
        if (deleteCount === 500) {
          console.warn("[cleanupOldReceipts] Deleted 500 receipts (batch limit). There may be more old receipts to clean up in the next run.");
        }

        return null;
      } catch (error) {
        console.error("[cleanupOldReceipts] Error during cleanup:", error);
        throw error;
      }
    });

// ============================================
// AI FUNCTIONS (Gemini 2.5 Flash-Lite)
// ============================================
const aiFunctions = require("./ai_functions");
exports.generateSmartPrompts = aiFunctions.generateSmartPrompts;
exports.weeklyPatternAnalysis = aiFunctions.weeklyPatternAnalysis;
exports.generatePredictiveInsight = aiFunctions.generatePredictiveInsight;

