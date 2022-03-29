//
// Created by Dimitrie-Toma Furdui on 20.02.2022.
//

import Foundation

enum AppErrorSubtype {
    case years
    case groups
    case subgroups
    case timetable
    case courses
    case count
}

enum EditSubtype {
    case isHidden
}

enum AppErrorType {
    case urlInvalid(_ subtype: AppErrorSubtype)
    case invalidData(_ subtype: AppErrorSubtype)
    case requestFailed(_ subtype: AppErrorSubtype)
    case parseFailed(_ subtype: AppErrorSubtype)
    case fetchFailed(_ subtype: AppErrorSubtype)
    case editFailed(_ subtype: EditSubtype)
}

struct AppError {
    let message: String
    let type: AppErrorType
    let additionalData: [String: Any]?
    
    init(message: String, type: AppErrorType, additionalData: [String: Any]? = nil) {
        self.message = message
        self.type = type
        self.additionalData = additionalData
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        """
        \(message)

        Please report this error to the developer with the following info:

        type: \(type)
        additionalData: \(additionalData as Any)
        """
    }
}
