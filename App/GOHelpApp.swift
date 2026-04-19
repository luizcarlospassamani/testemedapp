import SwiftUI
import FirebaseCore

@main
struct GOHelpApp: App {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var patientViewModel = PatientViewModel()

    init() {
        // IMPORTANTE:
        // 1) Adicione o arquivo GoogleService-Info.plist no target do app no Xcode.
        // 2) Em Xcode > Project > Package Dependencies, adicione:
        //    https://github.com/firebase/firebase-ios-sdk
        // 3) Selecione os produtos FirebaseCore e FirebaseFirestore.
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            EntryView()
                .environmentObject(userViewModel)
                .environmentObject(patientViewModel)
        }
    }
}
