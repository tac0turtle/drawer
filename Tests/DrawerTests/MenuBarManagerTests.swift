/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

@testable import Drawer
import Testing
import Foundation

@Suite(.serialized)
@MainActor
struct MenuBarManagerTests {
    @Test func initialStateIsNotHidden() {
        let settings = AppSettings()
        settings.hideAtLaunch = false
        let manager = MenuBarManager(settings: settings)
        #expect(!manager.isHidden)
    }

    @Test func toggleFlipsState() {
        let settings = AppSettings()
        settings.hideAtLaunch = false
        let manager = MenuBarManager(settings: settings)
        manager.toggle()
        #expect(manager.isHidden)
        manager.toggle()
        #expect(!manager.isHidden)
    }

    @Test func showAndHideTransitions() {
        let settings = AppSettings()
        settings.hideAtLaunch = false
        let manager = MenuBarManager(settings: settings)
        manager.hide()
        #expect(manager.isHidden)
        manager.show()
        #expect(!manager.isHidden)
    }
}
