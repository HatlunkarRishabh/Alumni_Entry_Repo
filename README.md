# 🎓 Alumni_Entry

**Alumni_Entry** is a **Flutter-based** application designed to streamline alumni event check-ins. The app scans QR codes, verifies user identity against **Google Sheets**, marks attendance, and prevents duplicate entries.

---

## 🚀 Features

- 🔍 **QR Code Scanning** – Scan alumni QR codes for verification.
- 📊 **Google Sheets Integration** – Fetch and verify user data.
- ✅ **Automatic Check-In** – Mark users as **present** upon verification.
- 🚫 **Duplicate Prevention** – Ensures each user can check in only once.
- ⚡ **Fast & Secure** – Built with Flutter for a smooth experience.

---

## 🛠️ Installation

### 1️⃣ Clone the Repository
```
git clone https://github.com/yourusername/Alumni_Entry.git
cd Alumni_Entry
```

### 2️⃣ Install Dependencies
```
flutter pub get
```

### 3️⃣ Run the App
```
flutter run
```

---

## 🎯 How It Works

1️⃣ **Scan QR Code** – Users scan a unique QR code.  
2️⃣ **Verify Identity** – The app searches **Google Sheets** for a matching key.  
3️⃣ **Mark Attendance** – If a match is found, the user is marked **present**.  
4️⃣ **Prevent Duplicates** – Already checked-in users are denied entry.  

---

## 📁 Project Structure

```
Alumni_Entry/
│── lib/                  # Main application code
│   ├── main.dart         # App entry point with first screen
│   ├── output.dart       # application main output screen after the scan 
│── pubspec.yaml          # Dependencies and configurations
│── README.md             # Project documentation
```

---

## 🏗️ Technologies Used

- **Flutter** – Cross-platform framework
- **Dart** – Programming language
- **Google Sheets API** – User data verification
- **QR Code Scanner** – User authentication
- **Firestore (Optional)** – For enhanced storage & verification

---

## 📌 Future Enhancements

- 📍 **Email & SMS Notifications**
- 📋 **Admin Dashboard for Attendance Tracking**
- 🔄 **Offline Check-In Support**

---

## 🤝 Contributing

1. Fork the repo.
2. Create a new branch: ***git checkout -b feature-xyz***
3. Commit changes: ***git commit -m "Added new feature"***
4. Push to the branch: ***git push origin feature-xyz***
5. Open a pull request.

---

## 📜 License

This project is licensed under the **MIT License**.

---

## 📞 Contact

📧 Email: [your.email@example.com](mailto:your.email@example.com)  
🐦 Twitter: [@yourhandle](https://twitter.com/yourhandle)  
🌐 Website: [yourwebsite.com](https://yourwebsite.com)  

---

⭐ **If you like this project, don't forget to star it!** ⭐
