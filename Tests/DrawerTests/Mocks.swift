/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

@testable import Drawer
import Foundation

final class MockDetector: InteractionDetecting, @unchecked Sendable {
    var interacting = false

    func isUserInteractingWithMenuBar() -> Bool {
        interacting
    }
}
