/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import SwiftUI

@main
struct DrawerApp: App {
    @State private var manager = MenuBarManager()
    @Environment(\.openSettings) private var openSettings

    var body: some Scene {
        SettingsOpener.shared.action = openSettings
        return Settings {
            SettingsView(manager: manager)
        }
    }
}
