import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    weak var delegate: TrackerStoreDelegate?
    
    var trackers: [TrackerModel] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        return objects.compactMap { try? trackerModel(from: $0) }
    }
    
    override init() {
        self.context = CoreDataManager.shared.context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdDate", ascending: true)
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
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func addTracker(_ tracker: TrackerModel, to categoryId: UUID) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        update(trackerCoreData, with: tracker, categoryId: categoryId)
        
        CoreDataManager.shared.saveContext()
    }
    
    func updateTracker(_ tracker: TrackerModel, categoryId: UUID) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        guard let trackerCoreData = results.first else {
            throw StoreError.notFound
        }
        
        update(trackerCoreData, with: tracker, categoryId: categoryId)
        CoreDataManager.shared.saveContext()
    }
    
    func deleteTracker(with id: UUID) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        guard let trackerCoreData = results.first else {
            throw StoreError.notFound
        }
        
        context.delete(trackerCoreData)
        CoreDataManager.shared.saveContext()
    }
    
    func togglePin(for trackerId: UUID) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        guard let trackerCoreData = results.first else {
            throw StoreError.notFound
        }
        
        trackerCoreData.pinned.toggle()
        CoreDataManager.shared.saveContext()
    }
    
    func fetchTrackers(for date: Date, searchText: String? = nil) -> [TrackerCategoryModel] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        let filteredTrackers = objects.compactMap { trackerCoreData -> TrackerModel? in
            guard let tracker = try? self.trackerModel(from: trackerCoreData) else { return nil }
            
            let schedule = tracker.schedule
            if !schedule.isEmpty {
                let calendarWeekdays = schedule.map { $0.calendarWeekday }
                if !calendarWeekdays.contains(weekday) {
                    return nil
                }
            }
            
            if let searchText = searchText, !searchText.isEmpty {
                if !tracker.title.localizedCaseInsensitiveContains(searchText) {
                    return nil
                }
            }
            
            return tracker
        }
        
        var categoriesDict: [UUID: (name: String, trackers: [TrackerModel])] = [:]
        
        for tracker in filteredTrackers {
            let category = objects.first { $0.id == tracker.id }?.category
            guard let categoryId = category?.id,
                  let categoryName = category?.name else { continue }
            
            if categoriesDict[categoryId] == nil {
                categoriesDict[categoryId] = (name: categoryName, trackers: [])
            }
            categoriesDict[categoryId]?.trackers.append(tracker)
        }
        
        return categoriesDict.map { TrackerCategoryModel(title: $0.value.name, trackers: $0.value.trackers) }
    }
    
    // MARK: - Helper Methods
    
    private func trackerModel(from trackerCoreData: TrackerCoreData) throws -> TrackerModel {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let color = trackerCoreData.color,
              let emoji = trackerCoreData.emoji,
              let scheduleData = trackerCoreData.schedule else {
            throw StoreError.invalidData
        }
        
        let schedule: [WeekDay]
        do {
            schedule = try JSONDecoder().decode([WeekDay].self, from: scheduleData)
        } catch {
            print("Failed to decode schedule: \(error)")
            schedule = []
        }
        
        return TrackerModel(
            id: id,
            title: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    private func update(_ trackerCoreData: TrackerCoreData, with tracker: TrackerModel, categoryId: UUID) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.title
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.createdDate = Date()
        trackerCoreData.pinned = false
        
        do {
            let scheduleData = try JSONEncoder().encode(tracker.schedule)
            trackerCoreData.schedule = scheduleData
        } catch {
            print("Failed to encode schedule: \(error)")
        }
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
        
        if let category = try? context.fetch(fetchRequest).first {
            trackerCoreData.category = category
        }
    }
    
    enum StoreError: Error {
        case notFound
        case invalidData
        case saveFailed
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
