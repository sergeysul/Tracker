import CoreData
import UIKit

final class TrackerStore {
    
    static let shared = TrackerStore()
    private let context: NSManagedObjectContext

    private init() {
        self.context = AppDelegate.shared.persistentContainer.viewContext
    }

    func createTracker(id: UUID, name: String, color: UIColor, emoji: String, timing: [WeekDay], categoryName: String, completion: @escaping (Tracker?) -> Void) {
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = id
        trackerCoreData.name = name
        trackerCoreData.color = color
        trackerCoreData.emoji = emoji
        trackerCoreData.timing = timing as NSObject

        let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "name == %@", categoryName)
        let categoryCoreData: TrackerCategoryCoreData
        
        if let existingCategory = try? context.fetch(categoryRequest).first {
            categoryCoreData = existingCategory
        } else {
            categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.name = categoryName
        }
    
        trackerCoreData.category = categoryCoreData
        categoryCoreData.addToTrackers(trackerCoreData)

        AppDelegate.shared.saveContext()

        let newTracker = Tracker(id: id, name: name, color: color, emoji: emoji, timing: timing)
        completion(newTracker)
    }

    func fetchTrackers(completion: @escaping ([Tracker]) -> Void) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let trackerEntities = try context.fetch(request)
            let trackers = trackerEntities.compactMap { entity -> Tracker? in
                guard let id = entity.id,
                      let name = entity.name,
                      let color = entity.color as? UIColor,
                      let emoji = entity.emoji,
                      let timing = entity.timing as? [WeekDay] else {
                    return nil
                }
                return Tracker(id: id, name: name, color: color, emoji: emoji, timing: timing)
            }
            completion(trackers)
        } catch {
            print("Ошибка загрузки трекеров: \(error)")
            completion([])
        }
    }
}
