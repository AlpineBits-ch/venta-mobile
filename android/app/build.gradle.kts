plugins {
    id("com.android.application")
    // file_picker and flutter_webrtc still self-apply the classic Kotlin
    // Gradle Plugin instead of using Flutter's built-in Kotlin support,
    // which breaks GeneratedPluginRegistrant's Java->Kotlin classpath
    // ordering unless the app module applies it too.
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "gg.venta.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications requires this.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "gg.venta.mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Push notifications (firebase_messaging) need this applied, which in turn
// needs google-services.json — see docs/native-call-push-backend-spec.md.
// Applied conditionally so the build stays green (no FCM push, but otherwise
// unaffected) for anyone who hasn't dropped that file in yet.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

flutter {
    source = "../.."
}
