## Flutter-specific ProGuard rules

# Keep Flutter engine and plugin classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Keep Gson / JSON serialization if used by plugins
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# OkHttp / HTTP client (used by some plugins)
-dontwarn okhttp3.**
-dontwarn okio.**

# Prevent stripping of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Suppress warnings for Play Core (deferred components – not used but referenced by Flutter engine)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
