# 🤖 OpenClaude: Android & PC Setup

Welcome to the ultimate streamlined setup guide for running **OpenClaude** directly from your terminal. 

This repository provides a fully automated, non-interactive installation script designed specifically for Android devices using **Termux**. It bypasses standard permission hangs and network timeouts, getting your AI agent up and running in seconds. We also provide a quick-start guide for PC users.

---

## ✨ Features

- **One-Click Android Install:** No hanging on `Y/N` prompts. 
- **Automatic Dependency Resolution:** Installs Node.js, cURL, Git, and fixes network configurations automatically.
- **DNS Timeout Fix:** Automatically applies the IPv4 Node.js fix for Termux to prevent network drops.
- **Cross-Platform:** Run the exact same AI agent on your smartphone and your desktop.

---

## 📱 Installation (Android / Termux)

To get Claude Code running natively on your Android device, simply copy and paste the following one-line command into a fresh Termux session:

```bash
curl -sL "https://raw.githubusercontent.com/AbuZar-Ansarii/free-openclaude/master/vanila_install.sh" | bash
```
Note: The script will automatically update your packages, install Node.js, fix the Termux DNS routing, and globally install the @gitlawb/openclaude package.

## 🚀 Start
```
openclaude
```

**Inside OpenClaude:**

**run /provider for guided provider setup and saved profiles**
**run /onboard-github for GitHub Models onboarding**


## 💻 Installation (Windows / macOS / Linux)
Because OpenClaude is an official NPM package, installing it on a PC is incredibly straightforward.

### Prerequisites
You must have Node.js (v18 or higher) installed on your system.
Download [Node.js](https://nodejs.org/en/download) from the official website.

## 🚀Setup
Open your terminal (Command Prompt, PowerShell, or standard Terminal) and run:
```
npm install -g @gitlawb/openclaude
```

## Start
```
openclaude
```
**For Linux/macOS users: If you get a permission error, you may need to run** 

*sudo npm install -g @gitlawb/openclaude*
