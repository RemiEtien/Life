# Receipt Replay Attack Fix - Documentation

## 🔴 CRITICAL Security Issue - FIXED

**Issue**: Receipt replay attack vulnerability in Cloud Functions purchase verification
**Severity**: CRITICAL
**Status**: ✅ FIXED

---

## Problem Description

The `verifyPurchase` Cloud Function did not store or check previously used receipts, allowing the same receipt to be verified multiple times. This created several attack vectors:

### Attack Scenarios:
1. **Self-replay**: A user could purchase once, get the receipt, and call `verifyPurchase` repeatedly to extend their premium status indefinitely
2. **Receipt sharing**: Users could share receipts with others who could then activate premium features without paying
3. **Refund fraud**: A user could get a refund but continue using the already-verified receipt

### Business Impact:
- Revenue loss from fraudulent premium activations
- Potential App Store/Play Store policy violations
- Unfair advantage for malicious users

---

## Solution Implemented

### Receipt Deduplication System

We now store every successfully verified receipt in a Firestore collection `used_receipts` and check against it before processing new verification requests.

### Key Changes:

#### 1. **Receipt Hash Generation** (functions/index.js:200-201)
```javascript
const receiptHash = Buffer.from(receipt).toString("base64").substring(0, 100);
const receiptRef = admin.firestore().collection("used_receipts").doc(receiptHash);
```

#### 2. **Replay Detection** (functions/index.js:203-208)
```javascript
const receiptDoc = await receiptRef.get();
if (receiptDoc.exists) {
  const existingData = receiptDoc.data();
  console.warn(`Receipt replay attempt detected. Receipt already used by user ${existingData.userId} at ${existingData.usedAt.toDate().toISOString()}`);
  throw new HttpsError("already-exists", "This receipt has already been used.");
}
```

#### 3. **Transaction ID Tracking**
- **Android**: Capture `purchase.orderId` (line 237)
- **iOS**: Capture `latestTransaction.transaction_id` (line 282)

#### 4. **Receipt Storage After Verification** (functions/index.js:311-320)
```javascript
await receiptRef.set({
  userId: uid,
  productId: productId,
  platform: platform,
  transactionId: transactionId,
  usedAt: admin.firestore.FieldValue.serverTimestamp(),
  expiryDate: admin.firestore.Timestamp.fromDate(expiryDate),
});
```

#### 5. **Firestore Security Rules** (firestore.rules:89-93)
```javascript
match /used_receipts/{receiptHash} {
  // Users cannot read or write directly
  // Only Cloud Functions can access this collection
  allow read, write: if false;
}
```

---

## Files Modified

1. **functions/index.js**
   - Lines 199-209: Receipt deduplication check
   - Line 213: Added transactionId variable
   - Line 237: Capture Android orderId
   - Line 282: Capture iOS transaction_id
   - Lines 311-320: Store used receipt in Firestore
   - Line 329: Enhanced logging with transactionId

2. **firestore.rules**
   - Lines 85-93: Added security rules for `used_receipts` collection

---

## Deployment Instructions

### 1. Deploy Cloud Functions

```bash
cd functions
npm install  # Ensure dependencies are up to date
firebase deploy --only functions
```

### 2. Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### 3. Verify Deployment

```bash
firebase functions:log --only verifyPurchase
```

Look for log messages like:
- ✅ `Successfully verified purchase for user {uid}. Premium expires on {date}. TransactionId: {id}`
- ⚠️ `Receipt replay attempt detected. Receipt already used by user {uid} at {timestamp}`

---

## Testing the Fix

### Test Case 1: Normal Purchase (Should Succeed)
1. User makes a legitimate purchase
2. App calls `verifyPurchase` with the receipt
3. ✅ Function verifies with Apple/Google, marks user as premium, stores receipt

### Test Case 2: Replay Attack (Should Fail)
1. User attempts to verify the same receipt again
2. App calls `verifyPurchase` with the same receipt
3. ❌ Function immediately rejects with error: `"This receipt has already been used."`
4. Logs warning: `Receipt replay attempt detected...`

### Test Case 3: Receipt Sharing (Should Fail)
1. User A verifies receipt successfully
2. User A shares receipt with User B
3. User B attempts to verify the same receipt
4. ❌ Function rejects with error: `"This receipt has already been used."`
5. Logs show original user A and timestamp

---

## Monitoring & Analytics

### Key Metrics to Track:

1. **Replay Attempt Rate**
   - Filter logs for: `"Receipt replay attempt detected"`
   - High rate may indicate coordinated attack or receipt sharing rings

2. **Transaction ID Logging**
   - All verifications now log `transactionId` for better tracking
   - Can correlate with App Store/Play Console data

3. **User Patterns**
   - Multiple replay attempts from same user = potential fraudster
   - Multiple users with same receipt = receipt sharing

### Firestore Console Queries:

```javascript
// Find all used receipts by a specific user
db.collection('used_receipts')
  .where('userId', '==', 'USER_ID_HERE')
  .orderBy('usedAt', 'desc')
  .get()

// Find receipts used in last 24 hours
const yesterday = new Date(Date.now() - 24*60*60*1000);
db.collection('used_receipts')
  .where('usedAt', '>', yesterday)
  .get()
```

---

## Data Retention Considerations

### Current Implementation:
- Receipts are stored indefinitely
- Storage cost: ~1KB per receipt = minimal cost even at scale

### Future Enhancement (Optional):
Consider implementing TTL (Time-To-Live) cleanup:
- Delete receipts after subscription expiry + grace period (e.g., 30 days)
- Use Cloud Scheduler + Cloud Function for cleanup
- Reduces storage costs for long-term operation

Example cleanup query:
```javascript
const thirtyDaysAgo = new Date(Date.now() - 30*24*60*60*1000);
db.collection('used_receipts')
  .where('expiryDate', '<', thirtyDaysAgo)
  .get()
  .then(snapshot => {
    snapshot.forEach(doc => doc.ref.delete());
  });
```

---

## Additional Security Recommendations

Based on the comprehensive audit, consider implementing:

1. **Rate Limiting** (HIGH Priority)
   - Limit verifyPurchase calls to 5 per user per hour
   - Prevents brute-force receipt testing

2. **Field Validation in Firestore Rules** (HIGH Priority)
   - Re-add basic validation for user profile fields
   - Prevent malicious data injection

3. **Webhook Integration** (MEDIUM Priority)
   - Implement Apple App Store Server Notifications
   - Implement Google Play Developer Notifications
   - Automatically track refunds, renewals, cancellations

4. **Purchase Retry Logic** (MEDIUM Priority)
   - Store pending purchases client-side
   - Retry failed verifications
   - Don't complete purchase until verification succeeds

---

## Support & Troubleshooting

### Error: "This receipt has already been used"

**Legitimate Scenario**: User reinstalled app and trying to restore purchase
**Solution**: Implement a restore purchase flow that:
1. Checks user's `isPremium` and `premiumUntil` in Firestore
2. If still valid, restore premium status client-side without re-verifying receipt
3. Only verify new receipts (new purchases or renewals)

### Error: "Verification request failed"

**Possible Causes**:
- Apple/Google API is down
- Invalid receipt format
- Network timeout

**Solution**: Check Cloud Functions logs for detailed error messages

---

## Version History

- **v1.0 (2025-10-03)**: Initial receipt replay attack fix implemented
  - Receipt deduplication system
  - Transaction ID tracking
  - Firestore security rules
  - Comprehensive logging

---

## Related Documentation

- [FIRESTORE_RULES_FIX.md](./FIRESTORE_RULES_FIX.md) - Firestore rules simplification
- [SECURITY_RULES_README.md](./SECURITY_RULES_README.md) - Security rules overview
- [RELEASE_CHECKLIST.md](./RELEASE_CHECKLIST.md) - Release process

---

**Author**: Claude Code
**Date**: 2025-10-03
**Severity**: CRITICAL → ✅ RESOLVED
