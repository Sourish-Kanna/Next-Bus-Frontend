# Next Bus 🚌

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=flat&logo=fastapi)
![Firebase](https://img.shields.io/badge/Database-Firestore-FFCA28?style=flat&logo=firebase)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-grey)

**The commuter's answer to unreliable transit schedules.** A robust, offline-first Flutter application built to track, predict, and crowdsource bus timings for the Thane region (Routes 56 & 156).

---

## 📖 The Story

> *"3.5 Years of Data. 1 Year of Code."*

This project wasn't born in a boardroom; it was born at a bus stop. After years of frustration with unreliable official schedules for the commute from **Thane Station to Tikujiniwadi**, I decided to fix it myself.

I spent **3.5 years manually tracking** the arrival and departure times of Route 56 and 156 to build a "Golden Dataset" of actual bus behavior. **Next Bus** is the digital evolution of that effort—a modern app that combines historical accuracy with real-time crowdsourcing to ensure no one misses their ride again.

---

## ✨ Key Features

### 🚀 **Offline-First Architecture**
* **Zero-Network Access:** The app works perfectly without an internet connection. Timetables are cached locally using `SharedPreferences`.
* **Smart Sync Queue:** If a user reports a bus arrival while offline, the data is queued locally and silently uploaded the moment connectivity is restored.

### 📊 **Data Precision**
* **The Golden Dataset:** Pre-seeded with highly accurate historical timings for Routes 56 & 156.
* **Crowdsourcing:** Users can report "Bus Arrived" or "Delayed" in real-time to help fellow commuters.

### 🎨 **Modern "Material 3" UI**
* **Dynamic Theming:** Adopts the user's wallpaper colors (Android 12+) with a **Deep Orange** brand fallback.
* **Accessibility:** High-contrast text, XL touch targets (56px pill buttons), and smooth animations.
* **Dark Mode:** Fully supported system-wide dark theme.

### 🛠 **Admin Dashboard**
* **Role-Based Access:** Admins (verified via Backend API) get instant access to a dedicated dashboard.
* **Route Management:** Create new routes, update stops, and modify timings on the fly.
* **System Health:** View real-time debug logs, cache status, and connectivity health.

---

## 🏗 Technical Architecture

### **Frontend (Flutter)**
* **State Management:** `Provider` (Multi-provider architecture for Auth, Routes, Timetable, and UI State).
* **Networking:** `Dio` with custom interceptors for retry logic and error handling.
* **Local Storage:** `SharedPreferences` for caching user roles and offline queues.

### **Backend & Database**
* **API:** Python **FastAPI** hosted on Render.
* **Database:** Google **Firebase Firestore** (NoSQL) for real-time syncing.
* **Auth:** **Firebase Auth** (Google Sign-In + Anonymous Guest Access).

### **DevOps & CI/CD**
* **GitHub Actions:** Automated workflows to:
    * Build signed Android APKs (`release` build).
    * Inject version numbers dynamically (`package_info_plus`).
    * Deploy the Web version to Firebase Hosting.

---

## 📸 Screenshots

| Home (Offline) | Admin Dashboard | Dark Mode |
|:---:|:---:|:---:|
| *(Place screenshot here)* | *(Place screenshot here)* | *(Place screenshot here)* |

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+)
* Firebase Project (with Auth & Firestore enabled)
* Python 3.x (for Backend)

### Installation

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/your-username/next-bus.git](https://github.com/your-username/next-bus.git)
    cd next-bus
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**
    * Use the `flutterfire` CLI to generate `firebase_options.dart` for your project.
    ```bash
    flutterfire configure
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

---

## 🤝 Contributing

Contributions are welcome! Whether it's fixing a bug, adding a new route, or improving the UI.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 🛡 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  <small>Built with ❤️ by a Commuter for Commuters.</small>
</div>