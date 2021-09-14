//
//  StopsForRoute.swift
//  OBAKit
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import MapKit

// swiftlint:disable nesting

/// Retrieve the set of stops serving a particular route, including groups by direction of travel.
///
/// The stops-for-route method first and foremost provides a method for retrieving the set of stops
/// that serve a particular route. In addition to the full set of stops, we provide various
/// “stop groupings” that are used to group the stops into useful collections. Currently, the main
/// grouping provided organizes the set of stops by direction of travel for the route. Finally,
/// this method also returns a set of polylines that can be used to draw the path traveled by the route.
public class StopsForRoute: NSObject, Identifiable, Decodable, HasReferences {
    public var id: String {
        return routeID
    }

    let routeID: String
    public private(set) var route: Route!

    #if !os(watchOS)

    public let rawPolylines: [String]

    public lazy var polylines: [MKPolyline] = rawPolylines.compactMap { Polyline(encodedPolyline: $0).mkPolyline }

    public lazy var mapRect: MKMapRect = {
        var bounds = MKMapRect.null
        for p in polylines {
            bounds = bounds.union(p.boundingMapRect)
        }
        return bounds
    }()
    #endif

    let stopIDs: [String]
    public private(set) var stops: [Stop]!

    public private(set) var regionIdentifier: Int?

    public let stopGroupings: [StopGrouping]

    private enum CodingKeys: String, CodingKey {
        case routeID = "routeId"
        case rawPolylines = "polylines"
        case stopIDs = "stopIds"
        case stopGroupings
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        #if !os(watchOS)
        rawPolylines = try container.decode([PolylineEntity].self, forKey: .rawPolylines).compactMap { $0.points }
        #endif

        routeID = try container.decode(String.self, forKey: .routeID)
        stopIDs = try container.decode([String].self, forKey: .stopIDs)
        stopGroupings = try container.decode([StopGrouping].self, forKey: .stopGroupings)
    }

    // MARK: - HasReferences

    public func loadReferences(_ references: References, regionIdentifier: Int?) {
        route = references.routeWithID(routeID)!
        stops = references.stopsWithIDs(stopIDs)
        stopGroupings.loadReferences(references, regionIdentifier: regionIdentifier)
        self.regionIdentifier = regionIdentifier
    }

    // MARK: - Nested Types

    // MARK: - StopGrouping

    public class StopGrouping: NSObject, Decodable, HasReferences {
        public let ordered: Bool
        public let groupingType: String
        public let stopGroups: [StopGroup]

        public private(set) var regionIdentifier: Int?

        private enum CodingKeys: String, CodingKey {
            case ordered
            case groupingType = "type"
            case stopGroups
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            ordered = try container.decode(Bool.self, forKey: .ordered)
            groupingType = try container.decode(String.self, forKey: .groupingType)
            stopGroups = try container.decode([StopGroup].self, forKey: .stopGroups)
        }

        public func loadReferences(_ references: References, regionIdentifier: Int?) {
            stopGroups.loadReferences(references, regionIdentifier: regionIdentifier)
            self.regionIdentifier = regionIdentifier
        }
    }

    // MARK: - StopGroup

    public class StopGroup: NSObject, Decodable, HasReferences {
        public let id: String
        public let name: String
        public let groupingType: String

        #if !os(watchOS)
        public let polylines: [String]
        #endif

        let stopIDs: [String]
        public private(set) var stops = [Stop]()

        public private(set) var regionIdentifier: Int?

        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case groupingType = "type"
            case polylines
            case stopIDs = "stopIds"
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decode(String.self, forKey: .id)

            let nameContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .name)
            name = try nameContainer.decode(String.self, forKey: .name)
            groupingType = try nameContainer.decode(String.self, forKey: .groupingType)

            #if !os(watchOS)
            let polylineEntities = try container.decode([PolylineEntity].self, forKey: .polylines)
            polylines = polylineEntities.compactMap { $0.points }
            #endif

            stopIDs = try container.decode([String].self, forKey: .stopIDs)
        }

        public func loadReferences(_ references: References, regionIdentifier: Int?) {
            stops = references.stopsWithIDs(stopIDs)
            self.regionIdentifier = regionIdentifier
        }
    }
}
