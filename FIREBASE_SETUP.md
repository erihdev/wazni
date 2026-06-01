# 🔥 إعداد Firebase — Wazni وزني

---

## الخطوة 1 — إنشاء مشروع Firebase

1. اذهبي إلى [console.firebase.google.com](https://console.firebase.google.com)
2. **Add project** ← اسم المشروع: `wazni`
3. يمكنك تعطيل Google Analytics (اختياري)
4. انتظري إنشاء المشروع

---

## الخطوة 2 — تفعيل Authentication

1. من القائمة الجانبية: **Build → Authentication**
2. اضغطي **Get started**
3. اختاري **Email/Password** → فعّليه → احفظي

---

## الخطوة 3 — إنشاء Firestore Database

1. من القائمة: **Build → Firestore Database**
2. اضغطي **Create database**
3. اختاري **Start in test mode** (للتطوير)
4. اختاري أقرب منطقة (مثل `europe-west3`)
5. اضغطي **Enable**

---

## الخطوة 4 — قواعد الأمان (Security Rules)

في **Firestore → Rules** ضعي هذه القواعد:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // المستخدمون يقرأون/يكتبون بياناتهم فقط
    match /users/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == uid;
    }

    // القراءات: أي مستخدم مسجل — الكتابة: صاحب الحساب فقط
    match /entries/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == uid;
    }

    // الأكواد: القراءة للجميع، الكتابة عبر الكود فقط
    match /codes/{code} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
  }
}
```

---

## الخطوة 5 — الحصول على Firebase Config

1. في Firebase Console → **Project Settings** (⚙️)
2. في **Your apps** → اضغطي **Add app** → **Web** (`</>`)
3. اسم التطبيق: `wazni-web` → **Register app**
4. انسخي الـ `firebaseConfig`

---

## الخطوة 6 — تحديث index.html

افتحي ملف `index.html` وابحثي عن:

```javascript
const firebaseConfig = {
  apiKey:            "REPLACE_API_KEY",
  authDomain:        "REPLACE_AUTH_DOMAIN",
  projectId:         "REPLACE_PROJECT_ID",
  storageBucket:     "REPLACE_STORAGE_BUCKET",
  messagingSenderId: "REPLACE_MESSAGING_SENDER_ID",
  appId:             "REPLACE_APP_ID"
};
```

استبدليها بقيمك الحقيقية من Firebase Console.

---

## الخطوة 7 — رفع على GitHub Pages

1. ارفعي الملفات على GitHub repository
2. **Settings → Pages → Branch: main**
3. رابط التطبيق: `https://erihdev.github.io/wazni`

> ⚠️ أضيفي الرابط في Firebase Console:
> **Authentication → Settings → Authorized domains** → أضيفي `erihdev.github.io`

---

## هيكل Firestore

```
users/{uid}
  ├── name: string
  ├── email: string
  ├── code: string (كود التحدي)
  ├── startWeight: number
  ├── goalWeight: number
  ├── challenges: [uid1, uid2, ...]
  └── createdAt: timestamp

entries/{uid}
  └── data: [{label, weight, ts}, ...]

codes/{code}
  ├── uid: string
  └── email: string
```

---

## erihdev · [erihdev.com](https://erihdev.com)
