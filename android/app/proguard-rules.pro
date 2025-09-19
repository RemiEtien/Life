# Flutter/Dart
-dontwarn io.flutter.embedding.**
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepnames class com.google.android.gms.measurement.AppMeasurement$ConditionalUserProperty { *; }

# Правила для плагина flutter_local_notifications, которые исправят вашу ошибку
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken