# Flutter/Dart
-dontwarn io.flutter.embedding.**
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepnames class com.google.android.gms.measurement.AppMeasurement$ConditionalUserProperty { *; }

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Isar Database (isar_community)
# Critical: Prevents crashes due to obfuscation of database fields and annotations
-keep class io.isar.** { *; }
-keep @io.isar.annotation.Collection class * { *; }
-keepclassmembers class * {
    @io.isar.annotation.Id <fields>;
}
-keepattributes *Annotation*

# Flutter Secure Storage
# Critical: Prevents crashes when accessing secure storage for encryption keys
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# WorkManager (Background Tasks)
# Required for scheduled notifications and background sync
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker
-keepclassmembers class * extends androidx.work.Worker {
    public <init>(android.content.Context,androidx.work.WorkerParameters);
}

# Audio Players
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# Gson (used by Firebase and notifications)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer