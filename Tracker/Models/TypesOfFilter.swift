import Foundation

enum FilterType: Int, CaseIterable {
    case all = 0
    case today
    case completed
    case incomplete

    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("all_trackers", comment: "")
        case .today:
            return NSLocalizedString("trackers_for_today", comment: "")
        case .completed:
            return NSLocalizedString("completed", comment: "")
        case .incomplete:
            return NSLocalizedString("incompleted", comment: "")
        }
    }
}
