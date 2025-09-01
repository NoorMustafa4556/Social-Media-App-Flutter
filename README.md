


#  Social Media App (Flutter + Provider + Firebase)

A full-featured **social media application** built with Flutter and Firebase, featuring secure authentication, user profiles with follow/unfollow, posts and resharing, real-time likes/comments, dark/light mode, and clean state management via **Provider**. Built with clean architecture for scalability and maintainability.

---

##  Features

-  **User Authentication** – Register, login, and maintain user sessions securely via Firebase.
-  **Profiles** – Follow/unfollow users and update profile info including posts.
-  **Posting System** – Create public/private posts with images.
-  **Reshare Mechanism** – Reshare content across the app.
-  **Real-Time Interactions** – Like and comment on posts instantly (real-time sync).
-  **Dark & Light Themes** – Toggle between light and dark modes dynamically.
-  **State Management** – Seamless state handling using the `provider` package.

---

##  Architectural Flow

1. **View** (UI) interacts through user actions (e.g., posting, liking).
2. **Provider (ViewModel)** processes logic and updates application state.
3. **Firebase Backend** manages authentication, Firestore for data, and Storage for media.
4. State changes flow back via Provider, triggering UI rebuilds for smooth user experience.

---

##  Tech Stack

| Component             | Technology        |
|----------------------|-------------------|
| Framework            | Flutter           |
| State Management     | Provider          |
| Authentication       | Firebase Auth     |
| Database             | Cloud Firestore   |
| Image Storage        | Firebase Storage  |
| UI Themes            | Dynamic (Light/Dark) |
| Real-Time Updates    | Firestore + Streams |

---

<h2 align="center">📷 App Screenshots</h2>

<p align="center">
  <img src="assets/images/1.png" width="30%"/>
  <img src="assets/images/2.png" width="30%"/>
  <img src="assets/images/3.png" width="30%"/>
  
  <img src="assets/images/4.png" width="30%"/>
  <img src="assets/images/5.png" width="30%"/>
  <img src="assets/images/6.png" width="30%"/>
  
  <img src="assets/images/7.png" width="30%"/>
  <img src="assets/images/8.png" width="30%"/>
  <img src="assets/images/9.png" width="30%"/>
  
  <img src="assets/images/10.png" width="30%"/>
  <img src="assets/images/11.png" width="30%"/>
  <img src="assets/images/12.png" width="30%"/>
  
  <img src="assets/images/13.png" width="30%"/>
  <img src="assets/images/14.png" width="30%"/>
  <img src="assets/images/15.png" width="30%"/>
  
  <img src="assets/images/16.png" width="30%"/>
  <img src="assets/images/17.png" width="30%"/>
  <img src="assets/images/18.png" width="30%"/>
  
  <img src="assets/images/19.png" width="30%"/>
  <img src="assets/images/20.png" width="30%"/>
</p>


---

##  Getting Started

### Prerequisites
- Flutter SDK installed — [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
- A Firebase project setup with Auth, Firestore, and Storage enabled.

### Setup
```bash
git clone https://github.com/NoorMustafa4556/Social-Media-App-Flutter.git
cd Social-Media-App-Flutter
flutter pub get
