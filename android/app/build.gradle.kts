import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeyFile = rootProject.file("key.properties")
val releaseKeys = Properties().apply {
    if (releaseKeyFile.exists()) releaseKeyFile.inputStream().use { load(it) }
}
val hasReleaseKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    .all { !releaseKeys.getProperty(it).isNullOrBlank() }
val allowUnsignedRelease = providers.gradleProperty("jawwidAllowUnsignedRelease")
    .map { it == "true" }.getOrElse(false)

android {
    namespace = "app.rattil.rattil"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications (daily reminder).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.jawwid.jawwid"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeys) {
            create("production") {
                storeFile = rootProject.file(releaseKeys.getProperty("storeFile"))
                storePassword = releaseKeys.getProperty("storePassword")
                keyAlias = releaseKeys.getProperty("keyAlias")
                keyPassword = releaseKeys.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeys) signingConfigs.getByName("production") else null
        }
    }
}

gradle.taskGraph.whenReady {
    val packagesRelease = allTasks.any {
        it.project == project && it.name in listOf("packageRelease", "packageReleaseBundle", "bundleRelease")
    }
    if (packagesRelease && !hasReleaseKeys && !allowUnsignedRelease) {
        throw GradleException("Production signing is missing. Configure android/key.properties. " +
            "For an unsigned local artifact only, set -PjawwidAllowUnsignedRelease=true. " +
            "Release builds never use the debug key.")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
