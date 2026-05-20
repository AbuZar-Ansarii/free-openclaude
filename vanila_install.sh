#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 🤖 Claude Code Vanilla Installer (No Phone Control)
# =========================================================================
# Designed to run via: curl -sL <url> | bash
# Fully non-interactive — bypasses all Termux Y/N prompts.
# =========================================================================

export DEBIAN_FRONTEND=noninteractive
export DPKG_FORCE=confold
export APT_LISTCHANGES_FRONTEND=none
export LANG=C
export LC_ALL=C

echo ""
echo "🤖 Installing Openclaude..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# =========================================================================
# Step 1: Update Packages & Install Dependencies
# =========================================================================
echo "📦 Step 1/2: Updating packages and installing dependencies..."

pkg update -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" </dev/null 2>&1 || true
pkg upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" </dev/null 2>&1 || true

# Removed android-tools since we no longer need ADB/UIAutomator
pkg install -y curl nodejs-lts git which </dev/null 2>&1

echo "✅ Dependencies installed"

# =========================================================================
# Step 2: Install Claude Code CLI
# =========================================================================
echo ""
echo "🧠 Step 2/2: Installing OpenClaude..."

# Apply IPv4 Node.js fix to prevent network timeouts in Termux
if ! grep -q "NODE_OPTIONS=--dns-result-order=ipv4first" ~/.bashrc 2>/dev/null; then
    echo "export NODE_OPTIONS=--dns-result-order=ipv4first" >> ~/.bashrc
fi
export NODE_OPTIONS=--dns-result-order=ipv4first

npm install -g @gitlawb/openclaude </dev/null 2>&1

echo "✅ OpenClaude installed"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 SETUP COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "To start your AI assistant, type:"
echo "  openclaude"
echo ""