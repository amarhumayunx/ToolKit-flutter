# 📱 Toolkit App

> **A comprehensive all-in-one mobile utility application built with Flutter** that combines document management, image processing, file operations, and productivity tools into a single, powerful platform.

Toolkit is a feature-rich Flutter application designed to handle all your document, image, and file management needs directly from your mobile device. Whether you need to create professional CVs, convert file formats, extract text from images, compress files, or securely manage your documents, Toolkit provides a seamless and intuitive experience.

## 📋 Description

Toolkit is a modern, cross-platform mobile application that serves as your complete productivity companion. Built with Flutter and integrated with Firebase, it offers:

- **📄 Document Management**: Create, edit, merge, split, and convert PDFs and Word documents
- **📝 CV/Resume Builder**: Professional CV creation with multiple templates and export options
- **🔍 OCR Technology**: Extract text from images using Google ML Kit's advanced text recognition
- **🖼️ Image Processing**: Convert, crop, compress, and enhance images with ease
- **📁 File Operations**: Compress, encrypt, transfer, and organize files efficiently
- **☁️ Cloud Integration**: Secure cloud storage and synchronization with Firebase
- **🔐 Security**: File encryption and secure authentication options
- **🌐 Multi-language Support**: Internationalization with GetX localization

Perfect for professionals, students, and anyone who needs powerful file and document management tools on the go.

---

## 🚀 Features

### 📄 Document & PDF Management
- Generate and preview PDF files
- Open DOCX templates and export documents
- View and print PDFs with ease
- Select files from device storage using file picker

### 🔍 OCR & Image Processing
- Scan and extract text from images using Google ML Kit OCR
- Crop and compress images with high performance
- Capture images via camera or gallery

### 🔐 Security & File Management
- Encrypt sensitive data and files
- Securely store files using Firebase Storage
- View, open, and share files with external apps

### ☁️ Cloud & Firebase Integration
- Google Sign-In and Firebase Authentication
- Store and retrieve user data from Cloud Firestore
- Upload documents to Firebase Storage

### 📦 Other Utilities
- QR Code scanner and generator
- Local notification system
- Device info access and permission handling
- Drop-down menus and dotted borders for a clean UI

---

## 🎨 UI & Assets

- Beautiful onboarding screens
- Avatar and template image sets
- Material and Cupertino icons
- Custom fonts with Google Fonts support

---

## 🛠 Tech Stack

- **Flutter 3.5.1+**
- **Firebase (Auth, Firestore, Storage)**
- **Google ML Kit**
- **Dart**
- **Provider / GetX for State Management**

---

## 📲 Getting Started

### Prerequisites

- Flutter SDK 3.5.1 or higher
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for mobile development)
- Firebase account and project setup

### Installation

1. **Clone the repository**  
   ```bash
   git clone https://github.com/your-username/toolkit.git
   cd toolkit
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android app and download `google-services.json` → place in `android/app/`
   - Add iOS app and download `GoogleService-Info.plist` → add to `ios/Runner/`
   - Enable Authentication (Email/Password, Google Sign-In, Phone)
   - Enable Firestore Database and Firebase Storage

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ipa --release
```

---

## 📸 Screenshots

*Add screenshots of your app here*

---

## 🏗️ Project Structure

```
lib/
├── controllers/     # Business logic controllers
├── models/         # Data models
├── provider/       # State management (Provider)
├── screens/        # UI screens
├── services/       # Business logic services
├── utils/          # Utility functions
└── widgets/        # Reusable components
```

---

## 🔧 Key Features in Detail

### 📄 Document & PDF Management
- Generate PDFs from templates and data
- Merge multiple PDFs into one
- Split PDFs into separate files
- Convert PDFs to images and Word documents
- View and print PDFs with built-in viewer

### 📝 CV/Resume Builder
- Multiple professional templates
- Step-by-step guided creation
- Sections: Personal Info, Work Experience, Education, Skills, Certifications, Languages
- Preview and export as PDF
- Save and edit saved CVs

### 🔍 OCR (Optical Character Recognition)
- Extract text from images using Google ML Kit
- Camera and gallery integration
- Edit extracted text before saving
- Export text to various formats

### 🖼️ Image Processing
- Convert between image formats (PNG, JPEG, etc.)
- Crop images with custom aspect ratios
- Compress images to reduce file size
- Quality and format selection

### 📁 File Management
- Browse and organize files
- Compress files to ZIP format
- Encrypt sensitive files
- Share files via system share dialog
- Recent files and favorites
- File search functionality

### 📡 File Transfer
- Generate QR codes for file sharing
- Scan QR codes to receive files
- Wireless file transfer without internet

### 📷 Document Scanner
- Multi-page document scanning
- Automatic edge detection
- Image enhancement
- Export as PDF or images

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.5.1+
- **Language**: Dart
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider + GetX
- **OCR**: Google ML Kit
- **Local Storage**: Hive + SharedPreferences
- **PDF Processing**: Syncfusion Flutter PDF, PDFX
- **Image Processing**: Image Cropper, Flutter Image Compress
- **File Operations**: File Picker, Archive, Open File

---

## 📦 Dependencies

Key dependencies include:
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `google_mlkit_text_recognition`
- `syncfusion_flutter_pdf`, `pdfx`, `printing`
- `file_picker`, `open_file`, `share_plus`
- `image_picker`, `image_cropper`, `flutter_image_compress`
- `qr_code_scanner_plus`, `pretty_qr_code`
- `provider`, `get`
- `hive_ce_flutter`, `shared_preferences`

See `pubspec.yaml` for complete list.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👤 Author

**Muhammad Humayun Amar*
- GitHub: [@amarhumayunx](https://github.com/amarhumayunx)
- Email: amarhumayun@outlook.com

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Google ML Kit for OCR capabilities
- All open-source contributors whose packages made this project possible
