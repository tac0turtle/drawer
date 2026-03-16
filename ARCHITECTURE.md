# Drawer — macOS Menu Bar Manager

A lightweight macOS menu bar utility that hides and shows menu bar icons for a cleaner desktop. Spiritual successor to [Dozer](https://github.com/Mortennn/Dozer), rebuilt from scratch with modern Swift and zero dependencies.

## Context

Both Dozer (last commit ~2022) and [Ice](https://github.com/jordanbaird/Ice) (last real commit June 2025) are effectively abandoned. Ice is broken on macOS 26 with crash reports, layout bugs, and unmerged fix PRs. There's a real gap for a maintained, minimal menu bar manager.

Drawer takes the proven core mechanism from Dozer, drops every dependency, rewrites the architecture for testability, and targets modern macOS.

## Core Mechanism

macOS provides no API to control other apps' status items. The only approach that works without accessibility permissions:

1. Place an `NSStatusItem` as a **separator** in the menu bar
2. Set its `length` to `10_000` to push everything to its left off-screen
3. Set its `length` back to normal to reveal hidden items

```
Menu bar layout (left to right):

[hidden items] [separator ·] [visible items] [system tray]

Hidden:  separator.length = 10_000  → left items pushed off screen
Shown:   separator.length = padding → everything visible
```

This approach has survived every macOS update since 2018. Must be validated on macOS 26 early in development.

## Tech Stack

- **Language**: Swift 6, strict concurrency
- **UI**: SwiftUI
- **Target**: macOS 14+ (Sonoma)
- **Dependencies**: Zero third-party for v1
- **Build**: XcodeGen (`project.yml` committed, `.xcodeproj` gitignored)
- **Distribution**: Homebrew cask + direct download

## Project Structure

```
Drawer/
├── project.yml
├── Sources/
│   └── Drawer/
│       ├── DrawerApp.swift              # @main, App protocol, Settings scene
│       │
│       ├── Core/
│       │   ├── MenuBarManager.swift     # @Observable, owns separators, show/hide/toggle
│       │   ├── SeparatorItem.swift      # NSStatusItem wrapper — show/hide/position
│       │   ├── InteractionDetector.swift # Protocol + CGWindowList implementation
│       │   └── AutoHideController.swift # Async timer, interaction-aware delay
│       │
│       ├── Settings/
│       │   ├── SettingsView.swift       # SwiftUI Settings scene, tab layout
│       │   ├── GeneralTab.swift         # Launch at login, auto-hide, delay picker
│       │   └── AboutTab.swift           # Version, links
│       │
│       ├── Model/
│       │   ├── AppSettings.swift        # @AppStorage keys, single source of truth
│       │   └── HidePolicy.swift         # Auto-hide rules enum
│       │
│       └── Utilities/
│           └── LoginItemManager.swift   # SMAppService wrapper
│
└── Tests/
    └── DrawerTests/
        ├── MenuBarManagerTests.swift
        ├── AutoHideControllerTests.swift
        └── InteractionDetectorTests.swift
```

## Component Design

### MenuBarManager

Replaces Dozer's 412-line god-object singleton. Owns the separator, exposes `show()`/`hide()`/`toggle()`, coordinates with auto-hide. Injected via SwiftUI environment, not a singleton.

```swift
@Observable
final class MenuBarManager {
    private let separator: SeparatorItem
    private let autoHide: AutoHideController
    private(set) var isHidden: Bool = false
}
```

Target: ~50 lines.

### SeparatorItem

Wraps `NSStatusItem`. Handles click dispatch (left = toggle, right = settings, option+click = show all). Owns no state beyond the status item itself.

```swift
final class SeparatorItem {
    private let statusItem: NSStatusItem
    func show()           // length = configured padding
    func hide()           // length = 10_000
    var xPosition: CGFloat
    var isVisible: Bool
}
```

Target: ~40 lines.

### InteractionDetector

Protocol-based for testability. The CGWindowList implementation ports Dozer's window-level/owner/y-position detection logic with proper error handling (no force unwraps).

```swift
protocol InteractionDetecting: Sendable {
    func isUserInteractingWithMenuBar() -> Bool
}

struct CGWindowListDetector: InteractionDetecting { ... }
struct MockDetector: InteractionDetecting { ... }  // for tests
```

Detection algorithm: enumerate on-screen windows via `CGWindowListCopyWindowInfo`, identify status bar items (window level 25, height ~22), check if any status bar app has a child window positioned directly below it (indicating an open menu/popup).

Target: ~60 lines.

### AutoHideController

Replaces Dozer's tangled `Timer.scheduledTimer` mess with structured concurrency. Cancellation is automatic via `Task`.

```swift
@Observable
final class AutoHideController {
    private var hideTask: Task<Void, Never>?
    private let detector: InteractionDetecting

    func scheduleHide(after delay: TimeInterval)
    func cancelHide()
    func resetHide()
}
```

Target: ~40 lines.

### AppSettings

Replaces the `Defaults` library with native `@AppStorage`.

```swift
enum AppSettings {
    @AppStorage("hideAtLaunch") static var hideAtLaunch = false
    @AppStorage("autoHideEnabled") static var autoHideEnabled = false
    @AppStorage("autoHideDelay") static var autoHideDelay: TimeInterval = 10
    @AppStorage("iconPadding") static var iconPadding: Double = 25
}
```

### LoginItemManager

Replaces the `LaunchAtLogin` library with `SMAppService` (built into macOS 13+).

```swift
struct LoginItemManager {
    static var isEnabled: Bool { SMAppService.mainApp.status == .enabled }
    static func setEnabled(_ enabled: Bool) throws { ... }
}
```

## Differences from Dozer

| Problem in Dozer | Fix in Drawer |
|---|---|
| 412-line god singleton | 4 focused types, each < 60 lines |
| `Timer.scheduledTimer` with retain cycles | `Task` with structured concurrency |
| Force unwraps (`as!`, `!`) everywhere | Optional chaining, guard-let |
| Carthage + 5 dependencies | Zero dependencies, native APIs |
| XIB + AppKit UI | SwiftUI Settings scene |
| No tests, untestable architecture | Protocol injection, tests from day 1 |
| macOS 10.13 | macOS 14+ |

## Feature Roadmap

### v1 — MVP

- Single separator dot in menu bar
- Left-click to toggle show/hide
- Right-click for settings / quit menu
- Auto-hide with configurable delay (5/10/15/30s)
- Hide at launch option
- Global keyboard shortcut (toggle)
- Launch at login
- SwiftUI settings window

### v2 — Polish

- Second separator for "always hidden" section
- Hover-to-reveal with configurable edge trigger
- Multi-monitor support
- Sparkle v2 for auto-updates (only external dependency)
- Menu bar item count / status indicator

### v3 — Differentiation

- App-aware profiles (different hidden sets per frontmost app)
- Focus mode integration (hide more in Do Not Disturb)
- Shortcuts.app action (expose toggle as a Shortcut)
- Raycast extension

## Estimated Size

v1 total: ~400-500 lines of Swift.

| Component | Lines |
|---|---|
| DrawerApp.swift | ~30 |
| MenuBarManager | ~50 |
| SeparatorItem | ~40 |
| InteractionDetector | ~60 |
| AutoHideController | ~40 |
| Settings views | ~120 |
| Model + Utilities | ~60 |
| Tests | ~100+ |

## License

MPL-2.0 (same as original Dozer).
