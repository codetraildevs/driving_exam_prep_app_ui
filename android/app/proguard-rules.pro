## Flutter-specific ProGuard rules

# Keep only Flutter entry points referenced by the embedding; let R8 shrink the rest.
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Keep androidx.activity.EdgeToEdge so Play Console's static check detects edge-to-edge
-keep class androidx.activity.EdgeToEdge { *; }

# Gson (only if used by plugins)
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

# Optimize: strip unused debug info from release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
