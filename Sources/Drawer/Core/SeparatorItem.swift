/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import AppKit

private enum SeparatorLength {
    static let hide: CGFloat = 10_000
}

/// Two NSStatusItems working together:
/// - `anchor`: always-visible dot the user clicks (created first → right)
/// - `expander`: length toggles to 10,000 to push items off screen (created second → left of anchor)
@MainActor
final class SeparatorItem {
    private let anchor: NSStatusItem
    private let expander: NSStatusItem
    private let iconPadding: () -> CGFloat
    var onLeftClick: (() -> Void)?
    var onRightClick: ((NSStatusItem) -> Void)?

    init(iconPadding: @escaping () -> CGFloat) {
        self.iconPadding = iconPadding

        // Anchor created first → sits to the right
        anchor = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        // Expander created second → sits to the left of anchor
        expander = NSStatusBar.system.statusItem(withLength: iconPadding())

        setupAnchor()
        setupExpander()
    }

    func show() {
        expander.length = iconPadding()
        setExpanderDot(visible: true)
    }

    func hide() {
        expander.length = SeparatorLength.hide
        setExpanderDot(visible: false)
    }

    var isVisible: Bool {
        expander.length != SeparatorLength.hide
    }

    func showMenu(_ menu: NSMenu) {
        anchor.menu = menu
        anchor.button?.performClick(nil)
        anchor.menu = nil
    }

    // MARK: - Private

    private func setupAnchor() {
        guard let button = anchor.button else { return }

        let image = NSImage(
            systemSymbolName: "circle.fill",
            accessibilityDescription: "Drawer toggle"
        )
        let config = NSImage.SymbolConfiguration(pointSize: 7, weight: .regular)
        button.image = image?.withSymbolConfiguration(config)
        button.target = self
        button.action = #selector(handleClick)
        button.sendAction(on: [.leftMouseDown, .rightMouseDown])
    }

    private func setupExpander() {
        guard let button = expander.button else { return }

        let image = NSImage(
            systemSymbolName: "circle.fill",
            accessibilityDescription: "Drawer separator"
        )
        let config = NSImage.SymbolConfiguration(pointSize: 5, weight: .regular)
        button.image = image?.withSymbolConfiguration(config)
        button.appearsDisabled = true
        button.target = self
        button.action = #selector(handleClick)
        button.sendAction(on: [.leftMouseDown, .rightMouseDown])
    }

    private func setExpanderDot(visible: Bool) {
        expander.button?.isHidden = !visible
    }

    @objc private func handleClick(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }

        switch event.type {
        case .rightMouseDown:
            onRightClick?(anchor)
        default:
            onLeftClick?()
        }
    }
}
