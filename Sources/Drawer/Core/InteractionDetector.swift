/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import CoreGraphics

protocol InteractionDetecting: Sendable {
    func isUserInteractingWithMenuBar() -> Bool
}

struct CGWindowListDetector: InteractionDetecting {
    static let statusBarWindowLevel = 25
    static let statusBarHeight = 22
    private static let childYOffsetMin = 22
    private static let childYOffsetMax = 30

    func isUserInteractingWithMenuBar() -> Bool {
        guard let windowList = CGWindowListCopyWindowInfo(
            .optionOnScreenOnly,
            kCGNullWindowID
        ) as? [[String: Any]] else {
            return false
        }

        let windows = windowList.compactMap(WindowInfo.init)
        let statusBarWindows = windows.filter { $0.isStatusBarItem }
        let nonStatusBarWindows = windows.filter {
            !$0.isStatusBarItem && $0.owner != "Drawer"
        }

        for popup in nonStatusBarWindows {
            for statusItem in statusBarWindows where statusItem.owner == popup.owner {
                let lower = statusItem.originY + Self.childYOffsetMin
                let upper = statusItem.originY + Self.childYOffsetMax
                if popup.originY >= lower && popup.originY <= upper {
                    return true
                }
            }
        }

        return false
    }
}

private struct WindowInfo {
    let owner: String
    let level: Int
    let originX: Int
    let originY: Int
    let width: Int
    let height: Int

    var isStatusBarItem: Bool {
        level == CGWindowListDetector.statusBarWindowLevel
            && height == CGWindowListDetector.statusBarHeight
    }

    init?(_ info: [String: Any]) {
        guard let level = info[kCGWindowLayer as String] as? Int,
              let owner = info[kCGWindowOwnerName as String] as? String,
              let bounds = info[kCGWindowBounds as String] as? [String: Int],
              let originX = bounds["X"],
              let originY = bounds["Y"],
              let width = bounds["Width"],
              let height = bounds["Height"]
        else {
            return nil
        }

        self.owner = owner
        self.level = level
        self.originX = originX
        self.originY = originY
        self.width = width
        self.height = height
    }
}
