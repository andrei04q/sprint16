import Foundation

enum WeekDay: String, CaseIterable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var title: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    var calendarWeekday: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    func toDate(for referenceDate: Date = Date()) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: referenceDate)
        
        let dayNumber = calendarWeekday
        
        let dayComponents = DateComponents(calendar: calendar,
                                         year: components.year,
                                         month: components.month,
                                         weekday: dayNumber)
        return calendar.date(from: dayComponents) ?? referenceDate
    }
}

struct TrackerModel {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: [WeekDay]
    
    var isHabit: Bool { !schedule.isEmpty }
}
