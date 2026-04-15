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

android {
    namespace = "com.lurebox.lurebox"
    compileSdk = 35
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
        versionCode = project.property("flutter.versionCode").toString().toInt()
        versionName = project.property("flutter.versionName").toString()
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
