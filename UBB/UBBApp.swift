import SwiftUI
import Sentry

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        SentrySDK.start { options in
            options.dsn = "https://f3581c20a24649a6aa35e5379509df93@o516992.ingest.sentry.io/5647908"
        }
        if ProcessInfo.processInfo.arguments.contains("test") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
        return true
    }
}

@main
struct UBBApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    @StateObject var timetableService = TimetableService.shared
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
            .onAppear {
                Task {
                    await timetableService.updateTimetable()
                }
            }
            .environmentObject(timetableService)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .onReceive(timetableService.errorOccurred) { error in
                self.errorMessage = error.localizedDescription
                self.isAlertShown = true
            }
            .alert(isPresented: self.$isAlertShown) {
                Alert(
                    title: Text("An error occured :("),
                    message: Text(errorMessage!),
                    primaryButton: .default(Text("Ok")),
                    secondaryButton: .default(Text("Copy debug information")) {
                        UIPasteboard.general.string = errorMessage
                    }
                )
            }
        }
    }
}
