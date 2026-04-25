import Foundation
import UIKit

protocol SearchManagerDelegate: AnyObject {
    func didUpdateSearchResults(_ filteredCategories: [TrackerCategoryModel])
}

final class SearchManager {
    
    weak var delegate: SearchManagerDelegate?
    
    private(set) var filteredCategories: [TrackerCategoryModel] = []
    private var allCategories: [TrackerCategoryModel] = []
    private var isSearching = false
    
    func updateCategories(_ categories: [TrackerCategoryModel]) {
        self.allCategories = categories
        self.filteredCategories = categories
        self.isSearching = false
    }
    
    func filterCategories(searchText: String) {
        isSearching = !searchText.isEmpty
        
        if searchText.isEmpty {
            filteredCategories = allCategories
        } else {
            filteredCategories = allCategories.compactMap { category -> TrackerCategoryModel? in
                let matchingTrackers = category.trackers.filter { tracker in
                    tracker.title.lowercased().contains(searchText.lowercased())
                }
                guard !matchingTrackers.isEmpty else { return nil }
                return TrackerCategoryModel(
                    title: category.title,
                    trackers: matchingTrackers
                )
            }
        }
        
        delegate?.didUpdateSearchResults(filteredCategories)
    }
    
    func getCurrentCategories() -> [TrackerCategoryModel] {
        return isSearching ? filteredCategories : allCategories
    }
    
    func isCurrentlySearching() -> Bool {
        return isSearching
    }
    
    func resetSearch() {
        isSearching = false
        filteredCategories = allCategories
        delegate?.didUpdateSearchResults(allCategories)
    }
}
