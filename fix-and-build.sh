#!/bin/bash
echo "=== إصلاح وبناء مشروع EPIC ==="

# 1. إصلاح library module
echo "🔧 إصلاح library module..."
if [ -f "library/build.gradle" ]; then
    # إزالة bintray-publish plugin
    sed -i "/com.github.panpf.bintray-publish/d" library/build.gradle
    
    # إزالة أي bintray أو publish configurations
    sed -i '/bintrayPublish/,/^}/d' library/build.gradle 2>/dev/null
    sed -i '/publishing/,/^}/d' library/build.gradle 2>/dev/null
    sed -i '/bintray/,/^}/d' library/build.gradle 2>/dev/null
    
    echo "✅ تم إصلاح library"
fi

# 2. تحديث build.gradle الرئيسي
echo "📦 تحديث build.gradle..."
cat > build.gradle << 'BUILD_EOF'
buildscript {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/central' }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
        classpath 'com.google.gms:google-services:4.3.15'
    }
}

allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/central' }
        google()
        mavenCentral()
    }
}
BUILD_EOF

# 3. البناء
echo "🏗️  بدء البناء..."
timeout 300 ~/gradle/bin/gradle assembleDebug \
  --no-daemon \
  --console=plain \
  2>&1 | tee epic-build.log

# 4. النتيجة
echo "📊 النتيجة:"
if grep -q "BUILD SUCCESSFUL" epic-build.log; then
    echo "🎉 ✅ البناء نجح!"
    find . -name "*.apk" -type f 2>/dev/null
else
    echo "❌ البناء فشل"
    echo "🔍 الأخطاء:"
    grep -i "error\|fail\|exception\|plugin" epic-build.log | head -10
fi
