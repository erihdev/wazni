# Wazni وزني — دليل الإعداد والنشر
**by erihdev**

---

## 📁 الملفات

```
wazni/
├── index.html        ← تطبيق الويب (PWA) — ارفعيه على GitHub Pages
├── manifest.json     ← إعدادات PWA
├── sw.js             ← Service Worker (وضع بلا إنترنت)
├── App.js            ← تطبيق React Native (iOS + Android)
├── package.json      ← تبعيات React Native
└── SETUP.md          ← هذا الملف
```

---

## 🌐 نشر الويب على GitHub Pages

### الخطوات:
1. اذهبي إلى [github.com](https://github.com) → **New repository**
2. الاسم: `wazni` (أو أي اسم تختارينه)
3. ارفعي الملفات: `index.html` + `manifest.json` + `sw.js`
4. **Settings → Pages → Branch: main** → احفظي
5. رابطك سيكون: `https://erihdev.github.io/wazni`

### تثبيت PWA على الآيفون:
- افتحي الرابط في Safari
- اضغطي على زر المشاركة ↑
- اختاري "إضافة إلى الشاشة الرئيسية"
- ✅ التطبيق سيظهر كتطبيق أصلي!

---

## 📱 بناء React Native (iOS + Android)

### المتطلبات:
- Node.js 18+
- Expo CLI: `npm install -g expo-cli eas-cli`
- حساب على [expo.dev](https://expo.dev) (مجاني)
- Xcode (للـ iOS — Mac فقط)
- Android Studio (للـ Android)

### الإعداد:
```bash
# 1. إنشاء مشروع Expo جديد
npx create-expo-app wazni --template blank

# 2. انسخي App.js إلى المجلد

# 3. تثبيت التبعيات
npm install @react-navigation/native @react-navigation/bottom-tabs @react-navigation/native-stack
npm install react-native-screens react-native-safe-area-context
npm install react-native-chart-kit react-native-svg
npm install @react-native-async-storage/async-storage
npm install expo-clipboard

# 4. تشغيل للاختبار
npx expo start
```

### البناء والنشر:
```bash
# تسجيل دخول EAS
eas login

# إعداد المشروع
eas build:configure

# بناء Android (.aab للمتجر أو .apk للتجربة)
eas build --platform android --profile preview

# بناء iOS
eas build --platform ios
```

### app.json — ضعيه في مجلد المشروع:
```json
{
  "expo": {
    "name": "Wazni وزني",
    "slug": "wazni",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": { "backgroundColor": "#185FA5" },
    "ios": {
      "bundleIdentifier": "com.erihdev.wazni",
      "supportsTablet": false
    },
    "android": {
      "package": "com.erihdev.wazni",
      "adaptiveIcon": { "foregroundImage": "./assets/adaptive-icon.png", "backgroundColor": "#185FA5" }
    }
  }
}
```

---

## ⚠️ ملاحظة مهمة — البيانات

التطبيق الحالي يحفظ البيانات محلياً (localStorage / AsyncStorage).
- ✅ مناسب للاستخدام على نفس الجهاز
- ❌ لا تتزامن البيانات بين الأجهزة المختلفة

**للمرحلة القادمة:** ربط Firebase Firestore لمشاركة البيانات بين الأجهزة.

---

## 📞 التواصل
**erihdev** — [erihdev.com](https://erihdev.com)
