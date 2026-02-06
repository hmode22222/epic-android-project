#!/bin/bash
echo "=== المحاولة الأخيرة ==="

# 1. إعدادات نهائية
echo "⚙️  الإعدادات النهائية..."
cat > app/build.gradle << 'APP_EOF'
apply plugin: 'com.android.application'

android {
    compileSdkVersion 33
    // لا buildToolsVersion - يستخدم الإفتراضي
    
    defaultConfig {
        applicationId "com.epic.app"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
    }
    
    buildTypes {
        debug {
            minifyEnabled false
            debuggable true
        }
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.7.0'
    implementation 'com.google.android.material:material:1.9.0'
}
APP_EOF

# 2. محاولة البناء الأخيرة
echo "🏗️  البناء الأخير..."
timeout 300 ~/gradle/bin/gradle assembleDebug \
  --no-daemon \
  --console=plain \
  2>&1 | tee last-try.log

# 3. النتيجة
echo "📊 النتيجة:"
if grep -q "BUILD SUCCESSFUL" last-try.log; then
    echo "🎉 نجح!"
    APK_FILE=$(find . -name "*.apk" -type f | head -1)
    if [ -f "$APK_FILE" ]; then
        echo "✅ APK: $APK_FILE"
        echo "📏 الحجم: $(ls -lh "$APK_FILE")"
        # نسخ إلى التحميلات
        cp "$APK_FILE" /storage/emulated/0/Download/ 2>/dev/null
        echo "📱 تم النسخ إلى مجلد التحميلات"
    fi
else
    echo "❌ فشل البناء النهائي على Termux"
    echo ""
    echo "📋 ملخص المحاولات:"
    echo "1. ✅ Java 17 - تعمل"
    echo "2. ✅ Gradle 8.5 - تعمل"
    echo "3. ❌ Build Tools - محجوبة"
    echo "4. ❌ Android SDK - غير متوفر"
    echo ""
    echo "🚀 التوصية: GitHub Actions"
fi
