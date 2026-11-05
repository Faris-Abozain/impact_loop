# دليل تشغيل واستخدام ImpactLoop Local API

تم بناء خادم محلي كامل (Node.js Express Local Mock Server) يطبق 100% من جميع نقاط النهاية المحددة في مواصفة **OpenAPI 3.0.3 (ImpactLoop MVP API)** بدقة تامة، مع ربطه بتطبيق Flutter مباشرة.

---

## 🚀 طريقة تشغيل السيرفر المحلي

### الطريقة الأولى (الأسهل بنقرة واحدة على ويندوز):
قم بالضغط مرتين (Double Click) على الملف:
```
run_local_server.bat
```
الموجود في المجلد الرئيسي للمشروع.

### الطريقة الثانية (عبر موجه الأوامر Terminal):
```bash
cd server
npm start
```
سيبدأ السيرفر في العمل فوراً على المنفذ `3000`:
- **رابط السيرفر:** `http://localhost:3000/api/v1`
- **رابط محاكي الأندرويد (Android Emulator):** `http://10.0.2.2:3000/api/v1`

---

## 🌐 السيرفر السحابي المباشر (Production Cloud Server)

تم رفع الـ API الخاصة بالمشروع وتجهيزها على السيرفر السحابي:
- **Base URL:** `https://api.impact-loop.dawava.me/api/v1`
- **الحالة:** يعمل مباشرة من أي جهاز وهاتف محمول أو محاكي دون الحاجة للاتصال بنفس شبكة الـ Wi-Fi أو تشغيل أي سيرفر محلي.

---

## 📱 إعدادات تطبيق Flutter

تم ضبط [lib/core/config/app_config.dart](file:///d:/StudioProjects/impact_loop/lib/core/config/app_config.dart) ليعتمد افتراضياً على السيرفر السحابي:
- **الوضع الافتراضي (Default):** يتصل مباشرة بسيرفر الإنتاج `https://api.impact-loop.dawava.me/api/v1` ويعمل على أي جهاز (Android, iOS, Web, Windows).
- **الوضع المحلي (Local Development Offline):** في حال الرغبة في التشغيل على سيرفر Node.js المحلي أوفلاين:
  ```bash
  flutter run --dart-define=USE_LOCAL_SERVER=true
  ```
  أو تحديد رابط مخصص عبر:
  ```bash
  flutter run --dart-define=IMPACT_LOOP_API_URL=http://<IP>:3000/api/v1
  ```

---

## 👥 الحسابات الجاهزة للاختبار (Seed Accounts)

| الحساب | البريد الإلكتروني | كلمة المرور | الدور (Role) | الصلاحيات |
|---|---|---|---|---|
| **مستخدم عادي (Demo User)** | `demo@impactloop.app` | أي كلمة مرور (مثلاً `12345678`) | `USER` | تصفح المهمات، الحجز، رفع الإثباتات، سحب المحفظة |
| **مراجع العمليات (Ops Admin)** | `ops@impactloop.app` | أي كلمة مرور | `ADMIN` | مراجعة واعتماد ورفض الإثباتات وتعديل المحافظ |
| **شريك المبادرة (Client)** | `client@impactloop.app` | أي كلمة مرور | `CLIENT` | إنشاء وإدارة الحملات وتصدير تقارير CSV |

*يمكنك أيضاً تسجيل أي حساب جديد عبر شاشة التسجيل وسيقوم السيرفر بحفظه في الذاكرة ومنحه رصيداً ترحيبياً تلقائياً.*

---

## 📋 جميع الـ APIs المغطاة في السيرفر وتطبيق Flutter

### 1. Health & Readiness (الفحص والجاهزية)
- `GET /api/v1/health`
- `GET /api/v1/ready`

### 2. Authentication (المصادقة والحسابات)
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`

### 3. Users & Wallet (المستخدم والمحفظة والأثر)
- `GET /api/v1/me` & `GET /api/v1/users/me`
- `GET /api/v1/wallet` & `GET /api/v1/users/me/wallet`
- `GET /api/v1/wallet/ledger`
- `POST /api/v1/wallet/withdraw`
- `GET /api/v1/users/me/impact`

### 4. Missions (المهمات المتاحة)
- `GET /api/v1/missions`
- `GET /api/v1/missions/:missionId`
- `GET /api/v1/missions/:missionId/tasks`

### 5. Tasks (المهام الفرعية والحجز والرفع)
- `GET /api/v1/tasks/nearby`
- `GET /api/v1/tasks/:taskId`
- `POST /api/v1/tasks/:taskId/reserve`
- `POST /api/v1/tasks/:taskId/submit` (يدعم رفع الملفات الحقيقية عبر Multipart)

### 6. Submissions (المسودات والإثباتات)
- `POST /api/v1/submissions` (إنشاء مسودة)
- `GET /api/v1/submissions` (قائمة إثباتات المستخدم)
- `PATCH /api/v1/submissions/:submissionId` (تعديل المسودة)
- `GET /api/v1/submissions/:submissionId` (تفاصيل الإثبات)
- `POST /api/v1/submissions/:submissionId/submit` (إرسال المسودة مع الملفات)

### 7. Campaigns (الحملات والمبادرات)
- `POST /api/v1/campaigns` (إنشاء حملة)
- `GET /api/v1/campaigns` (عرض الحملات)
- `GET /api/v1/campaigns/:campaignId` (تفاصيل الحملة)
- `PATCH /api/v1/campaigns/:campaignId/status` (تغيير حالة الحملة)
- `GET /api/v1/campaigns/:campaignId/submissions` (إثباتات الحملة والإحصائيات)
- `GET /api/v1/campaigns/:campaignId/submissions/export` (تصدير CSV)

### 8. Admin & Operations (لوحة التحكم والعمليات)
- `GET /api/v1/admin/submissions` & `GET /api/v1/ops/submissions`
- `POST /api/v1/admin/submissions/:submissionId/approve` & `POST /api/v1/ops/submissions/:submissionId/approve`
- `POST /api/v1/admin/submissions/:submissionId/reject` & `POST /api/v1/ops/submissions/:submissionId/reject`
- `POST /api/v1/ops/submissions/:submissionId/request-info`
- `POST /api/v1/admin/wallet/:userId/adjust` (مكافأة أو خصم نقاط)

### 9. Notifications & Devices (الإشعارات والأجهزة)
- `POST /api/v1/devices/register`
- `GET /api/v1/notifications`
- `POST /api/v1/notifications/:id/read`

### 10. Verification / KYC (توثيق الهوية)
- `GET /api/v1/verification/status`
- `POST /api/v1/verification/submit` (يدعم رفع صور الهوية والسيلفي)
- `GET /api/v1/verification/details`
