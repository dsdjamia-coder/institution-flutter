plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sanjid_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.sanjid_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // --- മാറ്റങ്ങൾ വരുത്തിയത് ഇവിടെയാണ് ---
            
            // 1. കോഡ് ചുരുക്കാൻ (Minify) നിർദ്ദേശം നൽകുന്നു
            isMinifyEnabled = true
            
            // 2. ആവശ്യമില്ലാത്ത ചിത്രങ്ങളും ഫയലുകളും നീക്കം ചെയ്യുന്നു (Shrink)
            isShrinkResources = true
            
            // പ്രോഗാർഡ് നിയമങ്ങൾ (ഇത് സുരക്ഷയ്ക്കും സൈസ് കുറയ്ക്കാനും സഹായിക്കും)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // Signing config
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
