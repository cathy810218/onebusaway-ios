//
//  RouteSearchModelOperationTests.swift
//  OBAKitTests
//
//  Created by Aaron Brethorst on 11/5/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import XCTest
import Nimble
import CoreLocation
import MapKit
@testable import OBAKit
@testable import OBAKitCore

// swiftlint:disable force_cast

class RouteSearchModelOperationTests: OBATestCase {
    let query = "Link"
    let center = CLLocationCoordinate2D(latitude: 47.0, longitude: -122)
    let radius = 5000.0
    lazy var region = CLCircularRegion(center: center, radius: radius, identifier: "identifier")

    func testLoading_success() {
        let dataLoader = (restService.dataLoader as! MockDataLoader)
        let data = Fixtures.loadData(file: "routes-for-location-10.json")
        dataLoader.mock(URLString: "https://www.example.com/api/where/routes-for-location.json", with: data)

        let op = restService.getRoute(query: query, region: region)

        waitUntil { done in
            op.complete { result in
                switch result {
                case .failure(let error):
                    print("TODO FIXME handle error! \(error)")
                case .success(let response):
                    let routes = response.list

                    expect(routes.count) == 1

                    let route = routes.first!

                    expect(route.agency.id) == "1"
                    expect(route.agency.name) == "Metro Transit"
                    expect(route.color).to(beNil())
                    expect(route.routeDescription) == "Capitol Hill - Downtown Seattle"
                    expect(route.id) == "1_100002"
                    expect(route.longName).to(beNil())
                    expect(route.shortName) == "10"
                    expect(route.textColor).to(beNil())
                    expect(route.routeType) == .bus
                    expect(route.routeURL) == URL(string: "http://metro.kingcounty.gov/schedules/010/n0.html")!

                    done()
                }
            }
        }
    }
}
