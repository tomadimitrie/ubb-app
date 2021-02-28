import SwiftUI
import CoreData

struct EditCoursesView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var timetableService: TimetableService
    @State private var selectionKeeper = Set<String>()
    @State private var loaded = false
    @Binding var hiddenCourses: [String]
    
    var body: some View {
        NavigationView {
            List(selection: self.$selectionKeeper) {
                ForEach(self.timetableService.uniqueCourseNames, id: \.self) { name in
                    Text(name)
                }
            }
            .environment(\.editMode, .constant(.active))
            .onChange(of: self.selectionKeeper) { selection in
                guard self.loaded else { return }
                self.hiddenCourses =
                    self.timetableService
                        .uniqueCourseNames
                        .asSet
                        .symmetricDifference(self.selectionKeeper)
                        .asArray
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            self.timetableService
                .uniqueCourseNames
                .asSet
                .symmetricDifference(
                    self.hiddenCourses
                )
                .forEach {
                    self.selectionKeeper.insert($0)
                }
            self.loaded = true
        }
    }
}
