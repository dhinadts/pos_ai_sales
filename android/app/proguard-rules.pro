# keep firebase + google classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# keep flutter plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# keep go_router (reflection)
-keep class com.ryanheise.** { *; }
-keep class io.github.** { *; }

# for json serializable models (if any)
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
