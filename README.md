# ⚡ AttendEase — Smart & Secure Attendance Management System

AttendEase is a state-of-the-art, secure, and resilient attendance management system tailored for modern educational institutions. Designed to tackle the massive issue of "proxy attendance," the system utilizes physical presence validation through a combination of **Bluetooth Low Energy (BLE)**, **Dynamic QR Codes**, and **Hybrid verification modes**. 

With a robust **offline-first architecture** built on **Flutter** and backed by **Supabase (sync_attend)**, AttendEase guarantees that students can mark their attendance with zero friction, even in environments with completely offline or congested campus networks.

---

## 📖 Table of Contents
1. [Project Overview & Key Objectives](#-project-overview--key-objectives)
2. [Core Attendance Modes & Working Principles](#-core-attendance-modes--working-principles)
   - [1. Bluetooth Low Energy (BLE) Mode](#1-bluetooth-low-energy-ble-mode)
   - [2. Dynamic QR Mode](#2-dynamic-qr-mode)
   - [3. Robust Hybrid Mode & Smart Fallback](#3-robust-hybrid-mode--smart-fallback)
3. [System Architecture & Data Flows](#-system-architecture--data-flows)
4. [Offline-First Architecture & Sync Queue](#-offline-first-architecture--sync-queue)
5. [Database Schema (Supabase sync_attend)](#-database-schema-supabase-sync_attend)
6. [Security & Proxy Prevention Mechanics](#-security--proxy-prevention-mechanics)
7. [Visual Design & Cyberpunk Aesthetics](#-visual-design--cyberpunk-aesthetics)
8. [Setup & Installation Guide](#-setup--installation-guide)

---

## 🌟 Project Overview & Key Objectives

In crowded university classrooms and lecture halls, traditional methods of attendance (roll calls, paper sheets, and static QR codes) are easily bypassed. Students routinely share static QR code screenshots over messaging apps or mark attendance for friends who are not physically present.

### Key Objectives of AttendEase:
* **Anti-Proxy Protection:** Enforce physical presence using localized Bluetooth signals and dynamic rotating QR signatures that cannot be screenshotted and shared.
* **Resilience to Poor Network Conditions:** Ensure classrooms in basements or old brick buildings with zero cellular signal can still take attendance seamlessly by caching logs locally and syncing when a connection is restored.
* **Premium User Experience:** Elevate standard boring SaaS dashboard designs into a highly interactive, animated cyberpunk-inspired telemetry hub that captures user attention.
* **Cross-Platform Readiness:** Deliver a unified mobile application for students and an adaptive, multi-viewport web/mobile interface for teachers.

---

## 🏛️ Core Attendance Modes & Working Principles

AttendEase offers three validation methods depending on classroom security preferences and hardware support.

```
                  ┌───────────────────────────────┐
                  │   Teacher Starts Session      │
                  └──────────────┬────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         ▼                       ▼                       ▼
  ┌──────────────┐        ┌──────────────┐        ┌──────────────┐
  │   BLE Mode   │        │   QR Mode    │        │ Hybrid Mode  │
  └──────┬───────┘        └──────┬───────┘        └──────┬───────┘
         │                       │                       │
         │                       │                       ▼
         │                       │               BLE Broadcast Check
         │                       │               (Automatic & Fast)
         │                       │                       │
         │                       │         ┌─────────────┴─────────────┐
         │                       │         ▼                           ▼
         │                       │     [Success]                    [Fail]
         │                       │         │                           │
         │                       │         ▼                           ▼
         │                       │     Proceed to                 Proceed to
         │                       │      QR Scan                     QR-Only
         │                       │    (BLE Checked)               (Fallback)
         │                       │         │                           │
         └───────────┬───────────┴─────────┼───────────────────────────┘
                     │                     │
                     ▼                     ▼
             ┌──────────────┐      ┌──────────────┐
             │ Mark Locally │ ───> │ Sync online  │
             └──────────────┘      └──────────────┘
```

### 1. Bluetooth Low Energy (BLE) Mode
Ideal for fast, contact-free verification without requiring students to align their cameras or leave their seats.

* **Teacher Side (Advertiser):** 
  When a teacher starts a BLE attendance session, the application configures a peripheral advertiser using `flutter_ble_peripheral`. The device broadcasts a localized beacon payload containing the unique session key:
  * Local Name: `"ATX:${sessionId.substring(0, 8)}"`
* **Student Side (Scanner):**
  * When the student enters the classroom and presses "Mark Attendance", the app opens a custom glowing **Radar Scanner Dialog**.
  * The student's device scans for active BLE beacons using `flutter_blue_plus`.
  * **Frictionless Proximity:** Traditional strict RSSI limits (e.g. `r.rssi < -85`) are bypassed. The scanner matches via string containment (`.contains('ATX:')`) to prevent trailing character issues.
  * Once the beacon is found, a dialog prompts the student to **Confirm Attendance**. A single tap completes the handshake and registers the presence.

### 2. Dynamic QR Mode
Best for classrooms with varying student hardware capabilities.

* **Teacher Side (QR Generator):**
  * The app displays a high-fidelity dynamic QR matrix.
  * To prevent screenshot sharing, the QR token changes every **30 to 45 seconds**.
  * Each token contains a cryptographically signed signature generated locally using:
    `ATTENDIX_QR : <session_id> : <rolling_window_id> : <sha256_hash>`
    Where `rolling_window_id` is the current Unix epoch divided by 30, and the `hash` is computed with a private application salt.
* **Student Side (QR Scanner):**
  * The student scans the dynamic QR code using the device's camera via `mobile_scanner`.
  * The application reads the signature and performs initial verification locally before sending it to the database, ensuring expired or malformed QR codes are rejected instantly.

### 3. Robust Hybrid Mode & Smart Fallback
The ultimate security configuration that enforces **both** physical presence and visual alignment.

* **Sequence of Execution:**
  1. The student application initiates the background Bluetooth scan *first*.
  2. **Automatic Handshake:** If the teacher's BLE beacon is detected, the app marks the BLE validation check as **Successful** and instantly transitions to the camera interface.
  3. The student scans the rotating Dynamic QR code, merging BLE proximity with visual line-of-sight validation to record a highly secure, verified attendance event.
* **Zero-Block Fallback System:**
  In real-world environments, a student’s Bluetooth module might be broken, location services disabled, or signals blocked by dense obstacles. To prevent locking out legitimate students:
  * A custom **"USE QR CODE"** bypass button is integrated directly into the glowing radar scanner dialog.
  * If the Bluetooth scan fails or times out after 8-10 seconds, the app gracefully falls back to QR-only verification.

---

## 🛠️ System Architecture & Data Flows

AttendEase is divided into isolated, decoupled layers for maintainability and scalability:

```
┌────────────────────────────────────────────────────────────────────────┐
│                          FLUTTER CLIENT APP                            │
├───────────────────────────────┬────────────────────────────────────────┤
│     TEACHER COMPONENT         │           STUDENT COMPONENT            │
├───────────────────────────────┼────────────────────────────────────────┤
│ - Persistent Desktop Sidebar  │ - Cyberpunk Radar UI                   │
│ - Telemetry Grid              │ - QR & BLE Handshake Controllers       │
│ - Live Attendance View        │ - Hive Local Sync Queue                │
└──────────────┬────────────────┴───────────────────▲────────────────────┘
               │                                    │
       Real-time Streams                        API & RLS
        (Websockets)                             (HTTPS)
               │                                    │
┌──────────────▼────────────────────────────────────┴────────────────────┐
│                    SUPABASE (sync_attend) BACKEND                      │
├────────────────────────────────────────────────────────────────────────┤
│ - PostgreSQL Tables & Unique Key Constraints                           │
│ - PL/pgSQL Cryptographic Token Validation RPCs                         │
│ - Row Level Security (RLS) Policy Filtering                            │
│ - Automated User Setup Triggers                                        │
└────────────────────────────────────────────────────────────────────────┘
```

* **Application Layer (Flutter):**
  * Core Navigation: Context-aware dashboard routing. Stretched mobile navigation scales gracefully into a premium glassmorphic `DesktopSidebar` on laptops and desktop screens.
  * Local Storage: High-performance key-value mapping using **Hive** for fast offline caching.
* **Backend Database Layer (Supabase - sync_attend):**
  * Configured in Supabase as a production database named **sync_attend**.
  * Employs Row Level Security (RLS) ensuring students can only select/insert their own records, and teachers can only manage classes assigned to their unique IDs.
  * Leverages Postgres triggers to automatically provision customized rows in `public.users` when new accounts authenticate via Google OAuth.

---

## 💾 Offline-First Architecture & Sync Queue

One of AttendEase's core values is its bulletproof offline functionality. If a classroom is in a basement with zero connectivity, the attendance sequence remains completely unimpeded.

### The Queue Mechanics:
1. **Network Status Detection:** The application monitors active networks using the `connectivity_plus` package.
2. **Offline Intercept:** When marking attendance, if `Connectivity().checkConnectivity()` returns `ConnectivityResult.none` for all channels:
   * The app generates the attendance record.
   * Marks the local field `synced = false`.
   * Enqueues the raw payload into a persistent Hive box: `'offline_attendance'`.
   * Displays a futuristic glowing dashboard notification: **"Saved Offline"**.
3. **Automated Background Sync:**
   * A persistent stream listener monitors network reconnect events.
   * Upon detecting a valid connection, `syncOfflineData()` is executed in the background.
   * It iterates through cached keys, removing the temporary QR validation tokens before pushing records to the live Supabase database via the client SDK.

### Postgres Unique Constraint Graceful Resolution:
The database contains a strict `unique_attendance` constraint across the composite key `(session_id, student_id)`. If a student marks attendance successfully online, but the local client cache misses the confirmation and attempts to sync the record again later, Supabase returns a Postgres Error Code `23505` (Unique Key Violation).
* **Sync Controller Defense:** The offline sync service catches the `23505` code, treats it as a successful registration, and immediately deletes it from the local Hive queue. This completely eliminates queue lockups and prevents students' local queues from getting stuck on repeat retries.

---

## 🗄️ Database Schema (Supabase sync_attend)

The hosted **sync_attend** database structure contains five core public tables optimized with relational indexes.

### 1. `users`
Profiles linked directly to Supabase Authentication.
```sql
create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  name text not null,
  role text check (role in ('student', 'teacher')),
  department text,
  avatar_url text,
  created_at timestamp with time zone default now()
);
```

### 2. `classes`
Contains class groups managed by teachers.
```sql
create table public.classes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  subject_code text,
  semester text default 'Current',
  department text,
  teacher_id uuid references public.users(id) on delete set null,
  total_students integer default 50,
  created_at timestamp with time zone default now()
);
```

### 3. `students`
Connects student users to active classes.
```sql
create table public.students (
  user_id uuid primary key references public.users(id) on delete cascade,
  roll_no text not null,
  class_id uuid references public.classes(id) on delete set null,
  created_at timestamp with time zone default now()
);
```

### 4. `sessions`
Attendance sessions created by teachers.
```sql
create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references public.users(id) on delete cascade,
  class_id uuid not null references public.classes(id) on delete cascade,
  subject text,
  mode text not null check (mode in ('QR', 'BLE', 'HYBRID')),
  start_time timestamp with time zone default now(),
  end_time timestamp with time zone,
  is_active boolean default true,
  created_at timestamp with time zone default now()
);
```

### 5. `attendance`
Active attendance entries. Includes a compound unique constraint.
```sql
create table public.attendance (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  student_id uuid not null references public.students(user_id) on delete cascade,
  marked_at timestamp with time zone default now(),
  device_id text,
  verification_method text,
  student_name text,
  roll_number text,
  status text default 'present',
  synced boolean default false,
  constraint unique_attendance unique (session_id, student_id)
);
```

---

## 🔐 Security & Proxy Prevention Mechanics

AttendEase's security framework is engineered to eliminate remote, virtual, or duplicate attendance submissions:

1. **Rotational Token Windows:** QR codes are valid for a single window of time. If a student tries to send a screenshot to an absent peer, the token will have expired before the peer can scan it.
2. **Clock-Drift Calibration:** Our server-side PL/pgSQL function calculates the valid window based on server time, tolerating a clock drift of up to 4 windows (~120 seconds) to ensure slow mobile connections do not trigger false negatives.
3. **Database-Level Integrity Constraints:** A composite primary database constraint prevents any student from logging more than one presence record per classroom session.

---

## 🎨 Visual Design & Cyberpunk Aesthetics

AttendEase stands out with its gorgeous, premium design. We utilize futuristic dark modes with high-contrast neon accents, glassmorphic panels, and fluid micro-animations.

### Our Branding Palette:
* **Backgrounds:** Deep Space Obsidian (`#0B0D19`) to Dark Navy (`#111428`)
* **Primary Accents:** Electric Neon Cyan (`#00F2FE`) & Cyber Yellow (`#FFF000`)
* **Glow/Ambient Accents:** Deep Neon Purple (`#7F00FF`)
* **Typography Hierarchy:**
  * **Logo and Display Headers:** `Orbitron` (Futuristic, high-impact sans-serif)
  * **Body, Metric Cards, Buttons, and Tables:** `Inter` (Sleek, legible, highly professional SaaS typography)

---

## 🛠️ Setup & Installation Guide

### Prerequisites
* Flutter SDK (3.22.0+ recommended)
* Android SDK (API Level 23+ required for Bluetooth Low Energy)
* A valid **Supabase** project instance (named `sync_attend`)

### Environment Setup
Create a `.env` file in the root directory of your project:
```env
SUPABASE_URL=https://your-supabase-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anonymous-key
```

### Package Installation
Run the following command to download dependencies:
```bash
flutter pub get
```

### Run the Project
Because BLE and camera testing require real hardware peripherals, you must run the app on a **physical device** (Android/iOS):
```bash
flutter run
```

### Production Build
To package a release APK:
```bash
flutter build apk --release
```
