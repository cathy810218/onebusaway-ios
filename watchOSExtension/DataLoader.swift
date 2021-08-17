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
    @Published var fetchError: Error?

    public var coreApp: CoreApplication?

    public func fetch() {
        guard
            let coreApp = coreApp,
            let apiService = coreApp.restAPIService
        else {
            fatalError()
        }

        let coord = CLLocationCoordinate2D(latitude: 47.6233777323687, longitude: -122.31264760176147)

        let op = apiService.getStops(coordinate: coord)

        op.complete { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.fetchError = error
            case .success(let response):
                self.stops = response.list
            }
        }
    }
}
