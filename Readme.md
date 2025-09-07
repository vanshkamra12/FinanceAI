# FinanceAI 💰

A comprehensive personal finance management app built with SwiftUI and Core Data. FinanceAI helps you track expenses, manage budgets, set financial goals, and gain insights into your spending patterns with beautiful charts and smart notifications.

## ✨ Features

### 📊 Core Functionality
- **Transaction Management** - Add, edit, and categorize income/expenses
- **Budget Tracking** - Set monthly budgets and track spending by category
- **Goal Setting** - Create and monitor financial goals with progress tracking
- **Advanced Search** - Filter and search transactions with multiple criteria
- **Analytics & Reports** - Visual spending insights with interactive charts

### 🎨 User Experience
- **Theme Support** - Light/Dark mode with customizable color schemes
- **Smart Notifications** - Budget alerts and goal reminders
- **Data Backup** - Export data as JSON/CSV, iCloud sync support
- **Receipt Management** - Photo attachment for transactions
- **Quick Actions** - Fast expense entry with transaction templates

### 🚀 Advanced Features
- **Recurring Transactions** - Automate regular income/expenses
- **Category Management** - Custom spending categories with icons
- **Data Visualization** - iOS 16+ Charts integration
- **Widget Support** - Home screen widgets (iOS 14+)
- **Siri Shortcuts** - Voice-activated transaction entry

## 📱 Screenshots

*Add screenshots here showing different views of your app*

## 🛠 Tech Stack

- **Framework**: SwiftUI (iOS 15+)
- **Database**: Core Data with CloudKit sync
- **Charts**: Swift Charts (iOS 16+)
- **Architecture**: MVVM pattern
- **Storage**: iCloud integration for data persistence
- **Notifications**: UserNotifications framework

## 📋 Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## 🚀 Installation

1. Clone the repository:
```bash
git clone https://github.com/vanshkamra12/FinanceAI.git
```

2. Open `FinanceAI.xcodeproj` in Xcode

3. Select your development team in Signing & Capabilities

4. Build and run the project (⌘R)

## 🏗 Project Structure

```
FinanceAI/
├── FinanceAI/
│   ├── Core/
│   │   ├── ContentView.swift
│   │   ├── FinanceAIApp.swift
│   │   └── Persistence.swift
│   ├── Views/
│   │   ├── Transaction/
│   │   ├── Budget/
│   │   ├── Goals/
│   │   └── Analytics/
│   ├── Managers/
│   │   ├── ThemeManager.swift
│   │   └── NotificationManager.swift
│   └── Models/
├── FinanceAI Widgets/
└── Resources/
```

## 📊 Key Components

### Data Models
- **Transaction**: Core financial transactions with categories
- **Budget**: Monthly spending limits by category
- **Goal**: Financial goals with target amounts and dates
- **Receipt**: Photo attachments for transactions

### Core Views
- **ContentView**: Main dashboard with balance overview
- **AddTransactionView**: Quick transaction entry
- **AnalyticsView**: Spending insights and charts
- **BudgetManagementView**: Budget creation and monitoring

## 🎯 Roadmap

- [ ] AI-powered spending insights
- [ ] Apple Pay integration
- [ ] Advanced receipt scanning with OCR
- [ ] Investment portfolio tracking
- [ ] Bill payment reminders
- [ ] Multi-currency support

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Vansh Kamra**
- GitHub: [@vanshkamra12](https://github.com/vanshkamra12)

## 📞 Support

If you have any questions or run into issues, please open an issue on GitHub or contact me directly.

---

⭐️ If you found this project helpful, please give it a star!
