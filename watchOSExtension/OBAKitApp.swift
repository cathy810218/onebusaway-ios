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
    private let stateBag = StateBag()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(stateBag)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
