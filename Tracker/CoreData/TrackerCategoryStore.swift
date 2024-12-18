import CoreData
import UIKit

final class TrackerCategoryStore {
    
    static let shared = TrackerCategoryStore()
    private let context: NSManagedObjectContext

    private init() {
        self.context = AppDelegate.shared.persistentContainer.viewContext
    }

    func createCategory(name: String, completion: @escaping (TrackerCategory?) -> Void) {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.name = name
        AppDelegate.shared.saveContext()
        let newCategory = TrackerCategory(name: name, list: [])
        completion(newCategory)
    }

    func fetchCategories(completion: @escaping ([TrackerCategory]) -> Void) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        
        do {
            let categoryEntities = try context.fetch(request)
            let categories = categoryEntities.compactMap { entity -> TrackerCategory? in
                guard let name = entity.name,
                      let trackersSet = entity.trackers as? Set<TrackerCoreData> else {
                    return nil
                }
                
                let model = trackersSet.compactMap { trackerEntity in
                    Tracker(
                        id: trackerEntity.id ?? UUID(),
                        name: trackerEntity.name ?? "",
                        color: trackerEntity.color as? UIColor ?? UIColor.black,
                        emoji: trackerEntity.emoji ?? "",
                        timing: trackerEntity.timing as? [WeekDay] ?? []
                    )
                }
                
                return TrackerCategory(name: name, list: model)
            }

            completion(categories)
        } catch {
            print("Ошибка получения категории: \(error)")
            completion([])
        }
    }
}

