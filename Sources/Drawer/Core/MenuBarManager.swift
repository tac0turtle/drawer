/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import AppKit
import Observation

@Observable
@MainActor
final class MenuBarManager {
    private let separator: SeparatorItem
    private let autoHide: AutoHideController
    private let hotKey: GlobalHotKey
    let settings: AppSettings

    private(set) var isHidden: Bool = false

    init(settings: AppSettings = AppSettings()) {
        self.settings = settings
        self.autoHide = AutoHideController()
        self.hotKey = GlobalHotKey()
        self.separator = SeparatorItem(iconPadding: { [settings] in
            settings.iconPadding
        })

        separator.onLeftClick = { [weak self] in
            self?.toggle()
        }

        separator.onRightClick = { [weak self] statusItem in
            self?.showContextMenu(for: statusItem)
        }

        autoHide.onHide = { [weak self] in
            self?.hide()
        }

        hotKey.onTrigger = { [weak self] in
            self?.toggle()
        }
        hotKey.register(
            keyCode: GlobalHotKey.defaultKeyCode,
            modifiers: GlobalHotKey.defaultModifiers
        )

        if settings.hideAtLaunch {
            Task {
                try? await Task.sleep(for: .milliseconds(150))
                hide()
            }
        }
    }

    func toggle() {
        if isHidden { show() } else { hide() }
    }

    func show() {
        separator.show()
        isHidden = false
        if settings.autoHideEnabled {
            autoHide.scheduleHide(after: settings.autoHideDelay)
        }
    }

    func hide() {
        separator.hide()
        isHidden = true
        autoHide.cancelHide()
    }

    private func showContextMenu(for statusItem: NSStatusItem) {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(
            title: isHidden ? "Show Menu Bar Icons" : "Hide Menu Bar Icons",
            action: #selector(handleToggle),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        let hintItem = NSMenuItem(
            title: "Toggle Shortcut: \u{2303}\u{21E7}D",
            action: nil,
            keyEquivalent: ""
        )
        hintItem.isEnabled = false
        menu.addItem(hintItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(
            title: "Settings\u{2026}",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit Drawer",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        separator.showMenu(menu)
    }

    @objc private func handleToggle() {
        toggle()
    }

    @objc private func openSettings() {
        SettingsOpener.shared.open()
    }
}
