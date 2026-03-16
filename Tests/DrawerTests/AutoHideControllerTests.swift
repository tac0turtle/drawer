/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

@testable import Drawer
import Testing
import Foundation

@Suite(.serialized)
@MainActor
struct AutoHideControllerTests {
    @Test func firesCallbackAfterDelay() async throws {
        let detector = MockDetector()
        let controller = AutoHideController(detector: detector)
        var didHide = false
        controller.onHide = { didHide = true }

        controller.scheduleHide(after: 0.1)
        try await Task.sleep(for: .seconds(1.5))

        #expect(didHide)
    }

    @Test func cancelPreventsCallback() async throws {
        let detector = MockDetector()
        let controller = AutoHideController(detector: detector)
        var didHide = false
        controller.onHide = { didHide = true }

        controller.scheduleHide(after: 0.1)
        controller.cancelHide()
        try await Task.sleep(for: .seconds(1))

        #expect(!didHide)
    }

    @Test func interactionDelaysHide() async throws {
        let detector = MockDetector()
        detector.interacting = true
        let controller = AutoHideController(detector: detector)
        var didHide = false
        controller.onHide = { didHide = true }

        controller.scheduleHide(after: 0.1)
        try await Task.sleep(for: .seconds(1))

        // Should not fire because detector reports ongoing interaction
        #expect(!didHide)
        controller.cancelHide()
    }
}
