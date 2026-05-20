#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 🤖 OpenClaude + Shizuku Universal Phone Controller Installer
# =========================================================================
# Designed to run via: curl -sL <url> | bash
# Fully non-interactive — bypasses all Termux Y/N prompts.
# =========================================================================

# ── Global Settings ──────────────────────────────────────────────────────
export DEBIAN_FRONTEND=noninteractive
export DPKG_FORCE=confold
export APT_LISTCHANGES_FRONTEND=none
export LANG=C
export LC_ALL=C

echo ""
echo "🤖 Installing OpenClaude Phone Controller..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# =========================================================================
# Step 1: Update Packages & Install Dependencies (Non-Interactive)
# =========================================================================
echo "📦 Step 1/5: Updating packages and installing dependencies..."

# The -y flag answers yes. The -o flags tell it to keep old config files instead of asking.
pkg update -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" </dev/null 2>&1 || true
pkg upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" </dev/null 2>&1 || true

pkg install -y curl nodejs-lts git android-tools which </dev/null 2>&1

echo "✅ Dependencies installed"

# =========================================================================
# Step 2: Setup Termux Storage & Shizuku
# =========================================================================
echo ""
echo "🔒 Step 2/5: Linking Shizuku to Termux..."

if [ ! -d "$HOME/storage" ]; then
    echo "A popup may appear asking for file permissions. Please tap 'Allow'."
    echo "y" | termux-setup-storage > /dev/null 2>&1 || true
    sleep 3
fi

SHIZUKU_DIR="$HOME/storage/shared/Shizuku"
if [ ! -f "$SHIZUKU_DIR/rish_shizuku.dex" ]; then
    echo "❌ ERROR: rish_shizuku.dex not found!"
    echo "Please open the Shizuku app -> Use in terminal apps -> Export files to the 'Shizuku' folder in your internal storage, then run this installer again."
    exit 1
fi

# Copy the Shizuku binaries into Termux's bin folder
cp "$SHIZUKU_DIR/rish" "$PREFIX/bin/rish"
cp "$SHIZUKU_DIR/rish_shizuku.dex" "$PREFIX/bin/rish_shizuku.dex"
chmod +x "$PREFIX/bin/rish"
sed -i 's/PKG/com.termux/' "$PREFIX/bin/rish"

echo "✅ Shizuku (rish) successfully linked"

# =========================================================================
# Step 3: Install Claude Code CLI
# =========================================================================
echo ""
echo "🧠 Step 3/5: Installing OpenClaude..."

# Apply IPv4 Node.js fix to prevent network timeouts in Termux
if ! grep -q "NODE_OPTIONS=--dns-result-order=ipv4first" ~/.bashrc 2>/dev/null; then
    echo "export NODE_OPTIONS=--dns-result-order=ipv4first" >> ~/.bashrc
fi
export NODE_OPTIONS=--dns-result-order=ipv4first

# Install Claude globally via npm
npm install -g @gitlawb/openclaude </dev/null 2>&1

echo "✅ OpenClaude installed"

# =========================================================================
# Step 4: Create the Phone Control API Wrapper
# =========================================================================
echo ""
echo "📱 Step 4/5: Building the Phone Control Wrapper..."

cat > ~/phone_control.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
CMD="$1"
shift
run_cmd() {
  if command -v rish &>/dev/null; then rish -c "$@"
  else echo "❌ Error: Start Shizuku first"; exit 1; fi
}
case "$CMD" in
  open-app) run_cmd "monkey -p $1 -c android.intent.category.LAUNCHER 1" 2>/dev/null ;;
  tap) run_cmd "input tap $1 $2" ;;
  swipe) run_cmd "input swipe $1 $2 $3 $4 ${5:-500}" ;;
  text) run_cmd "input text '$*'" ;;
  key) run_cmd "input keyevent $1" ;;
  home) run_cmd "input keyevent 3" ;;
  ui-dump) 
    run_cmd "uiautomator dump /sdcard/window_dump.xml >/dev/null 2>&1"
    node -e "
      const fs = require('fs');
      try {
        const xml = fs.readFileSync('/sdcard/window_dump.xml', 'utf8');
        const regex = /(?:text|content-desc)=\\\"([^\\\"]+)\\\"[^>]*bounds=\\\"(\\\[[0-9]+,[0-9]+\\\\]\\\[[0-9]+,[0-9]+\\\])\\\"/g;
        let match;
        while ((match = regex.exec(xml)) !== null) {
          if (match[1].trim() !== '') console.log(match[2] + ' ' + match[1]);
        }
      } catch(e) { console.log('Error reading UI'); }
    "
    ;;
  shell) run_cmd "$*" ;;
  *) echo "Usage: bash phone_control.sh [open-app|tap|swipe|text|key|home|ui-dump|shell]" ;;
esac
EOF
chmod +x ~/phone_control.sh

echo "✅ phone_control.sh generated"

# =========================================================================
# Step 5: Inject the System Prompt (CLAUDE.md)
# =========================================================================
echo ""
echo "📝 Step 5/5: Configuring Claude's Memory..."

cat > ~/CLAUDE.md << 'EOF'
# Autonomous Android Navigation Directive

You are running natively on an Android phone via Termux + Shizuku. 
You have full root-level control over this device using the script `~/phone_control.sh`. 

## Core Rules:
1. NEVER say "I cannot navigate UIs" or "I cannot read UIs". You possess these capabilities.
2. To "see" the screen, you MUST run `bash ~/phone_control.sh ui-dump`. This extracts clickable elements and their coordinates in the format `[x1,y1][x2,y2] ElementText`.
3. Read the output, find your target text, calculate the exact center (X, Y) between the bounds, and tap it.
4. DO NOT STOP AFTER ONE COMMAND. You must loop your tool calls continuously (Dump -> Parse -> Tap -> Dump -> Parse -> Type) until the user's requested task is 100% complete.

## Available Tools:
- `bash ~/phone_control.sh ui-dump` - Reads the screen. ALWAYS use this after screen changes.
- `bash ~/phone_control.sh tap X Y` - Taps specific coordinates.
- `bash ~/phone_control.sh swipe X1 Y1 X2 Y2` - Swipes/scrolls (e.g., `swipe 500 1500 500 500` to scroll down).
- `bash ~/phone_control.sh text "your text"` - Types text into a focused text box.
- `bash ~/phone_control.sh key 66` - Presses Enter/Search.
- `bash ~/phone_control.sh open-app com.android.chrome` - Opens a specific app.
EOF

echo "✅ CLAUDE.md brain injected"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 SETUP COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "To start your autonomous agent, type:"
echo "  openclaude"
echo ""