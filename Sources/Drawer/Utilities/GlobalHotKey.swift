/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Carbon

@MainActor
final class GlobalHotKey {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    nonisolated(unsafe) private static var shared: GlobalHotKey?
    var onTrigger: (() -> Void)?

    private static let hotKeySignature: OSType = 0x44525752 // "DRWR"

    init() {
        Self.shared = self
    }

    func register(keyCode: UInt32, modifiers: UInt32) {
        unregister()

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, _ -> OSStatus in
                MainActor.assumeIsolated {
                    GlobalHotKey.shared?.onTrigger?()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )

        var hotKeyID = EventHotKeyID(
            signature: Self.hotKeySignature,
            id: 1
        )

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
    }

    /// Ctrl+Shift+D
    static let defaultKeyCode: UInt32 = UInt32(kVK_ANSI_D)
    static let defaultModifiers: UInt32 = UInt32(controlKey | shiftKey)
}
