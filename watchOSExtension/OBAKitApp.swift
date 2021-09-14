//
//  OBAKitApp.swift
//  OBAKit watchOS Extension
//
//  Created by Aaron Brethorst on 8/15/21.
//

import SwiftUI
import OBAKitCore

@main
struct OBAKitApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
