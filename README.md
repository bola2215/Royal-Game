# 👑 Royal Game — Flutter Mobile Gaming App

A premium black & gold mobile gaming app featuring 4 classic games, a coins system, AdMob integration, and daily rewards.

---

## 🎮 Games Included
| Game | Coins Reward |
|------|-------------|
| 🃏 Memory Cards | +20 coins per win |
| ❌ Tic Tac Toe | +15 coins per win |
| 🐍 Snake | +2 coins per food |
| 🔢 2048 | +5 coins per move |

---

## 💰 Coins System
- **Starting coins:** 100
- **Daily bonus:** +50 coins every 24 hours
- **Watch ad reward:** +30 coins
- **Stored locally** via SharedPreferences

---

## 📱 AdMob IDs
| Type | ID |
|------|----|
| Banner | `ca-app-pub-5058824160138099/9172293682` |
| Interstitial | `ca-app-pub-5058824160138099/3992119193` |
| Rewarded | `ca-app-pub-5058824160138099/6225183256` |

> ⚠️ Update `android/app/src/main/AndroidManifest.xml` with your actual AdMob **App ID** (the `~XXXXXXXXXX` part).

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0 (stable channel)
- Android Studio / VS Code
- Java 17
- Android SDK API 21+

### Setup
```bash
# 1. Clone the repository
git clone https://github.com/yourusername/royal-game.git
cd royal-game

# 2. Install dependencies
flutter pub get

# 3. Add fonts (download Cinzel from Google Fonts)
# Place Cinzel-Regular.ttf and Cinzel-Bold.ttf in assets/fonts/

# 4. Run on device
flutter run
```

### Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## ☁️ Codemagic Build

1. Push project to GitHub
2. Connect repo on [codemagic.io](https://codemagic.io)
3. Select **`codemagic.yaml`** configuration
4. Add your keystore in Codemagic environment → Code signing
5. Trigger build → Download APK from artifacts

---

## 📁 Project Structure
```
royal_game/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── utils/
│   │   ├── app_theme.dart           # Black & gold theme
│   │   └── app_constants.dart       # Ad IDs, coin values
│   ├── coins_system/
│   │   └── coins_provider.dart      # Coins state + SharedPrefs
│   ├── ads/
│   │   ├── ad_manager.dart          # AdMob interstitial & rewarded
│   │   └── banner_ad_widget.dart    # Reusable banner widget
│   ├── home/
│   │   ├── splash_screen.dart       # Animated splash
│   │   ├── home_screen.dart         # Game hub
│   │   └── leaderboard_screen.dart  # Stats & high scores
│   ├── widgets/
│   │   ├── coins_display.dart       # Coin counter widget
│   │   ├── gold_button.dart         # Animated gold button
│   │   └── game_app_bar.dart        # Shared app bar
│   └── games/
│       ├── memory/                  # Memory cards game
│       ├── tictactoe/               # Tic Tac Toe
│       ├── snake/                   # Snake game
│       └── game2048/                # 2048 game
├── assets/
│   ├── fonts/                       # Cinzel font files
│   ├── images/                      # App images
│   └── sounds/                      # Sound effects
├── android/                         # Android native config
├── codemagic.yaml                   # CI/CD config
└── pubspec.yaml                     # Flutter dependencies
```

---

## 🎨 Design System
- **Background:** `#0A0A0F` (deep black)
- **Gold Primary:** `#FFD700`
- **Gold Dark:** `#B8860B`
- **Card Background:** `#1A1A24`
- **Font:** Cinzel (Google Fonts — royal serif)

---

## ⚙️ Configuration

### Switch to Test Ads (Development)
In `lib/utils/app_constants.dart`:
```dart
static const bool useTestAds = true; // change to false for production
```

### Update AdMob App ID
In `android/app/src/main/AndroidManifest.xml`, replace:
```xml
android:value="ca-app-pub-5058824160138099~XXXXXXXXXX"
```
with your real App ID from AdMob console.

---

## 📦 Dependencies
| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `shared_preferences` | Local coin storage |
| `google_mobile_ads` | AdMob ads |
| `flutter_animate` | Smooth animations |
| `audioplayers` | Sound effects |

---

## 📄 License
MIT License — free to use and modify.

---

*Built with ❤️ using Flutter — Ready for Google Play Store*
