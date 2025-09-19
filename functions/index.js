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

admin.initializeApp();

// Определяем секреты
const SPOTIFY_ID = defineSecret("SPOTIFY_ID");
const SPOTIFY_SECRET = defineSecret("SPOTIFY_SECRET");

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

      const query = request.data.query;
      if (!query) {
        throw new HttpsError("invalid-argument", "The function must be called with a 'query' parameter.");
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

      const trackId = request.data.trackId;
      if (!trackId) {
        throw new HttpsError("invalid-argument", "The function must be called with a 'trackId' parameter.");
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
      cors: true,
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
      }

      const {platform, receipt, productId} = request.data;
      const uid = request.auth.uid;

      if (!platform || !receipt || !productId) {
        throw new HttpsError("invalid-argument", "Missing required parameters for purchase verification.");
      }

      let isValid = false;
      let expiryDate = new Date();

      try {
        if (platform === "android") {
          const auth = new GoogleAuth({
            scopes: "https://www.googleapis.com/auth/androidpublisher",
          });
          const authClient = await auth.getClient();

          // --- ДИАГНОСТИЧЕСКАЯ СТРОКА ---
          console.log(`[DIAGNOSTIC] Attempting to authenticate with Play API using service account: ${authClient.email || "Email not directly available"}`);

          const packageName = "com.momentic.lifeline";
          const url = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/" +
            `${packageName}/purchases/subscriptions/${productId}/tokens/${receipt}`;
          const response = await authClient.request({url});

          if (response.data && response.data.expiryTimeMillis) {
            isValid = true;
            expiryDate = new Date(parseInt(response.data.expiryTimeMillis));
          }
        } else if (platform === "ios") {
          const isSandbox = (process.env.FUNCTIONS_EMULATOR === "true");
          const url = isSandbox ? "https://sandbox.itunes.apple.com/verifyReceipt" : "https://buy.itunes.apple.com/verifyReceipt";

          const response = await axios.post(url, {"receipt-data": receipt});

          if (response.data && response.data.status === 0 && response.data.latest_receipt_info) {
            const latestTransaction = response.data.latest_receipt_info[0];
            isValid = true;
            expiryDate = new Date(parseInt(latestTransaction.expires_date_ms));
          }
        }
      } catch (error) {
        const errorMessage = (error.response && error.response.data) || error.message;
        console.error("Purchase verification failed:", errorMessage);
        throw new HttpsError("internal", "Verification request failed.");
      }

      if (isValid) {
        await admin.firestore().collection("users").doc(uid).set({
          isPremium: true,
          premiumUntil: admin.firestore.Timestamp.fromDate(expiryDate),
        }, {merge: true});

        console.log(
            `Successfully verified purchase for user ${uid}. ` +
            `Premium expires on ${expiryDate.toISOString()}`,
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

