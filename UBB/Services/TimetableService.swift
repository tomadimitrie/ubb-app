//
//  TimetableService.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 30/09/2020.
//

import Foundation
import SwiftSoup

class TimetableService {
    static let shared = TimetableService()
    
    private init() {}
    
    func getTimetable(year: Year, group: Group, completionHandler: @escaping (Timetable?) -> ()) {
        let url = URL(string: "https://www.cs.ubbcluj.ro/files/orar/2020-1/tabelar/\(year.id).html")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                guard let html = String(data: data, encoding: .ascii) else { return }
                let index = Int(String(group.id.last!))! - 1
                completionHandler(try? SwiftSoup
                    .parse(html)
                    .select("table")[index]
                    .select("tr")[1...]
                    .map { tr in
                        try tr.select("td")
                    }
                    .map { tds in
                        try tds.map { td in
                            try td.text()
                        }
                    }
                    .map { data -> Course in
                        let hourArray = data[1].split(separator: "-")
                        let startHour = Int(String(hourArray[0]))!
                        let endHour = Int(String(hourArray[1]))!
                        return Course(
                            day: data[0],
                            startHour: startHour,
                            endHour: endHour,
                            frequency: data[2],
                            room: data[3],
                            group: data[4],
                            type: data[5],
                            name: data[6],
                            teacher: data[7],
                            id: UUID().uuidString
                        )
                    }
                )
            }
        }.resume()
    }
    
    func getYears(completionHandler: @escaping ([Year]?) -> ()) {
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
                            Year(id: id, value: "\(tuple.name) - Year \(index + 1)")
                        }
                    }
                    .flatMap { $0 }
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
                    .map { group in
                        Group(id: group, value: group)
                    }
                )
            }
        }.resume()
    }
}
