#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "BUBKA_TOOLCHAIN_FAILED: line $LINENO (exit $?)" >&2' ERR
[[ $(uname -m) == x86_64 ]] || { echo 'Expected Linux x86_64'; exit 1; }
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y --no-install-recommends ca-certificates curl git unzip zip xz-utils libglu1-mesa openjdk-17-jdk-headless
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export FLUTTER_SUPPRESS_ANALYTICS=true DART_SUPPRESS_ANALYTICS=true
base="$HOME/.local/share/bubka"
export ANDROID_HOME="$base/android-sdk" ANDROID_SDK_ROOT="$base/android-sdk"
flutter_dir="$base/flutter-3.50.1"
mkdir -p "$base" "$ANDROID_HOME/cmdline-tools" "$HOME/.config/bubka"
tmp=$(mktemp -d "$base/install.XXXXXX")
trap 'rm -rf -- "$tmp"' EXIT
if [[ ! -x "$flutter_dir/bin/flutter" ]]; then
  [[ ! -e "$flutter_dir" ]] || { echo "Incomplete Flutter directory: $flutter_dir"; exit 1; }
  curl -fL --retry 3 -o "$tmp/flutter.tar.xz" https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.50.1-stable.tar.xz
  echo '4ad17fc8462fbcef2ba19ff4a78c0a16b7147fde1add8578e267ea62cdb92678  flutter.tar.xz' | (cd "$tmp" && sha256sum -c -)
  tar -xJf "$tmp/flutter.tar.xz" -C "$tmp"
  mv "$tmp/flutter" "$flutter_dir"
  rm "$tmp/flutter.tar.xz"
fi
if [[ ! -x "$ANDROID_HOME/cmdline-tools/22.0/bin/sdkmanager" ]]; then
  [[ ! -e "$ANDROID_HOME/cmdline-tools/22.0" ]] || { echo 'Incomplete Android command-line tools directory'; exit 1; }
  curl -fL --retry 3 -o "$tmp/android.zip" https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip
  echo '4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583  android.zip' | (cd "$tmp" && sha256sum -c -)
  unzip -q "$tmp/android.zip" -d "$tmp/android"
  mv "$tmp/android/cmdline-tools" "$ANDROID_HOME/cmdline-tools/22.0"
  rm "$tmp/android.zip"
fi
if [[ ! -e "$ANDROID_HOME/cmdline-tools/latest" && ! -L "$ANDROID_HOME/cmdline-tools/latest" ]]; then
  ln -s 22.0 "$ANDROID_HOME/cmdline-tools/latest"
fi
export PATH="$flutter_dir/bin:$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/22.0/bin:$ANDROID_HOME/platform-tools:$PATH"
flutter --disable-analytics
flutter --version
flutter config --android-sdk "$ANDROID_HOME" --jdk-dir "$JAVA_HOME"
# The initial setup is interactive; subsequent devcontainer rebuilds use the same accepted license choice.
# The outer script records explicit consent before executing this step.
# sdkmanager itself must succeed; SIGPIPE from yes is expected and not used as the result.
set +o pipefail
yes | sdkmanager --sdk_root="$ANDROID_HOME" --licenses
set -o pipefail
sdkmanager --sdk_root="$ANDROID_HOME" 'platform-tools' 'platforms;android-36' 'build-tools;36.0.0' 'ndk;28.2.13676358'
flutter precache --android
cat > "$HOME/.config/bubka/env.sh" <<'ENV'
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME="$HOME/.local/share/bubka/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export FLUTTER_SUPPRESS_ANALYTICS=true DART_SUPPRESS_ANALYTICS=true
export PATH="$HOME/.local/share/bubka/flutter-3.50.1/bin:$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/22.0/bin:$ANDROID_HOME/platform-tools:$PATH"
ENV
line='[ -f "$HOME/.config/bubka/env.sh" ] && . "$HOME/.config/bubka/env.sh"'
touch "$HOME/.bashrc"
if ! grep -Fxq "$line" "$HOME/.bashrc"; then printf '\n%s\n' "$line" >> "$HOME/.bashrc"; fi
printf '\n=== BUBKA: TOOL VERSIONS ===\n'
flutter --version
dart --version
java -version
sdkmanager --version
sdkmanager --sdk_root="$ANDROID_HOME" --list_installed
printf '\n=== BUBKA: FLUTTER DOCTOR ===\n'
# Doctor may report irrelevant missing iOS, Chrome, desktop or emulator tools.
set +e
flutter --no-color doctor -v 2>&1 | tee "$tmp/doctor.log"
doctor_status=${PIPESTATUS[0]}
set -e
printf 'flutter doctor exit status: %s\n' "$doctor_status"
if ! grep -Eq '^\[✓\] Flutter ' "$tmp/doctor.log" || ! grep -Eq '^\[✓\] Android toolchain' "$tmp/doctor.log"; then
  echo 'BUBKA_SETUP_FAILED: Flutter or Android toolchain not healthy.' >&2; exit 1
fi
printf '\nBUBKA_SETUP_OK\n'
