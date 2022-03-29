//
//  HideCoursesView.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 06.03.2022.
//

import SwiftUI

struct HideCoursesView: View {
    @EnvironmentObject private var timetableService: TimetableService
    @Environment(\.dismiss) private var dismiss
    @State private var selection = Set<String>()
    @State private var names = [String]()
    @State private var isLoaded = false
    @State private var courses = [Course]()

    var body: some View {
        NavigationView {
            List(names, id: \.self, selection: $selection) { name in
                Text(name)
            }
            .navigationTitle(Text("Hide courses"))
            .environment(\.editMode, .constant(.active))
            .navigationBarItems(
                trailing:
                    Button(
                        action: {
                            dismiss()
                        }
                    ) {
                        Text("Done").bold()
                    }
            )
            .onAppear {
                if let courses = try? timetableService.getAllCourses() {
                    self.courses = courses
                    self.names = courses.map(\.name).unique
                    for (name, courses) in courses.grouped(by: \.name).elements {
                        var areAllHidden = true
                        for course in courses {
                            if
                                let editedCourse = timetableService
                                    .getExistingEditedCourse(
                                        course: course
                                    ),
                                editedCourse.isHidden
                            {} else {
                                areAllHidden = false
                            }
                        }
                        if areAllHidden {
                            selection.insert(name)
                        }
                    }
                }
                self.isLoaded = true
            }
            .onChange(of: selection) { selection in
                if !isLoaded {
                    return
                }
                for course in courses {
                    let editedCourse = timetableService.getOrCreateEditedCourse(course: course)
                    editedCourse.isHidden = selection.contains(course.name)
                    do {
                        try PersistenceController
                            .shared
                            .container
                            .viewContext
                            .save()
                    } catch {
                        let error = AppError(
                            message: "Could not save changes",
                            type: .editFailed(.isHidden),
                            additionalData: [
                                "id": course.id
                            ]
                        )
                        // is there even a better way? lol
                        // for some reason we cannot show an alert over a sheet
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            timetableService.errorOccurred.send(error)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
