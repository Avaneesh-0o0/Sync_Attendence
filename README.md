# AttendEase — Smart Attendance System

AttendEase is a smart and secure attendance management system designed for colleges and educational institutions. It supports three attendance modes — **Bluetooth**, **QR**, and **Hybrid** — enabling fast, offline-first, and proxy-resistant attendance verification.

Built with **Flutter** for the application layer and **Supabase** for backend authentication, data storage, and synchronization.

---

## 🚀 Features

- **Google Auth (College Email Based)**
- **Role-based Access (Teacher & Student)**
- **Bluetooth Attendance Mode**
  - Teacher device broadcasts BLE beacon
  - Students detect beacon & validate proximity via RSSI
  - Works fully offline
- **QR Attendance Mode**
  - Dynamic QR refreshes every 45 seconds
  - Time-bound token validation prevents proxy/share
- **Hybrid Mode**
  - Combines QR + Bluetooth for maximum security
- **Offline-first Architecture**
  - Attendance stored locally when offline & synced later
- **Teacher Dashboard**
  - Start sessions, monitor attendance, manage classes & subjects
- **Student Panel**
  - Mark attendance, view attendance history

---

## 🏛️ Attendance Modes

| Mode | Requires Internet | Secure Against Proxy | Notes |
|------|------------------|----------------------|-------|
| Bluetooth | ❌ No | ✅ Yes | Best for poor network environments |
| QR | ❌ No | ⚠️ Medium | QR rotates every 45 sec |
| Hybrid | ❌ No | 🔥 Maximum | Requires both BLE + QR |

---

## 🧩 Architecture Overview

**Frontend:** Flutter (Android)  
**Backend:** Supabase (PostgreSQL + Auth + Storage)  
**Data Sync:** Offline queue via Hive → Supabase sync  
**Device Comms:** BLE (Bluetooth Low Energy)

---

## 📱 User Roles

### 👨‍🎓 Student
- Login via Google
- Scan QR / detect BLE beacon
- Mark attendance & view history

### 👨‍🏫 Teacher
- Login via Google
- Manage classes & subjects
- Start/end attendance sessions and generate reports

---

## 💾 Offline Behavior

- Attendance events stored in local device DB (Hive)
- Synced to Supabase when network becomes available
- Prevents data loss in real college environments

---

## 🔐 Security Model

- Dynamic QR tokens (expires every 45 seconds)
- BLE RSSI proximity check (3-meter radius)
- Unique attendance constraint (1 student per session)
- Role-based routing & DB filtering
- College email-based authentication

---

## 🗄️ Database Schema

```
users        (id, email, role, name, avatar_url)
students     (user_id, roll_no, department)
teachers     (user_id, department)
classes      (id, name, teacher_id)
sessions     (id, class_id, teacher_id, mode, created_at, ended_at)
attendance   (id, session_id, student_id, method, rssi, synced, marked_at)
```

---

## 🔧 Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| Backend | Supabase (Auth + PostgreSQL) |
| Offline Storage | Hive |
| Bluetooth | flutter_blue_plus |
| QR | qr_flutter + mobile_scanner |
| Auth | Google Sign-In |

---

## 🛠️ Installation

1. Clone the repo and install dependencies:
```bash
flutter pub get
```

2. Run on a real Android device (BLE not supported in emulators):
```bash
flutter run
```

3. Build for release:
```bash
flutter build apk --release
```

---

## 🧪 Testing Requirements

- Must test on **real Android device** (BLE requires hardware)
- Android 6.0+ for Bluetooth support
- Camera permission required for QR mode

---

## 🔜 Planned Enhancements

- Web dashboard for admins
- Push notifications for attendance reminders
- Exportable CSV/PDF attendance reports
- iOS support (Phase 2)
- Bluetooth mesh optimization for large rooms

---

## 🏁 Status

> 🚧 Actively in development

---

## 🤝 Contributions

PRs and suggestions are welcome! Open an issue or fork the project to propose enhancements.

---

## 🔗 Author

**Avaneesh Malviya** — Flutter Dev / System Design  
[GitHub](https://github.com/Avaneesh-0o0) | [LinkedIn](https://www.linkedin.com/in/avaneesh-malviya-7980b5296/)

---

## 📄 License

MIT License
