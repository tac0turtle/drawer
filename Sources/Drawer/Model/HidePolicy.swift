/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Foundation

enum HidePolicy: Sendable {
    case manual
    case afterDelay(TimeInterval)

    static let defaultDelays: [TimeInterval] = [5, 10, 15, 30]
}
