import Foundation
import SwiftSoup
import Combine
import CoreData

class TimetableService: ObservableObject {
    @UserDefault("year") var year: Year? = nil {
        willSet {
            self.group = nil
            self.semigroup = nil
            self.objectWillChange.send()
            self.clearTimetable()
        }
    }

    @UserDefault("group") var group: Group? = nil {
        willSet {
            if self.semigroup != Semigroup.default {
                self.semigroup = nil
            }
            self.clearTimetable()
            self.objectWillChange.send()
        }
        didSet {
            if self.semigroup == Semigroup.default {
                self.updateTimetable()
            }
        }
    }

    @UserDefault("semigroup") var semigroup: Semigroup? = nil {
        willSet {
            self.objectWillChange.send()
        }
        didSet {
            self.updateTimetable()
        }
    }

    @Published var weekViewType: WeekViewType = .both {
        willSet {
            self.objectWillChange.send()
        }
    }

    @Published var errorOccurred = PassthroughSubject<Error, Never>()

    func fetchTimetable(year: Year, group: Group, semigroup: Semigroup) {
        let url = URL(string: "https://www.cs.ubbcluj.ro/files/orar/2020-2/tabelar/\(year.id).html")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                guard let html = String(data: data, encoding: .ascii) else { return }
                do {
                    try SwiftSoup
                        .parse(html)
                        .select("table")[group.index]
                        .select("tr")[1...]
                        .map { tr in
                            try tr.select("td")
                        }
                        .map { tds in
                            try tds.map { td in
                                try td.text()
                            }
                        }
                        .forEach { data in
                            if
                                data[4].split(separator: "/").count == 2,
                                let last = data[4].last,
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
                            let hourArray = data[1].split(separator: "-")
                            let startHour = Int(String(hourArray[0]))!
                            let endHour = Int(String(hourArray[1]))!
                            let course = Course(context: PersistenceController.shared.container.viewContext)
                            course.day = day.rawValue
                            course.startHour = Int16(startHour)
                            course.endHour = Int16(endHour)
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
                } catch {
                    self.errorOccurred.send(error)
                }
            }
        }.resume()
    }
    
    func getYears(completionHandler: @escaping ([[Year]]?) -> ()) {
        let url = URL(string: "https://www.cs.ubbcluj.ro/files/orar/2020-1/tabelar/index.html")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                guard let html = String(data: data, encoding: .ascii) else { return }
                completionHandler(try? SwiftSoup
                    .parse(html)
                    .select("tbody")
                    .map { tbody in
                        try tbody.select("tr")
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
                    .flatMap { $0 }
                    .map { tuple in
                        tuple.ids.enumerated().map { index, id in
                            Year(id: id, value: tuple.name, index: index)
                        }
                    }
                )
            }
        }.resume()
    }
    
    func getGroups(for year: Year, completionHandler: @escaping ([Group]?) -> ()) {
        let url = URL(string: "https://www.cs.ubbcluj.ro/files/orar/2020-1/tabelar/\(year.id).html")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                guard let html = String(data: data, encoding: .ascii) else { return }
                completionHandler(try? SwiftSoup
                    .parse(html)
                    .select("h1")
                    .compactMap { h1 -> String? in
                        let words = try h1.text().split(separator: " ")
                        guard words.count == 2, words.first == "Grupa" else { return nil }
                        return String(words[1])
                    }
                    .enumerated()
                    .map { index, group in
                        Group(id: group, value: group, index: index)
                    }
                )
            }
        }.resume()
    }
    
    func getSemigroups(year: Year, group: Group, completionHandler: @escaping ([Semigroup]?) -> ()) {
        let url = URL(string: "https://www.cs.ubbcluj.ro/files/orar/2020-1/tabelar/\(year.id).html")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                guard let text = String(data: data, encoding: .ascii) else { return }
                let regex = try! NSRegularExpression(pattern: "\(group.id)\\/\\d")
                let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
                let matches = Array(
                    Set(
                        results
                            .map {
                                String(text[Range($0.range, in: text)!])
                            }
                            .map {
                                Int($0.components(separatedBy: "/")[1])!
                            }
                    )
                )
                .sorted()
                completionHandler(
                    matches.map {
                        Semigroup(id: "\($0)", value: "\($0)", index: $0)
                    }
                )
            }
        }.resume()
    }
    
    func clearTimetable() {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Course.fetchRequest()
            let result = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            for managedObject in result {
                if let managedObjectData: NSManagedObject = managedObject as? NSManagedObject {
                    PersistenceController.shared
                        .container
                        .viewContext
                        .delete(managedObjectData)
                }
            }
        } catch {
            self.errorOccurred.send(error)
        }
    }
    
    func updateTimetable() {
        self.clearTimetable()
        if
            let year = self.year,
            let group = self.group,
            let semigroup = self.semigroup
        {
            self.fetchTimetable(
                year: year,
                group: group,
                semigroup: semigroup
            )
        }
    }
    
    func validateCourse(_ course: Course) -> Bool {
        if self.weekViewType != .both {
            if
                let week = course.frequency.last,
                let number = Int(String(week))
            {
                if
                    (number == 1 && self.weekViewType != .one) ||
                    (number == 2 && self.weekViewType != .two)
                {
                    return false
                }
            }
        }
        return true
    }
}
