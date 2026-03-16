/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import SwiftUI

struct GeneralTab: View {
    @Bindable var manager: MenuBarManager
    @State private var loginItemEnabled = LoginItemManager.isEnabled
    @State private var loginItemError: String?

    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $loginItemEnabled)
                .onChange(of: loginItemEnabled) { _, newValue in
                    do {
                        try LoginItemManager.setEnabled(newValue)
                        loginItemError = nil
                    } catch {
                        loginItemError = error.localizedDescription
                        loginItemEnabled = !newValue
                    }
                }

            if let errorMessage = loginItemError {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Toggle("Hide at launch", isOn: Bindable(manager.settings).hideAtLaunch)

            Toggle("Auto-hide", isOn: Bindable(manager.settings).autoHideEnabled)

            if manager.settings.autoHideEnabled {
                Picker("Delay", selection: Bindable(manager.settings).autoHideDelay) {
                    ForEach(HidePolicy.defaultDelays, id: \.self) { delay in
                        Text("\(Int(delay))s").tag(delay)
                    }
                }
            }
        }
        .padding()
    }
}
