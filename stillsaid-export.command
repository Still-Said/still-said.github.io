#!/bin/bash
# ──────────────────────────────────────────────────────
#  StillSaid — iMessage Export Tool (Mac only)
#  Exports your iPhone text messages so they can be
#  turned into a keepsake by StillSaid.
# ──────────────────────────────────────────────────────

clear

echo ""
echo "  ┌──────────────────────────────────────────────┐"
echo "  │                                              │"
echo "  │   StillSaid — iMessage Export                │"
echo "  │                                              │"
echo "  │   This tool exports your text messages       │"
echo "  │   so we can turn them into a keepsake.       │"
echo "  │                                              │"
echo "  │   Nothing leaves your computer.              │"
echo "  │   You choose what to share with us.          │"
echo "  │                                              │"
echo "  └──────────────────────────────────────────────┘"
echo ""

# ─── Check macOS ───
if [[ "$(uname)" != "Darwin" ]]; then
    echo "  This tool only works on Mac. For other platforms,"
    echo "  please contact us at stillsaid@proton.me"
    echo ""
    read -p "  Press Enter to exit..."
    exit 1
fi

# ─── FIRST: Check Full Disk Access ───
# Do this before installing anything so the user doesn't sit
# through installs only to hit a permission wall at the end.

CHAT_DB="$HOME/Library/Messages/chat.db"
if [[ ! -r "$CHAT_DB" ]]; then
    echo ""
    echo "  Before we start, your Mac needs to give this app"
    echo "  permission to read your messages."
    echo ""
    echo "  This is a one-time setup that takes about 30 seconds:"
    echo ""
    echo "    1. Open System Settings"
    echo "       (click the Apple menu at the top-left of your screen)"
    echo ""
    echo "    2. Click 'Privacy & Security' in the left sidebar"
    echo ""
    echo "    3. Scroll down and click 'Full Disk Access'"
    echo ""
    echo "    4. Click the + button and add 'Terminal'"
    echo "       (or toggle it ON if it's already listed)"
    echo ""
    echo "    5. Close Terminal completely (Cmd+Q)"
    echo ""
    echo "    6. Double-click this file again to re-run"
    echo ""
    echo "  ─────────────────────────────────────────────"
    echo "  Need help? Email us: stillsaid@proton.me"
    echo "  ─────────────────────────────────────────────"
    echo ""
    read -p "  Press Enter to close..."
    exit 1
fi

# ─── If we get here, permission is good. Now install tools. ───

echo "  Setting things up (this may take a couple of minutes"
echo "  the first time — after that it's instant)..."
echo ""

# ─── Check/Install Homebrew ───
if ! command -v brew &>/dev/null; then
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        echo "  Installing a helper tool (Homebrew)..."
        echo "  You may be asked for your Mac password — this is normal."
        echo ""
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        if ! command -v brew &>/dev/null; then
            echo ""
            echo "  Something went wrong with the setup."
            echo "  Please email us at stillsaid@proton.me and we'll help."
            echo ""
            read -p "  Press Enter to close..."
            exit 1
        fi
    fi
fi

# ─── Check/Install imessage-exporter ───
if ! command -v imessage-exporter &>/dev/null; then
    echo "  Installing the message export tool..."
    echo ""
    brew install imessage-exporter 2>&1 | while read line; do
        echo "    $line"
    done
    echo ""

    if ! command -v imessage-exporter &>/dev/null; then
        echo "  Something went wrong with the setup."
        echo "  Please email us at stillsaid@proton.me and we'll help."
        echo ""
        read -p "  Press Enter to close..."
        exit 1
    fi
fi

# ─── Run the export ───
echo ""
echo "  Exporting your messages..."
echo "  (this may take a minute if you have a lot of conversations)"
echo ""

OUTPUT_DIR="$HOME/Desktop/StillSaid Export"
mkdir -p "$OUTPUT_DIR"

imessage-exporter -f txt -o "$OUTPUT_DIR" 2>&1

# Verify files were actually created
FILE_COUNT=$(find "$OUTPUT_DIR" -name "*.txt" -type f 2>/dev/null | wc -l | tr -d ' ')

if [[ "$FILE_COUNT" -eq 0 ]]; then
    echo ""
    echo "  The export didn't produce any files."
    echo "  This can happen if your messages aren't synced to this Mac."
    echo ""
    echo "  Make sure 'Messages in iCloud' is turned on:"
    echo "    System Settings > [your name] > iCloud > Messages"
    echo ""
    echo "  Need help? Email us: stillsaid@proton.me"
    echo ""
    read -p "  Press Enter to close..."
    exit 1
fi

# ─── Success ───
clear

echo ""
echo "  ┌──────────────────────────────────────────────┐"
echo "  │                                              │"
echo "  │   Export complete!                            │"
echo "  │                                              │"
echo "  │   $FILE_COUNT conversation(s) exported.              │"
echo "  │                                              │"
echo "  └──────────────────────────────────────────────┘"
echo ""
echo "  Your messages are in the 'StillSaid Export' folder"
echo "  on your Desktop. We've opened it for you."
echo ""
echo "  ─────────────────────────────────────────────"
echo ""
echo "  WHAT TO DO NEXT"
echo ""
echo "  1. Look through the folder and find the conversation"
echo "     you'd like turned into a keepsake."
echo "     (files are named by phone number or contact name)"
echo ""
echo "  2. Email just that file to:"
echo ""
echo "         stillsaid@proton.me"
echo ""
echo "     We'll take it from there."
echo ""
echo "  3. After you've sent the file, feel free to delete"
echo "     the 'StillSaid Export' folder from your Desktop."
echo ""
echo "  ─────────────────────────────────────────────"
echo ""
echo "  Questions? Email stillsaid@proton.me"
echo ""

# Open the output folder
open "$OUTPUT_DIR"

# Open intake page
open "https://stillsaid.com/intake.html"

read -p "  Press Enter to close this window..."
