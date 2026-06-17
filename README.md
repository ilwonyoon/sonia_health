# Sonia Health — iOS Voice Therapist (Prototype)

An AI **voice-centric therapist** app for iOS. Tap to talk; Sonia listens, reflects,
and responds out loud using evidence-based techniques (Motivational Interviewing + light
CBT) with a strict crisis-safety protocol.

> Sonia is an AI wellness companion — **not** a licensed therapist and **not** a
> substitute for professional care. In a crisis, call or text **988** (US) or your
> local emergency number.

## Stack

- **SwiftUI**, iOS 18+, generated with **XcodeGen** (`project.yml`)
- **Cartesia** for real-time speech: `ink-whisper` STT + `sonic-3` TTS over WebSockets
- **Anthropic Claude** (`claude-sonnet-4-5`) for the therapist turn
- **AVAudioEngine** for mic capture (16 kHz PCM-S16LE) and TTS playback (24 kHz)
- Design system **ported from SaveReset** (liquid-glass nav/bottom bars, tokens, headers)

## Project layout

```
project.yml                      XcodeGen spec
SoniaHealth/
  App/                           @main entry + RootView
  Routing/                       AppRoute + AppRouter (central observable router)
  DesignSystem/                  Ported SR* tokens / foundation / components
    Tokens/  Theme/  Foundation/  Components/
  Voice/                         Voice pipeline
    SoniaSystemPrompt.swift      Evidence-based therapist prompt
    CartesiaConfig.swift         Endpoints, models, voice IDs, secret loading
    AudioSessionController.swift  AVAudioEngine capture + playback
    CartesiaSTTClient.swift      STT WebSocket (turn transcript)
    CartesiaTTSClient.swift      TTS WebSocket (streamed PCM)
    ClaudeClient.swift           Anthropic Messages API
    VoiceSessionViewModel.swift  Session state machine
  Features/
    Home/                        HomeView + SettingsSheet
    Session/                     SessionView + VoiceOrbView
  Resources/                     Info.plist, Assets.xcassets
  Config/                        Secrets.xcconfig (gitignored) + example
docs/THERAPIST_RESEARCH.md       Research + system-prompt rationale
```

## Voice pipeline

```
mic ──16kHz PCM──▶ Cartesia STT (ink-whisper) ──transcript──▶ Claude (Sonia prompt)
                                                                      │
 speaker ◀──24kHz PCM── Cartesia TTS (sonic-3, "Skylar") ◀──reply────┘
```

`VoiceSessionViewModel` drives the states: `connecting → idle → listening → thinking →
speaking`. The prototype is half-duplex (tap to speak, tap to send).

## Setup

1. **Secrets** — copy the example and fill in keys:
   ```sh
   cp SoniaHealth/Config/Secrets.example.xcconfig SoniaHealth/Config/Secrets.xcconfig
   # CARTESIA_API_KEY  (https://play.cartesia.ai/keys)
   # ANTHROPIC_API_KEY (https://console.anthropic.com)
   ```
2. **Generate the project** (requires `brew install xcodegen`):
   ```sh
   xcodegen generate
   ```
3. **Run** — open `SoniaHealth.xcodeproj` and run on an iOS 18+ simulator or device,
   or:
   ```sh
   xcodebuild -scheme SoniaHealth -destination 'platform=iOS Simulator,name=iPhone 16' build
   ```

> The generated `SoniaHealth.xcodeproj` and `Secrets.xcconfig` are intentionally
> gitignored. `project.yml` is the source of truth.

## Security note

The prototype calls Cartesia and Anthropic directly from the device with API keys in the
app bundle. **For production, move these calls behind a backend** so keys never ship in
the binary, and issue short-lived session tokens to the client.
