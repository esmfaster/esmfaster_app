# ESMFaster - Modern Flutter E-commerce App

A modern, scalable Flutter e-commerce application with clean architecture, integrated WooCommerce support, and advanced wallet functionality.

## 🎨 Design & Branding

### Brand Colors
- **Primary**: #00b838 (ESMFaster Green)
- **Secondary**: #ff6a00 (Orange)
- **Success**: #4CAF50
- **Warning**: #FF9800
- **Error**: #F44336
- **Info**: #2196F3

### Design Philosophy
- Modern Material 3 design system
- Clean and intuitive user interface
- Responsive layouts for all screen sizes
- Accessibility-first approach

## 🏗️ Architecture

This project follows **Clean Architecture** principles with proper separation of concerns:

```
lib/
├── core/
│   ├── constants/          # App-wide constants (colors, dimensions, strings)
│   ├── errors/             # Error handling (failures, exceptions)
│   ├── network/            # Network utilities
│   └── utils/              # Utility functions and helpers
├── data/
│   ├── datasources/        # Data sources (remote, local)
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── features/
│   ├── home/               # Home feature
│   ├── products/           # Products catalog
│   ├── orders/             # Order management
│   ├── wallet/             # Wallet functionality
│   ├── map/                # Store locator
│   └── settings/           # App settings
└── presentation/
    ├── pages/              # Main app pages
    ├── widgets/            # Reusable widgets
    └── theme/              # App theming
```

### Feature Structure
Each feature follows the same clean architecture pattern:
```
feature/
├── data/
│   ├── datasources/        # API calls, local storage
│   ├── models/             # Data transfer objects
│   └── repositories/       # Repository implementations
├── domain/
│   ├── models/             # Domain entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business logic
└── presentation/
    ├── bloc/               # State management (BLoC)
    ├── pages/              # Feature pages
    └── widgets/            # Feature-specific widgets
```

## 🚀 Features

### ✅ Implemented Features

#### 🏠 Home Screen
- Welcome section with user greeting
- Balance summary card
- Quick actions (Add Money, Send Money, QR Scan)
- Feature grid navigation
- Recent activity feed

#### 🛍️ Products
- Product catalog with categories
- Filter and search functionality
- Product grid/list views
- Product details with ratings
- Add to cart functionality

#### 📦 Orders
- Order history with status tracking
- Order filtering by status
- Order details view
- Reorder functionality
- Track order feature

#### 💰 Wallet (Advanced)
- Real-time balance display
- Add money with multiple payment methods
- Withdraw to bank account
- Complete transaction history
- Transaction status tracking
- Secure payment processing

#### 🗺️ Map & Store Locator
- Interactive store map
- Store search and filtering
- Distance-based sorting
- Store details and contact info
- Get directions functionality
- Store availability status

#### ⚙️ Settings
- Profile management
- App preferences (notifications, biometric, theme)
- Language and currency selection
- Security settings (password, 2FA)
- Support and help center
- About and legal information

### 🔄 State Management
- **BLoC Pattern** for predictable state management
- Reactive programming with streams
- Event-driven architecture
- Proper error handling and loading states

### 🎨 UI/UX Features
- Modern Material 3 design
- Custom ESMFaster theme
- Smooth animations and transitions
- Loading states and error handling
- Responsive design for all screens
- Dark mode support (ready)

## 🛠️ Technical Stack

### Core Dependencies
- **flutter**: Latest stable version
- **flutter_bloc**: State management
- **equatable**: Value equality
- **dartz**: Functional programming
- **http**: Network requests
- **cached_network_image**: Image caching
- **intl**: Internationalization

### Development Tools
- **flutter_lints**: Code quality
- **bloc_test**: BLoC testing utilities
- **mockito**: Mocking for tests

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.6.0 or higher)
- Dart SDK
- Android Studio / VS Code
- iOS development tools (for iOS builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/esmfaster/esmfaster_app.git
   cd esmfaster_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the modern app**
   ```bash
   # Run the modern version
   flutter run lib/main_modern.dart
   ```

4. **Build for production**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

## 💳 Wallet System

The wallet system is built with enterprise-grade features:

### Features
- ✅ **Balance Management**: Real-time balance tracking
- ✅ **Top Up**: Add money via multiple payment methods
- ✅ **Withdrawals**: Secure bank transfers
- ✅ **Transaction History**: Complete audit trail
- ✅ **Status Tracking**: Pending, completed, failed states
- ✅ **Multi-currency Support**: Ready for international expansion

### Payment Methods
- Credit/Debit Cards
- Bank Transfers
- Mobile Money (M-Pesa, etc.)
- Digital Wallets

### Security
- Encrypted transactions
- Secure API communication
- Transaction verification
- Fraud detection ready

## 🏪 WooCommerce Integration

Ready for WooCommerce integration with:
- Product synchronization
- Order management
- Inventory tracking
- Customer data sync
- Payment processing

## 🧪 Testing

The app includes comprehensive testing:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📱 Platform Support

- ✅ **Android**: API level 21+
- ✅ **iOS**: iOS 12.0+
- 🔄 **Web**: Progressive Web App ready
- 🔄 **Desktop**: Windows, macOS, Linux support

## 🌐 Internationalization

Multi-language support ready:
- English (default)
- Spanish
- French
- Swahili (East Africa)
- More languages can be added easily

## 🔐 Security Features

- Secure API communication (HTTPS)
- Data encryption at rest
- Biometric authentication support
- Session management
- Secure payment processing
- Privacy-first design

## 📊 Performance

- Optimized build sizes
- Lazy loading for large datasets
- Image caching and optimization
- Efficient state management
- Memory leak prevention

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the existing code style
4. Add tests for new features
5. Submit a pull request

## 📄 License

This project is proprietary software owned by ESMFaster.

## 📞 Support

For technical support or questions:
- Email: support@esmfaster.com
- Documentation: [Developer Portal](https://developers.esmfaster.com)
- Issues: [GitHub Issues](https://github.com/esmfaster/esmfaster_app/issues)

---

**Built with ❤️ by the ESMFaster Team**