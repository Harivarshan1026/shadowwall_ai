-keep class io.flutter.embedding.** { *; }
-keep class com.shadowwall.ai.** { *; }
-keep class com.example.shadowwall_ai.** { *; }

# Keep MethodChannel native method handlers
-keepclasseswithmembers class * {
    native <methods>;
}

# FreeRASP / Talsec
-keep class com.aheadroots.freerasp.** { *; }
-keep class com.talsec.freerasp.** { *; }

# MLKit Text Recognition optional language modules
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# TensorFlow Lite GPU Delegate optional classes
-dontwarn org.tensorflow.lite.gpu.**

# Google Play Core & Deferred Components (Optional Flutter features)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Google Play Services
-dontwarn com.google.android.gms.**
