//
//  StateBag.swift
//  watchOSExtension
//
//  Created by Aaron Brethorst on 8/17/21.
//

import Foundation
import OBAKitCore

public class StateBag: ObservableObject {
    public let coreApp: CoreApplication

    init() {
        let appBundle = Bundle.main
        let appGroup = appBundle.appGroup
        assert(appGroup != nil)

        let appConfig = CoreAppConfig(
            appBundle: appBundle,
            userDefaults: UserDefaults(suiteName: appGroup)!,
            bundledRegionsFilePath: appBundle.bundledRegionsFilePath!
        )

        self.coreApp = CoreApplication(config: appConfig)
    }
}
