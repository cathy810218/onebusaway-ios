//
//  DataLoader.swift
//  watchOSExtension
//
//  Created by Aaron Brethorst on 8/16/21.
//

import Foundation
import OBAKitCore
import CoreLocation

public class DataLoader: ObservableObject {
    @Published var stops: [Stop] = []
    @Published var fetchError: Bool = false

    private let coreApp: CoreApplication

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
        self.coreApp.regionsService.currentRegion = self.coreApp.regionsService.find(id: 1)
    }

    public func fetch() {
        guard let apiService = coreApp.restAPIService else {
            fatalError()
        }

        let coord = CLLocationCoordinate2D(latitude: 47.6233777323687, longitude: -122.31264760176147)

        let op = apiService.getStops(coordinate: coord)

        op.complete { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("Doh: \(error)")
            case .success(let response):
                self.stops = response.list
            }
        }
    }
}
