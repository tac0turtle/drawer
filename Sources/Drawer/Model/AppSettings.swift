/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Foundation
import Observation

@Observable
@MainActor
final class AppSettings {
    private static let defaults = UserDefaults.standard

    var hideAtLaunch: Bool {
        get { Self.defaults.bool(forKey: "hideAtLaunch") }
        set { Self.defaults.set(newValue, forKey: "hideAtLaunch") }
    }

    var autoHideEnabled: Bool {
        get { Self.defaults.bool(forKey: "autoHideEnabled") }
        set { Self.defaults.set(newValue, forKey: "autoHideEnabled") }
    }

    var autoHideDelay: TimeInterval {
        get {
            let value = Self.defaults.double(forKey: "autoHideDelay")
            return value > 0 ? value : 10
        }
        set { Self.defaults.set(newValue, forKey: "autoHideDelay") }
    }

    var iconPadding: CGFloat {
        get {
            let value = Self.defaults.double(forKey: "iconPadding")
            return value > 0 ? CGFloat(value) : 25
        }
        set { Self.defaults.set(Double(newValue), forKey: "iconPadding") }
    }
}
