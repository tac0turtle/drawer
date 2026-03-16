/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Foundation
import Observation

@Observable
@MainActor
final class AutoHideController {
    private var hideTask: Task<Void, Never>?
    private let detector: InteractionDetecting
    var onHide: (() -> Void)?

    private static let pollInterval: Duration = .milliseconds(500)

    init(detector: InteractionDetecting = CGWindowListDetector()) {
        self.detector = detector
    }

    func scheduleHide(after delay: TimeInterval) {
        cancelHide()
        hideTask = Task { [weak self, detector] in
            let deadline = ContinuousClock.now + .seconds(delay)

            while !Task.isCancelled {
                try? await Task.sleep(for: Self.pollInterval)
                guard !Task.isCancelled else { return }

                if detector.isUserInteractingWithMenuBar() {
                    continue
                }

                if ContinuousClock.now >= deadline {
                    self?.onHide?()
                    return
                }
            }
        }
    }

    func cancelHide() {
        hideTask?.cancel()
        hideTask = nil
    }
}
