plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.greentaxi.surucucheck"
    compileSdk = 35 // <-- BURANI DƏYİŞ
    defaultConfig {
        applicationId = "com.greentaxi.surucucheck.surucu_check"
        minSdk = 23
        targetSdk = 35 // <-- BURANI DƏYİŞ
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false // kodu kiçiltmək deaktiv
            isShrinkResources = false // resursu kiçiltmək deaktiv
        }
    }


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ... başqa dependensiyalar

    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.14.0"))

    // Firebase Authentication
    implementation("com.google.firebase:firebase-auth")
}
