# 🤝 Contributing to Sarthee AI

First off, thank you for considering contributing to **Sarthee AI**! It is contributions like yours that make Sarthee AI a top-tier mobility platform for urban India.

---

## 📋 Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How Can I Contribute?](#how-can-i-contribute)
   - [Reporting Bugs](#reporting-bugs)
   - [Suggesting Enhancements](#suggesting-enhancements)
   - [Pull Requests](#pull-requests)
3. [Development Workflow](#development-workflow)
4. [Coding Conventions](#coding-conventions)
5. [Security Policy](#security-policy)

---

## 📜 Code of Conduct

Help us keep Sarthee AI an open, welcoming, and inclusive community. Be respectful, constructive, and collaborative in all communications.

---

## 🛠️ How Can I Contribute?

### Reporting Bugs
Before creating a bug report, please check existing issues and our [Troubleshooting Guide](docs/TROUBLESHOOTING.md).

When submitting a bug report, include:
- A clear, descriptive title.
- Steps to reproduce the behavior.
- Expected vs. actual behavior.
- Operating system, Flutter version, and Node.js version.
- Terminal log output / stack traces.

### Pull Requests
1. Fork the repository and create a new feature branch (`git checkout -b feat/amazing-feature`).
2. Run backend test suite (`cd backend && npm test`) and ensure all 23 tests pass.
3. Run Flutter analyzer (`cd Sarthe_AI && flutter analyze`).
4. Ensure **NO API keys or secrets** are hardcoded in test files or comments.
5. Commit your changes (`git commit -m "feat(module): description"`).
6. Push to your branch and open a Pull Request against `main`.

---

## 💻 Development Workflow

### Backend Setup
```bash
cd backend
npm install
npm test
npm run dev
```

### Flutter Setup
```bash
cd Sarthe_AI
flutter pub get
flutter analyze
flutter run
```

---

## 🔒 Security Policy

If you discover a security vulnerability or exposed secret, **DO NOT** create a public issue. Please refer to our [Security Policy](docs/SECURITY.md) to report security issues privately.
