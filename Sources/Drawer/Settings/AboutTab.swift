/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import SwiftUI

struct AboutTab: View {
    private var version: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "Unknown"
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)

            Text("Drawer")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Version \(version)")
                .foregroundStyle(.secondary)
                .font(.caption)

            Button("Quit Drawer") {
                NSApp.terminate(nil)
            }
        }
        .padding()
    }
}
