# AttendEase — Smart Attendance System

AttendEase is a smart and secure attendance management system designed for colleges and educational institutions. It supports three attendance modes — **Bluetooth**, **QR**, and **Hybrid** — enabling fast, offline-first, and proxy-resistant attendance verification.

The system is built with **Flutter** for the application layer and **Supabase** for backend authentication, data storage, and synchronization.

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
  - Start sessions
  - Monitor attendance
  - Manage classes & subjects
- **Student Panel**
  - Mark attendance
  - View attendance history

---

## 🏛️ Attendance Modes (Spec)

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
- Mark attendance
- View history

### 👨‍🏫 Teacher
- Login via Google
- Manage classes & subjects
- Start attendance sessions
- End sessions and generate reports

---

## 💾 Offline Behavior

- Attendance events stored in local device DB (Hive)
- Synced to Supabase when network becomes available
- Prevents data loss in real college environments

---

## 🔐 Security Model

- Dynamic QR tokens (expires every 45 seconds)
- BLE RSSI proximity check
- Unique attendance constraint (1 student per session)
- Role-based routing & DB filtering
- College email-based authentication

---

## 🗄️ Database Schema (Simplified)
- users (id, email, role, name, avatar_url)
- students (user_id, roll_no, department)
- teachers (user_id, department)
- classes (id, name, teacher_id)
- sessions (id, class_id, teacher_id, mode, created_at, ended_at)
- attendance (id, session_id, student_id, method, rssi, synced, marked_at)
  
---

## 🔧 Tech Stack

- Flutter (Dart)
- Supabase (Auth + PostgreSQL)
- Hive (Offline storage)
- flutter_blue_plus (Bluetooth LE)
- qr_flutter + mobile_scanner (QR system)
- Google Sign-In

---

## 🔜 Planned Enhancements

- Web dashboard for admins
- Push notifications for attendance reminders
- Exportable CSV/PDF attendance reports
- iOS support (phase-2)
- Bluetooth mesh optimization for large rooms

---

## 🧪 Testing Requirements

- Must test on **real Android device** (BLE not supported in emulators)
- Bluetooth: requires Android 6.0+
- Camera permission for QR mode

---

## 🏁 Status

> 🚧 Work In Progress — actively developed

---

## 📄 License

MIT License (or choose your own)

---

## 🤝 Contributions

PRs and suggestions are welcome! Open an issue or fork the project to propose enhancements.

---

## 🔗 Authors

- Avaneesh — Flutter Dev / System Design



