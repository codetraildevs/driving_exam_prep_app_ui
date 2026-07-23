import java.util.Properties

plugins {
    id("com.android.application")
    // Kotlin-android is applied by the Flutter Gradle Plugin internally.
    // Removed explicit declaration per Flutter's KGP migration guide:
    // https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.trafficrules.rwanda.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.trafficrules.rwanda.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Note: NDK abiFilters would go here, but they only affect plugin-native code,
        // NOT the Flutter engine .so files. The reliable way to build a single-ABI APK
        // is via the CLI flag:  flutter build apk --release --target-platform android-arm64
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { 
                rootProject.file("app/$it")
            }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            // Enable code shrinking, obfuscation, and resource optimization.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// Kotlin JVM target — migrated from deprecated kotlinOptions per Flutter's
// built-in Kotlin migration guide:
// https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
