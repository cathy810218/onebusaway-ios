//
//  StopArrivalView.swift
//  OBAKit
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit
import OBAKitCore

// MARK: - StopArrivalView

/// This view displays the route, headsign, and predicted arrival/departure time for an `ArrivalDeparture`.
///
/// This view is what displays the core information at the heart of the `StopViewController`, and everywhere
/// else that we show information from an `ArrivalDeparture`.
/// # Layout
/// This view will adapt to accessibility settings.
///
/// ## Standard Content Size
/// ```
/// +----------------outerStackView------------------+
/// | +-------infoStack------+                       |
/// | |routeHeadsignLabel    |                       |
/// | |                      |     minutesWrapper    |
/// | |fullExplanationlabel  |                       |
/// | |occupancyStatusView   |                       |
/// | +----------------------+                       |
/// +------------------------------------------------+
/// ```
///
/// ## Accessibility Content Size
/// ```
/// +-----------------outerStackView-----------------+
/// | +------------------infoStack-----------------+ |
/// | |routeHeadsignLabel                          | |
/// | |accessibilityTimeLabel                      | |
/// | |accessibilityScheduleDeviationLabel         | |
/// | |accessibilityRelativeTimeBadge              | |
/// | |occupancyStatus                             | |
/// | +--------------------------------------------+ |
/// +------------------------------------------------+
/// ```
///
/// ## Standard → Accessibility:
/// - Collapse data into one column
/// - Add background color to relative time text for clarity and to differentiate
class StopArrivalView: UIView {

    let kUseDebugColors = false

    // MARK: - Outer Stack

    private lazy var outerStackView: UIStackView = {
        let outerStack = UIStackView.horizontalStack(arrangedSubviews: [infoStackWrapper, minutesWrapper])
        outerStack.spacing = ThemeMetrics.compactPadding
        return outerStack
    }()

    // MARK: - Info Labels

    /// First line in the view; contains route and headsign information.
    ///
    /// For example, this might contain the text `10 - Downtown Seattle`.
    let routeHeadsignLabel: UILabel = {
        let label = buildLabel(textStyle: .headline)
        label.numberOfLines = 2
        label.allowsDefaultTighteningForTruncation = true
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)

        // Re: limiting number of lines to 2 -- there is a weird layout bug I
        // can't trace that is always setting a fixed height constraint to
        // StopArrivalCell, which inherits SwipeCollectionViewCell. If we can
        // get rid of the height constraint, set the label to have infinite lines.

        return label
    }()

    /// Second line in the view; contains the arrival/departure time and status relative to schedule.
    ///
    /// For example, this might contain the text `11:20 AM - arriving on time`.
    let fullExplanationLabel: UILabel = {
        let label = buildLabel(textStyle: .body)
        label.setContentHuggingPriority(.defaultHigh - 1, for: .vertical)

        return label
    }()

    /// Accessibility feature for one-column compact view. For example, `11:20 AM`
    let accessibilityTimeLabel = buildLabel(textStyle: .subheadline)

    /// Accessibility feature for one-column compact view. For example, `arriving on time`.
    let accessibilityScheduleDeviationLabel = buildLabel(textStyle: .subheadline)

    /// Accessibility feature for one-column compact view. For example, `15m`
    let accessibilityRelativeTimeBadge: DepartureTimeBadge = {
        let badge = DepartureTimeBadge()
        badge.adjustsFontForContentSizeCategory = true

        return badge
    }()

    /// Views to set visible when not in accessibility.
    var normalInfoStack: [UIView] {
        [fullExplanationLabel, minutesWrapper]
    }

    /// Views to set visible when user is in accessibility.
    var accessibilityInfoStack: [UIView] {
        [accessibilityTimeLabel,
         accessibilityScheduleDeviationLabel,
         accessibilityRelativeTimeBadge]
    }

    /// Views to set visible in accessibility when in minimal view.
    var accessibilityMinimalInfoStack: [UIView] {
        [accessibilityRelativeTimeBadge]
    }

    /// Views containing info elements. To simplify logic, we will include all info views into the stack view.
    private lazy var infoStack = UIStackView.verticalStack(arrangedSubviews: [
        routeHeadsignLabel,
        fullExplanationLabel,
        occupancyStatusView,
        accessibilityTimeLabel,
        accessibilityScheduleDeviationLabel,
        accessibilityRelativeTimeBadge
    ])

    private lazy var infoStackWrapper = infoStack.embedInWrapperView()

    // MARK: - Minutes to Departure Labels

    /// Appears on the trailing side of the view; contains the number of minutes until arrival/departure.
    ///
    /// For example, this might contain the text `10m`.
    let minutesLabel = HighlightChangeLabel.autolayoutNew()

    lazy var minutesWrapper: UIView = {
        let wrapper = minutesLabel.embedInWrapperView(setConstraints: false)
        NSLayoutConstraint.activate([
            minutesLabel.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            minutesLabel.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            minutesLabel.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            wrapper.heightAnchor.constraint(greaterThanOrEqualTo: minutesLabel.heightAnchor)
        ])
        return wrapper
    }()

    // MARK: - Occupancy Status

    let occupancyStatusView = OccupancyStatusView.autolayoutNew()

    // MARK: - Public Properties

    /// When `true`, decrease the `alpha` value of this cell if it happened in the past.
    public var deemphasizePastEvents = true

    public var formatters: Formatters!

    // MARK: - Data Setters

    public func prepareForReuse() {
        routeHeadsignLabel.text = nil
        fullExplanationLabel.text = nil
        accessibilityTimeLabel.text = nil
        accessibilityScheduleDeviationLabel.text = nil
        accessibilityRelativeTimeBadge.prepareForReuse()
        minutesLabel.text = ""
        occupancyStatusView.prepareForReuse()
    }

    /// Set this to display data in this view.
    public var arrivalDeparture: ArrivalDeparture! {
        didSet {
            configureView(for: traitCollection)
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(outerStackView)
        outerStackView.pinToSuperview(.edges)

        minutesLabel.font = .preferredFont(forTextStyle: .headline)
        configureView(for: traitCollection)

        if kUseDebugColors {
            routeHeadsignLabel.backgroundColor = .red
            fullExplanationLabel.backgroundColor = .orange
            minutesLabel.backgroundColor = .purple
            backgroundColor = .green
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UIAppearance

    @objc public dynamic var notificationCenter: NotificationCenter {
        get { _notificationCenter }
        set { _notificationCenter = newValue }
    }

    private var _notificationCenter: NotificationCenter! {
        didSet {
            _notificationCenter.addObserver(
                self,
                selector: #selector(contentSizeDidChange),
                name: UIContentSizeCategory.didChangeNotification,
                object: nil)
        }
    }

    // MARK: - UI Builders

    private class func buildLabel(textStyle: UIFont.TextStyle) -> UILabel {
        let label = UILabel.obaLabel(font: .preferredFont(forTextStyle: textStyle))
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        return label
    }

    private func buildMinutesLabelWrapper(label: UILabel) -> UIView {
        let wrapper = label.embedInWrapperView()
        wrapper.setCompressionResistance(horizontal: .required, vertical: .required)
        return wrapper
    }

    func configureView(for contentConfiguration: ArrivalDepartureContentConfiguration) {
        if contentConfiguration.deemphasizePastEvents {
            alpha = contentConfiguration.viewModel.temporalState == .past ? 0.5 : 1.0
        }

        routeHeadsignLabel.text = contentConfiguration.viewModel.name
        fullExplanationLabel.attributedText = contentConfiguration.fullAttributedExplanation

        minutesLabel.text = contentConfiguration.untilMinutesText
        minutesLabel.textColor = contentConfiguration.colorForScheduleStatus
        accessibilityTimeLabel.text = contentConfiguration.accessibilityTimeLabelText
        accessibilityScheduleDeviationLabel.text = contentConfiguration.accessibilityScheduleDeviationText
        accessibilityRelativeTimeBadge.configure(contentConfiguration.departureTimeBadgeConfiguration)

        if let occupancy = contentConfiguration.viewModel.occupancyStatus, occupancy != .unknown {
            occupancyStatusView.configure(occupancyStatus: occupancy, realtimeData: true)
            infoStack.setCustomSpacing(ThemeMetrics.compactPadding, after: fullExplanationLabel)
        } else if let historicalOccupancy = contentConfiguration.viewModel.historicalOccupancyStatus, historicalOccupancy != .unknown {
            occupancyStatusView.configure(occupancyStatus: historicalOccupancy, realtimeData: false)
            infoStack.setCustomSpacing(ThemeMetrics.compactPadding, after: fullExplanationLabel)
        }
        else {
            infoStack.setCustomSpacing(0, after: fullExplanationLabel)
        }

        accessibilityLabel = contentConfiguration.accessibilityLabel
        accessibilityValue = contentConfiguration.accessibilityValue
        accessibilityTraits = [.button, .updatesFrequently]
        isAccessibilityElement = true

        layoutAccessibilityElements()
    }

    func configureView(for traitCollection: UITraitCollection) {
        guard let arrivalDeparture = arrivalDeparture else { return }

        if deemphasizePastEvents {
            // 'Gray out' the view if it occurred in the past.
            alpha = arrivalDeparture.temporalState == .past ? 0.50 : 1.0
        }

        routeHeadsignLabel.text = arrivalDeparture.routeAndHeadsign
        fullExplanationLabel.attributedText = formatters.fullAttributedExplanation(from: arrivalDeparture)

        minutesLabel.text = formatters.shortFormattedTime(until: arrivalDeparture)
        minutesLabel.textColor = ColorFormatters.uiColorForScheduleStatus(arrivalDeparture.scheduleStatus)

        accessibilityTimeLabel.text = formatters.timeFormatter.string(from: arrivalDeparture.arrivalDepartureDate)

        if arrivalDeparture.scheduleStatus == .unknown {
            accessibilityScheduleDeviationLabel.text = Strings.scheduledNotRealTime
        }
        else {
            accessibilityScheduleDeviationLabel.text = formatters.formattedScheduleDeviation(for: arrivalDeparture)
        }

        accessibilityScheduleDeviationLabel.textColor = ColorFormatters.uiColorForScheduleStatus(arrivalDeparture.scheduleStatus)
        accessibilityRelativeTimeBadge.configure(with: arrivalDeparture, formatters: formatters)

        accessibilityLabel = formatters.accessibilityLabel(for: arrivalDeparture)
        accessibilityValue = formatters.accessibilityValue(for: arrivalDeparture)
        accessibilityTraits = [.button, .updatesFrequently]
        isAccessibilityElement = true

        layoutAccessibilityElements()
    }

    private func layoutAccessibilityElements() {
        normalInfoStack.forEach { $0.isHidden = isAccessibility }
        accessibilityInfoStack.forEach { $0.isHidden = !isAccessibility }

        infoStack.spacing = isAccessibility ? ThemeMetrics.padding : 0
    }

    @objc func contentSizeDidChange(_ notification: Notification) {
        layoutAccessibilityElements()
    }
}
