import Foundation

final class UserDefaultsSettings {
    static let shared = UserDefaultsSettings()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    private enum Keys: String {
        case onboardingWasShown
        case pinnedTrackers
        case currentFilterRawValue
    }

    var onboardingWasShown: Bool {
        get { userDefaults.bool(forKey: Keys.onboardingWasShown.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.onboardingWasShown.rawValue) }
    }
    

    var currentFilterRawValue: Int {
        get { userDefaults.integer(forKey: Keys.currentFilterRawValue.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.currentFilterRawValue.rawValue) }
    }

    private(set) var pinnedTrackers: Set<UUID> = []
    
    func loadPinnedTrackers() {
        if let savedData = userDefaults.data(forKey: Keys.pinnedTrackers.rawValue),
           let savedIDs = try? JSONDecoder().decode(Set<UUID>.self, from: savedData) {
            pinnedTrackers = savedIDs
        }
    }
    
    func savePinnedTrackers() {
        if let data = try? JSONEncoder().encode(pinnedTrackers) {
            userDefaults.set(data, forKey: Keys.pinnedTrackers.rawValue)
        }
    }

    func addPinnedTracker(id: UUID) {
        pinnedTrackers.insert(id)
        savePinnedTrackers()
    }

    func removePinnedTracker(id: UUID) {
        pinnedTrackers.remove(id)
        savePinnedTrackers()
    }

    func isPinned(trackerId: UUID) -> Bool {
        return pinnedTrackers.contains(trackerId)
    }

}


