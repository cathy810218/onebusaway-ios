//
//  ColorFormatters.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 8/16/21.
//

import UIKit
import SwiftUI

/// Maps transit statuses to SwiftUI `Color`s and UIKit `UIColor`s.
public class ColorFormatters {
    #if !os(watchOS)
    /// Retrieves the appropriate background `UIColor` for the passed-in `ScheduleStatus` value.
    /// - Parameter status: The schedule status to map to a color.
    /// - Returns: The background color corresponding to the passed-in status.
    public static func backgroundUIColorForScheduleStatus(_ status: ScheduleStatus) -> UIColor {
        switch status {
        case .onTime: return UIColor.systemGreen
        case .early: return UIColor.systemRed
        case .delayed: return UIColor.systemBlue
        default: return UIColor.systemGray
        }
    }

    /// Retrieves the appropriate `UIColor` for the passed-in `ScheduleStatus` value.
    /// - Parameter status: The schedule status to map to a color.
    /// - Returns: The color corresponding to the passed-in status.
    public static func uiColorForScheduleStatus(_ status: ScheduleStatus) -> UIColor {
        switch status {
        case .onTime: return .systemGreen
        case .early: return .systemRed
        case .delayed: return .systemBlue
        default: return .label
        }
    }
    #endif

    /// Retrieves the appropriate background SwiftUI `Color` for the passed-in `ScheduleStatus` value.
    /// - Parameter status: The schedule status to map to a color.
    /// - Returns: The background color corresponding to the passed-in status.
    public static func backgroundColorForScheduleStatus(_ status: ScheduleStatus) -> Color {
        switch status {
        case .onTime: return .green
        case .early: return .red
        case .delayed: return .blue
        default: return .gray
        }
    }

    /// Retrieves the appropriate SwiftUI `Color` for the passed-in `ScheduleStatus` value.
    /// - Parameter status: The schedule status to map to a color.
    /// - Returns: The color corresponding to the passed-in status.
    public static func colorForScheduleStatus(_ status: ScheduleStatus) -> Color {
        switch status {
        case .onTime: return .green
        case .early: return .red
        case .delayed: return .blue
        default: return .primary
        }
    }
}
