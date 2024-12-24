import CoreData

final class TrackerRecordStore {
    
    static let shared = TrackerRecordStore()
    private let context: NSManagedObjectContext

    private init() {
        self.context = AppDelegate.shared.persistentContainer.viewContext
    }

    func add(trackerId: UUID, date: Date, completion: @escaping (Bool) -> Void) {
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.trackerId = trackerId
        recordCoreData.date = date

        do {
            try context.save()
            completion(true)
        } catch {
            print("Ошибка добавления записи: \(error)")
            completion(false)
        }
    }

    func delete(trackerId: UUID, date: Date, completion: @escaping (Bool) -> Void) {
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND date == %@", trackerId as CVarArg, date as CVarArg)

        do {
            let records = try context.fetch(request)
            for record in records {
                context.delete(record)
            }
            try context.save()
            completion(true)
        } catch {
            print("Ошибка удаления записи: \(error)")
            completion(false)
        }
    }

    func fetchRecords(completion: @escaping ([TrackerRecord]) -> Void) {
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let recordEntities = try context.fetch(request)
            let records = recordEntities.compactMap { entity -> TrackerRecord? in
                guard let trackerId = entity.trackerId, let date = entity.date else { return nil }
                return TrackerRecord(trackerId: trackerId, date: date)
            }
            completion(records)
        } catch {
            print("Ошибка получения записи: \(error)")
            completion([])
        }
    }
}
