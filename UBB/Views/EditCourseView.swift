//
//  EditCourseView.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 21.02.2022.
//

import SwiftUI
import CoreData

struct EditCourseView: View {
    @EnvironmentObject private var timetableService: TimetableService
    @Environment(\.dismiss) private var dismiss
    @State private var isHidden = false
    var course: Course
        
    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $isHidden) {
                    Text("Hide")
                }
            }
            .navigationBarTitle(
                Text("Edit course"),
                displayMode: .inline
            )
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
//                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = EditedCourse.fetchRequest()
//                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//                try! PersistenceController.shared.container.viewContext.executeAndMergeChanges(batchDeleteRequest)
                
//                let fetchRequest = EditedCourse.fetchRequest()
//                let objects = try? viewContext.fetch(fetchRequest)
//                print(objects)

                let course = timetableService.getExistingEditedCourse(course: course)
                if let course = course {
                    isHidden = course.isHidden
                }
            }
            .onChange(of: isHidden) { newValue in
                let course = timetableService.getOrCreateEditedCourse(course: course)
                course.isHidden = newValue
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
                            "id": self.course.id
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
