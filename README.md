# Captoniner 🎤📝

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Hive](https://img.shields.io/badge/Hive-FF6B35?style=for-the-badge&logo=hive&logoColor=white)](https://hivedb.dev)

**AI-powered real-time multilingual captioning app for the Deaf and hard-of-hearing community in India**

*Built by R3D Team for Smart India Hackathon 2024*

## 🎯 Problem Statement

**Title:** Develop a real-time closed captioning solution with simplified captions in multiple Indian languages for accessibility and inclusivity of Deaf and hard-of-hearing individuals.

**Objectives:**
- Enable real-time speech-to-text captioning in major Indian languages for Deaf users
- Provide simplified captions for easy comprehension by Deaf individuals and low-literacy users
- Ensure low latency, high accuracy, and accessibility features tailored for the Deaf community across diverse platforms

## ✨ Features

### 🎤 **Real-Time Speech Recognition**
- **Instant captioning** with <500ms latency
- **Tap-to-listen** interface with smart auto-stop
- **3-second silence detection** for automatic session management
- **Live partial results** for continuous feedback

### 🌍 **12 Indian Languages Supported**
- Hindi (हिन्दी) - Default
- English
- Bengali (বাংলা)
- Tamil (தமிழ்)
- Telugu (తెలుగు)
- Malayalam (മലയാളം)
- Kannada (ಕನ್ನಡ)
- Gujarati (ગુજરાતી)
- Marathi (मराठी)
- Punjabi (ਪੰਜਾਬੀ)
- Nepali (नेपाली)
- Urdu (اردو)

### 📱 **Accessibility First**
- **Theme switching** (Light/Dark/System)
- **Customizable font sizes**
- **High contrast mode**
- **WCAG 2.1 AA compliant**
- **Professional R3D branding**

### 🔄 **Offline Functionality**
- **Works without internet** using device's built-in speech recognition
- **Hive database** for fast local storage
- **Preloaded language support**
- **Battery optimized** smart listening modes

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK 3.10+
- Android Studio / VS Code
- Android device (API level 21+)

### **Installation**

1. **Clone the repository**
```bash
git clone https://github.com/Lethinkj/Speech-to-text.git
cd Speech-to-text
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate Hive adapters**
```bash
flutter packages pub run build_runner build
```

4. **Build and run**
```bash
flutter build apk --release
# or for development
flutter run
```

## 📱 APK Installation

### **Download**
- Latest release: `app-release.apk` (44.5MB)
- Compatible with Android 5.0+ (API 21+)

### **Permissions Required**
- **Microphone** - For speech recognition
- **Storage** - For caption history
- **Internet** - Optional for enhanced features

## 🎯 Usage

1. **Open Captoniner** on your Android device
2. **Grant microphone permission** when prompted
3. **Select your preferred language** from 12 options
4. **Tap the microphone button** to start listening
5. **Speak clearly** - captions appear in real-time
6. **Auto-stops after 3 seconds** of silence
7. **View caption history** in settings

## 🌟 Impact & Benefits

### **Social Impact**
- **2.78M+ deaf individuals** in India can benefit
- **Educational accessibility** for students
- **Workplace inclusion** for professionals
- **Social integration** in conversations

### **Technical Innovation**
- **First offline multilingual** captioning app for Indian languages
- **Smart silence detection** for battery optimization
- **Native script rendering** with proper Unicode support
- **Accessibility-first design** following WCAG guidelines

## 🏆 Achievements

- ✅ **Working prototype** with real-time functionality
- ✅ **12 Indian languages** with native script support
- ✅ **Offline capability** without internet dependency
- ✅ **Professional UI/UX** with R3D branding
- ✅ **Optimized performance** with <500ms latency
- ✅ **Ready for deployment** with tested APK

## 👥 Team R3D

Built with ❤️ for the Smart India Hackathon 2024 to make technology accessible for everyone.

---

*Making digital communication accessible for the Deaf community in India* 🇮🇳
