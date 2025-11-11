# Flutter rules are compiled into the JAR file already.
# You can add your own rules here.

# Firebase SDK
-keep class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# OkHttp
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
-dontwarn okhttp3.**

# Other common rules
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.common.util.concurrent.internal.InternalFutureFailureAccess
-keep class com.google.common.util.concurrent.internal.InternalFutures
-if class-path-for-name "androidx.window.extensions.WindowExtensionsProvider"
-keep class androidx.window.extensions.WindowExtensionsProvider
-if class-path-for-name "androidx.window.sidecar.SidecarProvider"
-keep class androidx.window.sidecar.SidecarProvider
