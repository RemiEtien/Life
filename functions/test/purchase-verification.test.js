/**
 * Unit tests for purchase verification logic
 *
 * These tests validate the business logic for verifying purchases
 * from App Store and Google Play. They focus on edge cases and
 * security vulnerabilities.
 */

const crypto = require('crypto');

/**
 * Helper function to generate receipt hash
 * (Mirrors the implementation in index.js line 279)
 */
function generateReceiptHash(receipt) {
  return crypto.createHash('sha256').update(receipt).digest('hex');
}

/**
 * Product ID validation
 */
function isValidProductId(productId) {
  const VALID_PRODUCT_IDS = ['lifeline_premium_monthly', 'lifeline_premium_yearly'];
  return VALID_PRODUCT_IDS.includes(productId);
}

/**
 * Android purchase validation logic
 * Returns: { isValid: boolean, reason?: string, expiryDate?: Date }
 */
function validateAndroidPurchase(purchaseData) {
  if (!purchaseData || !purchaseData.expiryTimeMillis) {
    return { isValid: false, reason: 'Missing expiry time' };
  }

  const expiryTimestamp = parseInt(purchaseData.expiryTimeMillis);
  const isExpired = expiryTimestamp <= Date.now();
  const isPurchaseStateValid = purchaseData.purchaseState === 0; // 0 = PURCHASED
  const isAcknowledged = purchaseData.acknowledgementState === 1; // 1 = ACKNOWLEDGED

  if (isExpired) {
    return { isValid: false, reason: 'Purchase expired' };
  }

  if (!isPurchaseStateValid) {
    return { isValid: false, reason: `Invalid purchase state: ${purchaseData.purchaseState}` };
  }

  if (!isAcknowledged) {
    return { isValid: false, reason: `Not acknowledged: ${purchaseData.acknowledgementState}` };
  }

  return {
    isValid: true,
    expiryDate: new Date(expiryTimestamp),
    transactionId: purchaseData.orderId
  };
}

/**
 * iOS purchase validation logic
 * Returns: { isValid: boolean, reason?: string, expiryDate?: Date }
 */
function validateIOSPurchase(receiptData, productId) {
  const expectedBundleId = 'com.momentic.lifeline';

  if (!receiptData || !receiptData.receipt) {
    return { isValid: false, reason: 'Missing receipt data' };
  }

  if (receiptData.receipt.bundle_id !== expectedBundleId) {
    return { isValid: false, reason: `Invalid bundle ID: ${receiptData.receipt.bundle_id}` };
  }

  if (!receiptData.latest_receipt_info || receiptData.latest_receipt_info.length === 0) {
    return { isValid: false, reason: 'No receipt info' };
  }

  // Filter by productId and sort by expiry date (most recent first)
  const sortedReceipts = receiptData.latest_receipt_info
    .filter((t) => t.product_id === productId)
    .sort((a, b) => parseInt(b.expires_date_ms) - parseInt(a.expires_date_ms));

  const latestTransaction = sortedReceipts.length > 0 ? sortedReceipts[0] : null;

  if (!latestTransaction || !latestTransaction.expires_date_ms) {
    return { isValid: false, reason: 'No matching transaction found' };
  }

  const expiryTimestamp = parseInt(latestTransaction.expires_date_ms);
  if (expiryTimestamp <= Date.now()) {
    return { isValid: false, reason: 'Transaction expired' };
  }

  return {
    isValid: true,
    expiryDate: new Date(expiryTimestamp),
    transactionId: latestTransaction.transaction_id
  };
}

// ============================================================================
// TESTS
// ============================================================================

describe('Purchase Verification Tests', () => {
  describe('Receipt Hash Generation', () => {
    test('generates consistent SHA-256 hash for same receipt', () => {
      const receipt = 'test-receipt-data-12345';
      const hash1 = generateReceiptHash(receipt);
      const hash2 = generateReceiptHash(receipt);

      expect(hash1).toBe(hash2);
      expect(hash1).toHaveLength(64); // SHA-256 produces 64 hex characters
    });

    test('generates different hashes for different receipts', () => {
      const receipt1 = 'receipt-1';
      const receipt2 = 'receipt-2';

      const hash1 = generateReceiptHash(receipt1);
      const hash2 = generateReceiptHash(receipt2);

      expect(hash1).not.toBe(hash2);
    });

    test('prevents hash collisions from substring approach', () => {
      // In the old implementation (substring(0,100)), these could collide:
      const longReceipt1 = 'A'.repeat(100) + 'B';
      const longReceipt2 = 'A'.repeat(100) + 'C';

      const hash1 = generateReceiptHash(longReceipt1);
      const hash2 = generateReceiptHash(longReceipt2);

      // With SHA-256, they should NOT collide
      expect(hash1).not.toBe(hash2);
    });

    test('handles empty receipt', () => {
      const hash = generateReceiptHash('');
      expect(hash).toHaveLength(64);
      // Empty string SHA-256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
      expect(hash).toBe('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
    });

    test('handles unicode characters in receipt', () => {
      const receipt = '🎉 Premium Purchase 🎊';
      const hash = generateReceiptHash(receipt);
      expect(hash).toHaveLength(64);
    });
  });

  describe('Product ID Validation', () => {
    test('accepts valid monthly product ID', () => {
      expect(isValidProductId('lifeline_premium_monthly')).toBe(true);
    });

    test('accepts valid yearly product ID', () => {
      expect(isValidProductId('lifeline_premium_yearly')).toBe(true);
    });

    test('rejects invalid product ID', () => {
      expect(isValidProductId('invalid_product')).toBe(false);
      expect(isValidProductId('lifeline_premium_lifetime')).toBe(false);
      expect(isValidProductId('')).toBe(false);
      expect(isValidProductId(null)).toBe(false);
      expect(isValidProductId(undefined)).toBe(false);
    });

    test('is case-sensitive', () => {
      expect(isValidProductId('LIFELINE_PREMIUM_MONTHLY')).toBe(false);
      expect(isValidProductId('Lifeline_Premium_Monthly')).toBe(false);
    });

    test('rejects SQL injection attempts', () => {
      expect(isValidProductId("lifeline_premium_monthly' OR '1'='1")).toBe(false);
      expect(isValidProductId('lifeline_premium_monthly; DROP TABLE users;')).toBe(false);
    });
  });

  describe('Android Purchase Validation', () => {
    const futureTime = Date.now() + 30 * 24 * 60 * 60 * 1000; // 30 days from now

    test('validates correct Android purchase', () => {
      const purchaseData = {
        expiryTimeMillis: futureTime.toString(),
        purchaseState: 0, // PURCHASED
        acknowledgementState: 1, // ACKNOWLEDGED
        orderId: 'GPA.1234-5678-9012-34567'
      };

      const result = validateAndroidPurchase(purchaseData);

      expect(result.isValid).toBe(true);
      expect(result.expiryDate).toBeInstanceOf(Date);
      expect(result.expiryDate.getTime()).toBe(futureTime);
      expect(result.transactionId).toBe('GPA.1234-5678-9012-34567');
    });

    test('rejects expired Android purchase', () => {
      const pastTime = Date.now() - 24 * 60 * 60 * 1000; // 1 day ago

      const purchaseData = {
        expiryTimeMillis: pastTime.toString(),
        purchaseState: 0,
        acknowledgementState: 1,
        orderId: 'GPA.1234-5678-9012-34567'
      };

      const result = validateAndroidPurchase(purchaseData);

      expect(result.isValid).toBe(false);
      expect(result.reason).toBe('Purchase expired');
    });

    test('rejects Android purchase with invalid purchase state', () => {
      const purchaseData = {
        expiryTimeMillis: futureTime.toString(),
        purchaseState: 1, // 1 = CANCELLED
        acknowledgementState: 1,
        orderId: 'GPA.1234-5678-9012-34567'
      };

      const result = validateAndroidPurchase(purchaseData);

      expect(result.isValid).toBe(false);
      expect(result.reason).toContain('Invalid purchase state');
    });

    test('rejects unacknowledged Android purchase', () => {
      const purchaseData = {
        expiryTimeMillis: futureTime.toString(),
        purchaseState: 0,
        acknowledgementState: 0, // NOT ACKNOWLEDGED
        orderId: 'GPA.1234-5678-9012-34567'
      };

      const result = validateAndroidPurchase(purchaseData);

      expect(result.isValid).toBe(false);
      expect(result.reason).toContain('Not acknowledged');
    });

    test('rejects Android purchase with missing expiry time', () => {
      const purchaseData = {
        purchaseState: 0,
        acknowledgementState: 1,
        orderId: 'GPA.1234-5678-9012-34567'
        // expiryTimeMillis is missing
      };

      const result = validateAndroidPurchase(purchaseData);

      expect(result.isValid).toBe(false);
      expect(result.reason).toBe('Missing expiry time');
    });

    test('rejects null Android purchase data', () => {
      const result = validateAndroidPurchase(null);

      expect(result.isValid).toBe(false);
      expect(result.reason).toBe('Missing expiry time');
    });

    test('handles Android purchase expiring exactly now', () => {
      const now = Date.now();

      const purchaseData = {
        expiryTimeMillis: now.toString(),
        purchaseState: 0,
        acknowledgementState: 1,
        orderId: 'GPA.1234-5678-9012-34567'
      };

      const result = validateAndroidPurchase(purchaseData);

      // Should be invalid (expired) since the condition is <=
      expect(result.isValid).toBe(false);
      expect(result.reason).toBe('Purchase expired');
    });
  });

  describe('iOS Purchase Validation', () => {
    const futureTime = Date.now() + 30 * 24 * 60 * 60 * 1000; // 30 days from now
    const productId = 'lifeline_premium_monthly';

    test('validates correct iOS purchase', () => {
      const receiptData = {
        receipt: {
          bundle_id: 'com.momentic.lifeline'
        },
        latest_receipt_info: [
          {
            product_id: 'lifeline_premium_monthly',
            expires_date_ms: futureTime.toString(),
            transaction_id: '1000000123456789'
          }
        ]
      };

      const result = validateIOSPurchase(receiptData, productId);

      expect(result.isValid).toBe(true);
      expect(result.expiryDate).toBeInstanceOf(Date);
      expect(result.expiryDate.getTime()).toBe(futureTime);
      expect(result.transactionId).toBe('1000000123456789');
    });

    test('rejects iOS purchase with wrong bundle ID', () => {
      const receiptData = {
        receipt: {
          bundle_id: 'com.malicious.app'
        },
        latest_receipt_info: [
          {
            product_id: productId,
            expires_date_ms: futureTime.toString(),
            transaction_id: '1000000123456789'
          }
        ]
      };

      const result = validateIOSPurchase(receiptData, productId);

      expect(result.isValid).toBe(false);
      expect(result.reason).toContain('Invalid bundle ID');
    });

    test('rejects expired iOS purchase', () => {
      const pastTime = Date.now() - 24 * 60 * 60 * 1000; // 1 day ago

      const receiptData = {
        receipt: {
          bundle_id: 'com.momentic.lifeline'
        },
        latest_receipt_info: [
          {
            product_id: productId,
            expires_date_ms: pastTime.toString(),
            transaction_id: '1000000123456789'
          }
        ]
      };

      const result = validateIOSPurchase(receiptData, productId);

      expect(result.isValid).toBe(false);
      expect(result.reason).toBe('Transaction expired');
    });

    test('filters iOS receipts by product ID', () => {
      const receiptData = {
        receipt: {
          bundle_id: 'com.momentic.lifeline'
        },
        latest_receipt_info: [
          {
            product_id: 'lifeline_premium_yearly', // Different product
            expires_date_ms: futureTime.toString(),
            transaction_id: '1000000111111111'
          },
          {
            product_id: 'lifeline_premium_monthly', // Correct product
            expires_date_ms: futureTime.toString(),
            transaction_id: '1000000123456789'
          }
        ]
      };

      const result = validateIOSPurchase(receiptData, 'lifeline_premium_monthly');

      expect(result.isValid).toBe(true);
      expect(result.transactionId).toBe('1000000123456789');
    });

    test('selects most recent iOS transaction', () => {
      const olderTime = Date.now() + 7 * 24 * 60 * 60 * 1000; // 7 days
      const newerTime = Date.now() + 30 * 24 * 60 * 60 * 1000; // 30 days

      const receiptData = {
        receipt: {
          bundle_id: 'com.momentic.lifeline'
        },
        latest_receipt_info: [
          {
            product_id: productId,
            expires_date_ms: olderTime.toString(),
            transaction_id: 'OLDER'
          },
          {
            product_id: productId,
            expires_date_ms: newerTime.toString(),
            transaction_id: 'NEWER'
          }
        ]
      };

      const result = validateIOSPurchase(receiptData, productId);

      expect(result.isValid).toBe(true);
      expect(result.transactionId).toBe('NEWER');
      expect(result.expiryDate.getTime()).toBe(newerTime);
    });

    test('rejects iOS purchase with no matching product', () => {
      const receiptData = {
        receipt: {
          bundle_id: 'com.momentic.lifeline'
        },
        latest_receipt_info: [
          {
            product_id: 'lifeline_premium_yearly',
            expires_date_ms: futureTime.toString(),
            transaction_id: '1000000123456789'
          }
        ]
      };

      const result = validateIOSPurchase(receiptData, 'lifeline_premium_monthly');

      expect(result.isValid).toBe(false);
      expect(result.reason).toBe('No matching transaction found');
    });

    test('rejects iOS purchase with empty receipt info', () => {
      const receiptData = {
        receipt: {
          bundle_id: 'com.momentic.lifeline'
        },
        latest_receipt_info: []
      };

      const result = validateIOSPurchase(receiptData, productId);

      expect(result.isValid).toBe(false);
      expect(result.reason).toBe('No receipt info');
    });

    test('rejects iOS purchase with missing receipt data', () => {
      const result = validateIOSPurchase({}, productId);

      expect(result.isValid).toBe(false);
      expect(result.reason).toBe('Missing receipt data');
    });
  });

  describe('Security & Edge Cases', () => {
    test('receipt hash is deterministic across runs', () => {
      const receipt = 'production-receipt-12345-abcde';
      const hashes = [];

      for (let i = 0; i < 100; i++) {
        hashes.push(generateReceiptHash(receipt));
      }

      // All hashes should be identical
      expect(new Set(hashes).size).toBe(1);
    });

    test('very long receipt string does not cause issues', () => {
      const longReceipt = 'A'.repeat(10000);
      const hash = generateReceiptHash(longReceipt);

      expect(hash).toHaveLength(64);
      expect(typeof hash).toBe('string');
    });

    test('Android purchase with string timestamp works', () => {
      const futureTime = (Date.now() + 30 * 24 * 60 * 60 * 1000).toString();

      const purchaseData = {
        expiryTimeMillis: futureTime,
        purchaseState: 0,
        acknowledgementState: 1,
        orderId: 'GPA.1234'
      };

      const result = validateAndroidPurchase(purchaseData);
      expect(result.isValid).toBe(true);
    });

    test('iOS purchase with multiple expired and one valid transaction', () => {
      const pastTime1 = Date.now() - 60 * 24 * 60 * 60 * 1000;
      const pastTime2 = Date.now() - 30 * 24 * 60 * 60 * 1000;
      const futureTime = Date.now() + 30 * 24 * 60 * 60 * 1000;

      const receiptData = {
        receipt: {
          bundle_id: 'com.momentic.lifeline'
        },
        latest_receipt_info: [
          {
            product_id: 'lifeline_premium_monthly',
            expires_date_ms: pastTime1.toString(),
            transaction_id: 'EXPIRED_1'
          },
          {
            product_id: 'lifeline_premium_monthly',
            expires_date_ms: pastTime2.toString(),
            transaction_id: 'EXPIRED_2'
          },
          {
            product_id: 'lifeline_premium_monthly',
            expires_date_ms: futureTime.toString(),
            transaction_id: 'VALID'
          }
        ]
      };

      const result = validateIOSPurchase(receiptData, 'lifeline_premium_monthly');

      expect(result.isValid).toBe(true);
      expect(result.transactionId).toBe('VALID');
    });
  });
});
