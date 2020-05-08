//
//  StopArrivals.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 11/2/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import Foundation

public class StopArrivals: NSObject, Decodable, HasReferences {

    /// Upcoming and just-passed vehicle arrivals and departures.
    public let arrivalsAndDepartures: [ArrivalDeparture]

    /// A list of nearby stop IDs.
    let nearbyStopIDs: [StopID]

    /// A list of nearby `Stop`s.
    public private(set) var nearbyStops = [Stop]()

    /// A list of active service alert IDs.
    private let situationIDs: [String]

    /// Active service alerts tied to the `StopArrivals` model.
    private var _situations = [Situation]()

    /// Returns this model's list of service alerts, if any exist. If this model does not have any, then it returns a flattened list of its `ArrivalDepartures` objects' service alerts.
    public var situations: [Situation] {
        if _situations.count > 0 {
            return _situations
        }
        else {
            return arrivalsAndDepartures.flatMap { $0.situations }
        }
    }

    /// The stop ID for the stop this represents.
    let stopID: StopID

    /// The stop to which this object refers.
    public var stop: Stop!

    private enum CodingKeys: String, CodingKey {
        case arrivalsAndDepartures
        case nearbyStopIDs = "nearbyStopIds"
        case situationIDs = "situationIds"
        case stopID = "stopId"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        arrivalsAndDepartures = try container.decode([ArrivalDeparture].self, forKey: .arrivalsAndDepartures)
        nearbyStopIDs = try container.decode([StopID].self, forKey: .nearbyStopIDs)
        situationIDs = try container.decode([String].self, forKey: .situationIDs)
        stopID = try container.decode(StopID.self, forKey: .stopID)
    }

    public func loadReferences(_ references: References) {
        nearbyStops = references.stopsWithIDs(nearbyStopIDs)
        _situations = references.situationsWithIDs(situationIDs)
        stop = references.stopWithID(stopID)!
        arrivalsAndDepartures.loadReferences(references)
    }
}
