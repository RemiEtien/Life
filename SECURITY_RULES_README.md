# 🔐 Firestore & Storage Security Rules

**Last Updated:** October 2, 2025
**Version:** 2.0 (Production Ready)

---

## 📋 Overview

This document describes the security rules for Lifeline's Firestore database and Firebase Storage. These rules ensure that:

- ✅ Users can only access their own data
- ✅ Data validation prevents malformed documents
- ✅ File size limits prevent abuse
- ✅ Rate limiting prevents spam (basic)
- ✅ All operations require authentication

---

## 🔥 Firestore Rules

### Protected Collections:

#### 1. `/users/{userId}`
**User Profiles**

- **Read:** Owner only
- **Create:** Owner only, once (with validation)
- **Update:** Owner only (prevents changing `createdAt`, `email` requires validation)
- **Delete:** ❌ Disabled (use Cloud Functions for soft delete)

**Validation:**
- `email`: string, required
- `displayName`: string, 1-100 chars, required
- `createdAt`: timestamp, required, immutable

#### 2. `/users/{userId}/memories/{memoryId}`
**User Memories**

- **Read:** Owner only
- **Create:** Owner only (with validation & rate limiting)
- **Update:** Owner only (prevents changing `userId`)
- **Delete:** Owner only

**Validation:**
- `userId`: string, must match auth user, required
- `createdAt`: timestamp, required
- `title`: string, max 500 chars, optional
- `content`: string, max 100KB, optional
- `isPinned`, `isPrivate`, `isDraft`: boolean, optional
- Document size: max 900KB

**Rate Limiting:**
- Prevents backdating (createdAt must be within last 5 minutes)

#### 3. `/users/{userId}/subscriptions/{subscriptionId}`
**Premium Subscriptions**

- **Read:** Owner only
- **Write:** ❌ Cloud Functions only (after IAP verification)

#### 4. `/public/{document}`
**Public Data (App config, announcements)**

- **Read:** All authenticated users
- **Write:** ❌ Cloud Functions only

---

## 🗄️ Storage Rules

### Protected Paths:

#### 1. `/users/{userId}/avatar.{jpg,png}`
**User Avatars**

- **Read:** All authenticated users (for future social features)
- **Write:** Owner only
- **File type:** image/*
- **Max size:** 10 MB

#### 2. `/users/{userId}/memories/{memoryId}/images/{imageId}`
**Memory Photos**

- **Read:** Owner only
- **Write:** Owner only
- **File type:** image/*
- **Max size:** 10 MB

#### 3. `/users/{userId}/memories/{memoryId}/thumbnails/{thumbId}`
**Image Thumbnails**

- **Read:** Owner only
- **Write:** Owner only
- **File type:** image/*
- **Max size:** 10 MB

#### 4. `/users/{userId}/memories/{memoryId}/videos/{videoId}`
**Memory Videos** (Premium Feature)

- **Read:** Owner only
- **Write:** Owner only
- **File type:** video/*
- **Max size:** 100 MB

#### 5. `/users/{userId}/memories/{memoryId}/audio/{audioId}`
**Audio Notes**

- **Read:** Owner only
- **Write:** Owner only
- **File type:** audio/*
- **Max size:** 25 MB

#### 6. `/users/{userId}/exports/{exportId}`
**PDF Exports**

- **Read:** Owner only
- **Write:** Owner only
- **File type:** application/pdf
- **Max size:** 20 MB

#### 7. `/users/{userId}/temp/{fileName}`
**Temporary Uploads** (auto-cleanup via Cloud Functions)

- **Read/Write/Delete:** Owner only
- **File types:** image/*, video/*, audio/*
- **Max sizes:** As per file type

---

## 🚀 Deployment Instructions

### Option 1: Firebase Console (Recommended for first deploy)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Rules** tab
4. Copy contents from `firestore.rules`
5. Click **Publish**
6. Navigate to **Storage** → **Rules** tab
7. Copy contents from `storage.rules`
8. Click **Publish**

### Option 2: Firebase CLI

```bash
# Login to Firebase
firebase login

# Initialize Firebase (if not done)
firebase init

# Deploy only rules
firebase deploy --only firestore:rules
firebase deploy --only storage:rules

# Deploy everything
firebase deploy
```

### Option 3: Automated CI/CD (GitHub Actions)

```yaml
# .github/workflows/deploy-rules.yml
name: Deploy Security Rules
on:
  push:
    branches: [main]
    paths:
      - 'firestore.rules'
      - 'storage.rules'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install -g firebase-tools
      - run: firebase deploy --only firestore:rules,storage:rules --token ${{ secrets.FIREBASE_TOKEN }}
```

---

## 🧪 Testing Security Rules

### Using Firebase Emulator:

```bash
# Install emulators
firebase init emulators

# Start emulators
firebase emulators:start

# Run tests (create test file first)
npm test
```

### Manual Testing Checklist:

#### Firestore:
- [ ] User can read own profile
- [ ] User cannot read other user's profile
- [ ] User can create profile with valid data
- [ ] User cannot create profile with invalid data (missing fields, wrong types)
- [ ] User cannot change `createdAt` on update
- [ ] User can create memory with valid data
- [ ] User cannot create memory with `userId` mismatch
- [ ] User cannot create memory with oversized content (>100KB)
- [ ] User cannot create memory with oversized document (>900KB)
- [ ] User can update own memory
- [ ] User can delete own memory
- [ ] User cannot access other user's memories

#### Storage:
- [ ] User can upload avatar (image, <10MB)
- [ ] User cannot upload non-image as avatar
- [ ] User cannot upload oversized avatar (>10MB)
- [ ] User can read other user's avatars
- [ ] User can upload memory images (<10MB)
- [ ] User cannot access other user's memory images
- [ ] User can upload videos (<100MB)
- [ ] User can upload audio (<25MB)
- [ ] User cannot upload oversized files

---

## ⚠️ Known Limitations

### Rate Limiting:
- **Current:** Basic check (createdAt within 5 minutes)
- **Limitation:** Can be bypassed by determined attacker
- **Solution:** Implement proper rate limiting in Cloud Functions

### File Type Validation:
- **Current:** MIME type check
- **Limitation:** MIME types can be spoofed
- **Solution:** Add server-side validation in Cloud Functions (check magic bytes)

### Quota Management:
- **Current:** Per-file size limits
- **Limitation:** No total storage quota per user
- **Solution:** Track storage usage in Firestore, enforce in Cloud Functions

### Data Sanitization:
- **Current:** Size and type validation only
- **Limitation:** No content scanning (XSS, malware, NSFW)
- **Solution:** Implement Cloud Functions with:
  - Text sanitization (remove scripts)
  - Image moderation (Cloud Vision API)
  - Virus scanning for uploads

---

## 🔄 Version History

### v2.0 (October 2, 2025) - Production Ready
- ✅ Added comprehensive validation functions
- ✅ Implemented rate limiting checks
- ✅ Added file size limits for all media types
- ✅ Added file type validation
- ✅ Protected critical fields from modification
- ✅ Added subscription protection (Cloud Functions only)
- ✅ Added public data collection
- ✅ Comprehensive documentation

### v1.0 (Previous) - MVP
- Basic authentication checks
- User isolation
- Simple read/write rules

---

## 📚 Resources

- [Firestore Security Rules Docs](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules Docs](https://firebase.google.com/docs/storage/security)
- [Security Rules Testing](https://firebase.google.com/docs/rules/unit-tests)
- [Best Practices](https://firebase.google.com/docs/rules/best-practices)

---

## 🆘 Troubleshooting

### "Permission Denied" errors:

1. **Check authentication:**
   ```dart
   final user = FirebaseAuth.instance.currentUser;
   print('User ID: ${user?.uid}'); // Should match path
   ```

2. **Check document path:**
   ```dart
   // Correct:
   db.collection('users').doc(userId).collection('memories').doc(memoryId)

   // Wrong:
   db.collection('memories').doc(memoryId) // Missing user path
   ```

3. **Check data validation:**
   ```dart
   // Ensure all required fields are present:
   final memory = {
     'userId': userId,  // Required
     'createdAt': FieldValue.serverTimestamp(), // Required
     'title': 'My Memory', // Optional but validated if present
   };
   ```

4. **Check file size before upload:**
   ```dart
   final file = File(path);
   final fileSize = await file.length();
   if (fileSize > 10 * 1024 * 1024) {
     print('File too large!');
     return;
   }
   ```

---

**For issues or questions, contact:** founder@theplacewelive.org
