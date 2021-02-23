import SwiftUI

@main
struct UBBApp: App {
    @StateObject var timetableService = TimetableService()
    let persistenceController = PersistenceController.shared

    @State var activeTab: Int = 0
    @State var isAlertShown = false
    @State var errorMessage: String? = nil

    var body: some Scene {
        WindowGroup {
            TabView(selection: self.$activeTab) {
                TimetableView(activeTab: self.$activeTab)
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("Timetable")
                    }
                    .tag(0)
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .tag(1)
            }
            .environmentObject(self.timetableService)
            .environment(\.managedObjectContext, self.persistenceController.container.viewContext)
            .onReceive(self.timetableService.errorOccurred) { error in
                self.errorMessage = error.localizedDescription
                self.isAlertShown = true
            }
            .alert(isPresented: self.$isAlertShown) {
                Alert(
                    title: Text("An error occured :("),
                    message: Text(self.errorMessage!)
                )
            }
        }
    }
}
