#!/bin/bash
# سكريبت يمنع daemon نهائياً
export GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# حذف مجلد daemon
rm -rf ~/.gradle/daemon

# استخدام Java مباشرة
JAVA_CMD="/data/data/com.termux/files/usr/lib/jvm/java-17-openjdk/bin/java"
GRADLE_JAR="$HOME/gradle/lib/gradle-launcher-8.5.jar"

echo "🏗️  البناء بدون Daemon..."
$JAVA_CMD \
  -Dgradle.user.home=$HOME/.gradle \
  -Dorg.gradle.daemon=false \
  -Dorg.gradle.parallel=false \
  -jar "$GRADLE_JAR" \
  assembleDebug \
  --console=plain \
  2>&1 | tee direct-build.log

echo "📊 النتيجة:"
grep -i "BUILD" direct-build.log | tail -5
