import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var records: [TrackerRecordModel] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        
        return objects.compactMap { recordCoreData -> TrackerRecordModel? in
            guard let trackerId = recordCoreData.tracker?.id,
                  let date = recordCoreData.date else {
                return nil
            }
            
            return TrackerRecordModel(trackerId: trackerId, date: date)
        }
    }
    
    override init() {
        self.context = CoreDataManager.shared.context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch records: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func addRecord(trackerId: UUID, date: Date) throws {
        if try isRecordExists(trackerId: trackerId, date: date) {
            throw StoreError.duplicateRecord
        }
        
        let trackerFetchRequest = TrackerCoreData.fetchRequest()
        trackerFetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        guard let tracker = try context.fetch(trackerFetchRequest).first else {
            throw StoreError.trackerNotFound
        }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = UUID()
        recordCoreData.date = date
        recordCoreData.tracker = tracker
        
        CoreDataManager.shared.saveContext()
    }
    
    func deleteRecord(trackerId: UUID, date: Date) throws {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            date.startOfDay as CVarArg,
            date.nextDay.startOfDay as CVarArg
        )
        
        let results = try context.fetch(fetchRequest)
        guard let recordCoreData = results.first else {
            throw StoreError.notFound
        }
        
        context.delete(recordCoreData)
        CoreDataManager.shared.saveContext()
    }
    
    func fetchRecords(for trackerId: UUID) -> [TrackerRecordModel] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        
        return objects.compactMap { recordCoreData -> TrackerRecordModel? in
            guard let recordTrackerId = recordCoreData.tracker?.id,
                  recordTrackerId == trackerId,
                  let date = recordCoreData.date else {
                return nil
            }
            
            return TrackerRecordModel(trackerId: recordTrackerId, date: date)
        }
    }
    
    func isCompletedToday(trackerId: UUID, date: Date) -> Bool {
        guard let objects = fetchedResultsController?.fetchedObjects else { return false }
        
        return objects.contains { recordCoreData in
            guard let recordTrackerId = recordCoreData.tracker?.id,
                  recordTrackerId == trackerId,
                  let recordDate = recordCoreData.date else {
                return false
            }
            
            return Calendar.current.isDate(recordDate, inSameDayAs: date)
        }
    }
    
    func completedCount(for trackerId: UUID) -> Int {
        guard let objects = fetchedResultsController?.fetchedObjects else { return 0 }
        
        return objects.filter { recordCoreData in
            recordCoreData.tracker?.id == trackerId
        }.count
    }
    
    // MARK: - Helper Methods
    
    private func isRecordExists(trackerId: UUID, date: Date) throws -> Bool {
        guard let objects = fetchedResultsController?.fetchedObjects else { return false }
        
        return objects.contains { recordCoreData in
            guard let recordTrackerId = recordCoreData.tracker?.id,
                  recordTrackerId == trackerId,
                  let recordDate = recordCoreData.date else {
                return false
            }
            
            return Calendar.current.isDate(recordDate, inSameDayAs: date)
        }
    }
    
    enum StoreError: Error {
        case notFound
        case duplicateRecord
        case saveFailed
        case trackerNotFound
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}

// MARK: - Date Helpers
private extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var nextDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self) ?? self
    }
}
