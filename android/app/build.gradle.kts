import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = File(rootProject.rootDir.parent, "local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use { localProperties.load(it) }
}

// Read version from pubspec.yaml
val pubspecFile = File(rootProject.rootDir.parent, "pubspec.yaml")
val pubspecVersion = pubspecFile.readLines()
    .firstOrNull { it.trimStart().startsWith("version:") }
    ?.substringAfter("version:")?.trim() ?: "1.0.0"
val versionParts = pubspecVersion.split("+")
val flutterVersionName = versionParts.getOrElse(0) { "1.0.0" }
val flutterVersionCode = versionParts.getOrElse(1) { "1" }.toIntOrNull() ?: 1

android {
    namespace = "com.lurebox.lurebox"
    compileSdk = 36
    ndkVersion = "26.1.10909125"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.lurebox.lurebox"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(File(rootProject.rootDir.parent, "android/app/${localProperties["keystore.file"]}"))
            storePassword = localProperties["keystore.password"].toString()
            keyAlias = localProperties["key.alias"].toString()
            keyPassword = localProperties["key.password"].toString()
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}
