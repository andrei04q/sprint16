import Foundation

struct TrackerRecordModel: Hashable {
    let trackerId: UUID
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackerId)
        hasher.combine(date)
    }
    
    static func == (lhs: TrackerRecordModel, rhs: TrackerRecordModel) -> Bool {
        lhs.trackerId == rhs.trackerId && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}
