/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import AppKit
import SwiftUI

@MainActor
final class SettingsOpener {
    static let shared = SettingsOpener()
    var action: OpenSettingsAction?

    func open() {
        action?()
        NSApp.activate(ignoringOtherApps: true)
    }
}
