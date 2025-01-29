import CoreData
import UIKit

final class TrackerStore {
    
    static let shared = TrackerStore()
    private let context: NSManagedObjectContext

    private init() {
        self.context = AppDelegate.shared.persistentContainer.viewContext
    }

    func createTracker(id: UUID, 
                       name: String,
                       color: UIColor,
                       emoji: String,
                       timing: [WeekDay],
                       categoryName: String,
                       completion: @escaping (Tracker?) -> Void) {
        
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
    
    func deleteTracker(_ tracker: Tracker, completion: @escaping (Bool) -> Void) {
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id.uuidString)

        do {
            let results = try context.fetch(fetchRequest)
            if let trackerToDelete = results.first {
                context.delete(trackerToDelete)
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Не удалось удалить трекер: \(error)")
            completion(false)
        }
    }

    func updateTracker(_ tracker: Tracker, 
                       name: String,
                       color: UIColor,
                       emoji: String,
                       timing: [WeekDay],
                       categoryName: String,
                       completion: @escaping (Bool) -> Void) {
        
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id.uuidString)

        do {
            if let trackerCoreData = try context.fetch(request).first {
                trackerCoreData.name = name
                trackerCoreData.color = color
                trackerCoreData.emoji = emoji
                trackerCoreData.timing = timing as NSObject

                if trackerCoreData.category?.name != categoryName {
                    let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                    categoryRequest.predicate = NSPredicate(format: "name == %@", categoryName)
                    let categoryCoreData: TrackerCategoryCoreData
                    if let existingCategory = try context.fetch(categoryRequest).first {
                        categoryCoreData = existingCategory
                    } else {
                        categoryCoreData = TrackerCategoryCoreData(context: context)
                        categoryCoreData.name = categoryName
                    }
                    trackerCoreData.category = categoryCoreData
                }

                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Не удалось обновить трекер: \(error)")
            completion(false)
        }
    }
    
    
    func fetchCategory(for trackerId: UUID) -> TrackerCategory? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "ANY trackers.id == %@", trackerId.uuidString)

        do {
            if let category = try context.fetch(request).first {
                return TrackerCategory(
                    name: category.name ?? "",
                    list: []
                )
            }
        } catch {
            print("Ошибка получения категории: \(error)")
        }
        return nil
    }
}
