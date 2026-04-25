import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var categories: [TrackerCategoryModel] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        
        return objects.compactMap { categoryCoreData -> TrackerCategoryModel? in
            guard let name = categoryCoreData.name,
                  let trackersCoreData = categoryCoreData.trackers as? Set<TrackerCoreData> else {
                return nil
            }
            
            let trackers = trackersCoreData.compactMap { trackerCoreData -> TrackerModel? in
                guard let id = trackerCoreData.id,
                      let name = trackerCoreData.name,
                      let color = trackerCoreData.color,
                      let emoji = trackerCoreData.emoji,
                      let scheduleData = trackerCoreData.schedule else {
                    return nil
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
            
            return TrackerCategoryModel(title: name, trackers: trackers)
        }
    }
    
    override init() {
        self.context = CoreDataManager.shared.context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
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
            print("Failed to fetch categories: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func addCategory(with name: String) throws -> UUID {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.id = UUID()
        categoryCoreData.name = name
        
        CoreDataManager.shared.saveContext()
        
        guard let id = categoryCoreData.id else {
            throw StoreError.saveFailed
        }
        
        return id
    }
    
    func updateCategory(_ id: UUID, with newName: String) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        guard let categoryCoreData = results.first else {
            throw StoreError.notFound
        }
        
        categoryCoreData.name = newName
        CoreDataManager.shared.saveContext()
    }
    
    func deleteCategory(with id: UUID) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        guard let categoryCoreData = results.first else {
            throw StoreError.notFound
        }
        
        context.delete(categoryCoreData)
        CoreDataManager.shared.saveContext()
    }
    
    func fetchCategoryId(for name: String) -> UUID? {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        
        guard let category = try? context.fetch(fetchRequest).first,
              let id = category.id else {
            return nil
        }
        
        return id
    }
    
    func createCategoryIfNeeded(with name: String) throws -> UUID {
        if let existingId = fetchCategoryId(for: name) {
            return existingId
        }
        
        return try addCategory(with: name)
    }
    
    enum StoreError: Error {
        case notFound
        case saveFailed
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
