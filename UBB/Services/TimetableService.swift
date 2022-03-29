import Foundation
import SwiftSoup
import Combine
import CoreData
import SwiftUI

class TimetableService: ObservableObject {
    static let shared = TimetableService()
    
    private init() {}
    
    @Published var errorOccurred = PassthroughSubject<Error, Never>()

    @UserDefault("year") var year: Year? {
        willSet {
            // clearing the year also clears the group and semigroup
            group = nil
            semigroup = nil
            objectWillChange.send()
        }
        didSet {
            if year == nil {
                self.clearTimetable()
            } else {
                Task {
                    await self.updateTimetable()
                }
            }
        }
    }

    @UserDefault("group") var group: Group? {
        willSet {
            // clearing the group also clears the semigroup
            semigroup = nil
            self.objectWillChange.send()
        }
        didSet {
            if group == nil {
                self.clearTimetable()
            } else {
                Task {
                    await self.updateTimetable()
                }
            }
        }
    }

    @UserDefault("semigroup") var semigroup: Semigroup? {
        willSet {
            self.objectWillChange.send()
        }
        didSet {
            if semigroup == nil {
                self.clearTimetable()
            } else {
                Task {
                    await self.updateTimetable()
                }
            }
        }
    }


    @Published var weekViewType: WeekViewType = {
        .both
//        var calendar = Calendar(identifier: .iso8601)
//        calendar.firstWeekday = 2
//        if calendar.component(.weekOfYear, from: Date()) % 2 == 0 {
//            return .two
//        } else {
//            return .one
//        }
    }() {
        willSet {
            self.objectWillChange.send()
        }
    }

    @UserDefaultColor("courseColor") var courseColor: Color? {
        willSet {
            self.objectWillChange.send()
        }
    }

    @UserDefaultColor("seminarColor") var seminarColor: Color? {
        willSet {
            self.objectWillChange.send()
        }
    }

    @UserDefaultColor("labColor") var labColor: Color? {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    @AppStorage("showHidden") var showHidden: Bool = true

    var areSettingsSet: Bool {
        year != nil && group != nil
    }

    func fetchTimetable(year: Year, group: Group, semigroup: Semigroup?) async throws {
        clearTimetable()
        let url = URL(string: "https://www.cs.ubbcluj.ro/files/orar/2021-2/tabelar/\(year.id).html")
        guard let url = url else {
            let error = AppError(
                message: "The timetable url was invalid",
                type: .urlInvalid(.timetable),
                additionalData: [
                    "url": url as Any
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        let config = URLSessionConfiguration.default
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let result = try? await URLSession(configuration: config).data(from: url)
        guard let result = result else {
            let error = AppError(
                message: "Failed to fetch timetable",
                type: .requestFailed(.timetable),
                additionalData: [
                    "url": url
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        let (data, _) = result
        guard let html = String(data: data, encoding: .ascii) else {
            let error = AppError(
                message: "Could not convert data provided by the UBB website",
                type: .invalidData(.timetable),
                additionalData: [
                    "url": url
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        var parsedUntilNow = [String]()
        try SwiftSoup
            .parse(html)
            .select("table")[group.index]
            .once {
                parsedUntilNow.append("table")
            }
            .select("tr")[1...]
            .once {
                parsedUntilNow.append("tr")
            }
            .map { tr in
                try tr.select("td")
            }
            .once {
                parsedUntilNow.append("td")
            }
            .map { tds in
                try tds.map { td in
                    try td.text()
                }
            }
            .once {
                parsedUntilNow.append("td+text")
            }
            .forEach { data in
                if
                    data[4].split(separator: "/").count == 2,
                    let last = data[4].last,
                    let semigroup = semigroup,
                    String(last) != semigroup.id
                {
                    return
                }
                let day: Day
                switch data[0] {
                case "Luni":
                    day = .monday
                case "Marti":
                    day = .tuesday
                case "Miercuri":
                    day = .wednesday
                case "Joi":
                    day = .thursday
                case "Vineri":
                    day = .friday
                default:
                    return
                }
                let timeArray = data[1].split(separator: "-")
                let startArray = timeArray[0].split(separator: ".")
                let endArray = timeArray[1].split(separator: ".")
                let startHour = Int(String(startArray[0]))!
                let startMinute = Int(String(startArray[1]))!
                let endHour = Int(String(endArray[0]))!
                let endMinute = Int(String(endArray[1]))!
                let course = Course(
                    context: PersistenceController.shared.container.viewContext
                )
                course.day = day.rawValue
                course.startHour = Int16(startHour)
                course.startMinute = Int16(startMinute)
                course.endHour = Int16(endHour)
                course.endMinute = Int16(endMinute)
                course.frequency = data[2]
                course.room = data[3]
                course.type = data[5]
                course.name = data[6]
                course.teacher = data[7]
        }
        try PersistenceController.shared
            .container
            .viewContext
            .save()
    }

    func getYears() async throws -> [Year] {
        let url = URL(string: "https://www.cs.ubbcluj.ro/files/orar/2021-2/tabelar/index.html")
        guard let url = url else {
            let error = AppError(
                message: "The years url was invalid",
                type: .urlInvalid(.years),
                additionalData: [
                    "url": url as Any
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        let config = URLSessionConfiguration.default
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let result = try? await URLSession(configuration: config).data(from: url)
        guard let result = result else {
            let error = AppError(
                message: "Failed to fetch years",
                type: .requestFailed(.years),
                additionalData: [
                    "url": url
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        let (data, _) = result
        guard let html = String(data: data, encoding: .ascii) else {
            let error = AppError(
                message: "Could not convert data provided by the UBB website",
                type: .invalidData(.years),
                additionalData: [
                    "url": url
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        var parsedUntilNow = [String]()
        let years = try? SwiftSoup
            .parse(html)
            .select("tbody")
            .once {
                parsedUntilNow.append("tbody")
            }
            .map { tbody in
                try tbody.select("tr")
            }
            .once {
                parsedUntilNow.append("tr")
            }
            .map { trs -> [(name: String, ids: [String])] in
                try trs[1...].map { tr -> (name: String, ids: [String]) in
                    let tds = try tr.select("td")
                    let name = try tds[0].text()
                    let ids = try tds[1...].compactMap { td -> String? in
                        let id = try td.select("a").attr("href").split(separator: ".").first
                        if let id = id {
                            return String(id)
                        } else {
                            return nil
                        }
                    }
                    return (name: name, ids: ids)
                }
            }
            .once {
                parsedUntilNow.append("td")
            }
            .flatMap { $0 }
            .map { tuple in
                tuple.ids.enumerated().map { index, id in
                    Year(id: id, value: tuple.name, index: index)
                }
            }
        guard let years = years else {
            let error = AppError(
                message: "Could not parse years provided by the UBB website",
                type: .parseFailed(.years),
                additionalData: [
                    "url": url,
                    "parsedUntilNow": parsedUntilNow
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        return years.flatMap {$0}
    }

    func getGroups(for year: Year) async throws -> [Group] {
        let url = URL(string: "https://www.cs.ubbcluj.ro/files/orar/2021-2/tabelar/\(year.id).html")
        guard let url = url else {
            let error = AppError(
                message: "The groups url was invalid",
                type: .urlInvalid(.groups),
                additionalData: [
                    "url": url as Any
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        let config = URLSessionConfiguration.default
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let result = try? await URLSession(configuration: config).data(from: url)
        guard let result = result else {
            let error = AppError(
                message: "Failed to fetch groups",
                type: .requestFailed(.groups),
                additionalData: [
                    "url": url
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        let (data, _) = result
        guard let html = String(data: data, encoding: .ascii) else {
            let error = AppError(
                message: "Could not convert data provided by the UBB website",
                type: .invalidData(.groups),
                additionalData: [
                    "url": url
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        var parsedUntilNow = [String]()
        let groups = try? SwiftSoup
            .parse(html)
            .select("h1")
            .once {
                parsedUntilNow.append("h1")
            }
            .compactMap { h1 -> String? in
                let words = try h1.text().split(separator: " ")
                guard words.count == 2, words.first == "Grupa" else {
                    return nil
                }
                return String(words[1])
            }
            .once {
                parsedUntilNow.append("split")
            }
            .enumerated()
            .map { index, group in
                Group(id: group, value: group, index: index)
            }
        guard let groups = groups else {
            let error = AppError(
                message: "Could not parse groups provided by the UBB website",
                type: .parseFailed(.years),
                additionalData: [
                    "url": url,
                    "parsedUntilNow": parsedUntilNow
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        return groups
    }

    func getSemigroups(year: Year, group: Group) async throws -> [Semigroup] {
        let url = URL(string: "https://www.cs.ubbcluj.ro/files/orar/2021-2/tabelar/\(year.id).html")
        guard let url = url else {
            let error = AppError(
                message: "The subgroups url was invalid",
                type: .urlInvalid(.subgroups),
                additionalData: [
                    "url": url as Any
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        let config = URLSessionConfiguration.default
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let result = try? await URLSession(configuration: config).data(from: url)
        guard let result = result else {
            let error = AppError(
                message: "Failed to fetch subgroups",
                type: .requestFailed(.subgroups),
                additionalData: [
                    "url": url
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        let (data, _) = result
        guard let text = String(data: data, encoding: .ascii) else {
            let error = AppError(
                message: "Could not convert data provided by the UBB website",
                type: .invalidData(.groups),
                additionalData: [
                    "url": url
                ]
            )
            errorOccurred.send(error)
            throw error
        }
        let regex = try! NSRegularExpression(pattern: "\(group.id)\\/\\d")
        let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        let matches = results
            .map {
                String(text[Range($0.range, in: text)!])
            }
            .map {
                Int($0.components(separatedBy: "/")[1])!
            }
            .unique
            .sorted()
        return matches.map {
            Semigroup(id: "\($0)", value: "\($0)", index: $0)
        }
    }

    func clearTimetable() {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Course.fetchRequest()
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try PersistenceController.shared.container.viewContext.executeAndMergeChanges(batchDeleteRequest)
        } catch {
            errorOccurred.send(error)
        }
    }

    func updateTimetable() async {
        if areSettingsSet {
            try? await fetchTimetable(
                year: year!,
                group: group!,
                semigroup: semigroup
            )
        }
    }

    func validateCourse(_ course: Course) -> Bool {
        if weekViewType != .both {
            if
                let week = course.frequency.last,
                let number = Int(String(week)) {
                if
                    (number == 1 && weekViewType != .one) ||
                    (number == 2 && weekViewType != .two)
                {
                    return false
                }
            }
        }
        return true
    }
    
    var hasSemigroups: Bool {
        get async {
            guard let year = year, let group = group else { return false }
            let semigroups = try? await getSemigroups(year: year, group: group)
            return semigroups?.count != 0
        }
    }
    
    func getExistingEditedCourse(course: Course) -> EditedCourse? {
        let fetchRequest = EditedCourse.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id like %@", course.id)
        fetchRequest.fetchLimit = 1
        let objects = try? PersistenceController
            .shared
            .container
            .viewContext
            .fetch(fetchRequest)
        if
            let objects = objects,
            objects.count == 1,
            let existingCourse = objects.first
        {
            return existingCourse
        }
        return nil
    }
    
    func getOrCreateEditedCourse(course: Course) -> EditedCourse {
        if let existingCourse = getExistingEditedCourse(course: course) {
            return existingCourse
        }
        let newCourse = EditedCourse(
            context: PersistenceController
                .shared
                .container
                .viewContext
        )
        newCourse.id = course.id
        newCourse.isHidden = false
        return newCourse
    }
    
    func getAllCourses() throws -> [Course] {
        let fetchRequest = Course.fetchRequest()
        let objects = try? PersistenceController
            .shared
            .container
            .viewContext
            .fetch(fetchRequest)
        guard let objects = objects else {
            let error = AppError(
                message: "Cannot get course names",
                type: .fetchFailed(.courses)
            )
            errorOccurred.send(error)
            throw error
        }
        return objects
    }
}
