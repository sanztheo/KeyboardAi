<div align="center">

<img src="img/banner.png" alt="KeyboardAi banner" width="100%" />

# KeyboardAi — iOS Keyboard that Improves Your Writing with AI

Improve grammar, style, and clarity in one tap — right from an iOS keyboard. Powered by OpenAI `gpt-4o-mini`, real‑time streaming, and a privacy‑first design.

<br/>

</div>

---

## Table of Contents

- Overview
- Features
- Security & Privacy
- Requirements
- Quick Setup
- Enable the Keyboard
- Usage
- Architecture
- Technical Details
- Troubleshooting (FAQ)
- Roadmap
- License & Credits

---

## Overview

KeyboardAi is an iOS keyboard that rewrites and refines your text to make it clearer, more correct, and more natural — without leaving your app. The extension reads the accessible text around the cursor, sends a request to the OpenAI API, and shows a live preview you can insert or replace.

> Recommended: iOS 15+ (streaming). iOS < 15 is supported with non‑streaming mode.

## Features

- One‑tap improvement: “✨ Improve Writing”
- Shorten text: “Make Shorter” (concise without losing meaning)
- Lengthen text: “Make Longer” (expands, adds transitions)
- Live preview: streamed result, then Replace / Insert / Copy
- Best‑effort context reading via `textDocumentProxy`
- Clear design, status indicators, and haptic feedback

## Security & Privacy

- API key stored securely in the iOS Keychain
- Secure sharing via App Groups (app + keyboard) `group.tye.KeyboardAi`
- No API key in plain text in the repo
- Encrypted (HTTPS) calls only to the OpenAI API
- No built‑in analytics; only text sent upon explicit user action is transmitted to the API

## Requirements

1) OpenAI account and API key (credits required)

2) Xcode capabilities for app/extension sharing:
- App Groups: `group.tye.KeyboardAi` on targets `KeyboardAi` and `KeyboardExtension`
- Keychain Sharing: same access group on both targets

## Quick Setup

```bash
open KeyboardAi.xcodeproj  # open the project in Xcode
```

In the `KeyboardAi` app:
- Enter your API key (`sk-…`)
- “💾 Save API Key”, then “🧪 Test API Key”

## Enable the Keyboard

1. iOS Settings → General → Keyboard → Keyboards → Add New Keyboard…
2. Choose “KeyboardExtension”
3. Enable “Allow Full Access” (required for networking)

## Usage

1. Place the cursor in any app (Notes, Mail, Messages…)
2. Switch to the “KeyboardExtension” keyboard (globe 🌐)
3. Type your text, then choose an action:
   - ✨ Improve Writing → corrects and improves
   - Make Shorter → makes it more concise
   - Make Longer → expands the idea
4. Preview live, then choose Replace, Insert, or Copy

Quick examples:

```
Improve   : i want go to store today maybe buy some thing
→ I want to go to the store today to maybe buy something.

Shorten   : In light of the fact that we are running behind schedule
→ We’re running behind schedule.

Lengthen  : The meeting was productive
→ The meeting was productive, covering our key milestones and clarifying next steps with clear owners and deadlines.
```

## Architecture

### Views and Styling (new layout)

```
KeyboardExtension/
 ├─ Views/
 │  ├─ KBColor.swift                 # Centralized palette (tileBG, midGreyText…)
 │  ├─ KeyboardHomeStyling.swift     # Home styling (Improve + Shorten + Lengthen)
 │  ├─ KeyboardControlsView.swift    # Home (buttons, status, bottom bar)
 │  ├─ BottomActionBarView.swift     # Bar [space | delete | return]
 │  └─ ImproveWritingView.swift      # AI preview (stream + Insert/Replace/Copy/Refresh/Back)
 ├─ Prompts/
 │  ├─ ImprovePrompt.swift           # System prompt for improvement
 │  ├─ ShortenPrompt.swift           # System prompt for shortening
 │  └─ LengthenPrompt.swift          # System prompt for lengthening
 ├─ KeyboardViewController.swift     # Orchestration + wiring of actions
 ├─ TextProxyBestEffort.swift        # Full read via proxy (scan + probes)
 └─ OpenAIService.swift              # SSE streaming (iOS 15+) + fallback
```

Xcode tip: if you see greyed‑out files after this move, drag‑drop the `Views/` folder into the `KeyboardExtension` target to refresh references.

```
KeyboardAi/
├─ KeyboardAi/                     # Host application (API key, test, guides)
│  ├─ ViewController.swift         # Configuration UI + API test
│  ├─ KeychainHelper.swift         # Secure storage (Keychain + App Group)
│  └─ OpenAIService.swift          # App: non‑streaming requests
│
└─ KeyboardExtension/              # Keyboard extension
   ├─ KeyboardViewController.swift # UI orchestration + logic
   ├─ Views/…                      # Views and styling (see above)
   ├─ Prompts/…                    # System prompts (Improve/Shorten/Lengthen)
   ├─ TextProxyBestEffort.swift    # Read “all accessible text”
   └─ OpenAIService.swift          # Extension: streaming requests (iOS 15+)
```

## Technical Details

- OpenAI model: `gpt-4o-mini` (fast/cost‑effective), `temperature = 0.3`
- SSE streaming on the extension (non‑streaming fallback for iOS < 15)
- Large input budget (≈ 10,000 tokens, ≈ 40,000 characters)
- “Best‑effort select all”: reads all accessible context without altering the document
- `OpenAIService` with `PromptKind` (`improve|shorten|lengthen`) and modular prompts
- Replace/Insert via `textDocumentProxy`; Copy and Refresh in the preview

### iOS limitations to know

- Keyboards cannot officially select text: reading is via before/after context
- Network access requires “Allow Full Access”
- Text after the cursor may be inaccessible depending on the host app

## Troubleshooting (FAQ)

- “API key not configured” → Save the key in the app, verify App Group + Keychain Sharing
- “No text to improve” → Type some text and ensure the cursor follows the text
- “Network request failed” → Enable Full Access, check your connection and key

Debug tip:

```swift
// In the extension
print("[KeyboardAI] captured=\(capturedText.count)")
print("[KeyboardAI] improved=\(improvedText.count)")
```

## Roadmap

- Writing styles (formal, concise, friendly…)
- Multiple suggestions with user choice
- Keyboard shortcuts and UI customization
- Local history + quick copy
- Streaming with progressive indicators

## License & Credits

Educational sample project. Use it freely to learn and build your ideas. Created by Sanz (October 31, 2025).

Note: Respect OpenAI’s policies and never share an API key publicly.
