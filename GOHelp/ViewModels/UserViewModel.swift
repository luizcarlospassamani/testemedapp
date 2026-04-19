import Foundation

@MainActor
final class UserViewModel: ObservableObject {
    @Published var nomeInput: String = ""
    @Published var currentUser: SimpleUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = FirestoreService.shared
    private let userDefaultsKey = "current_user_name"

    init() {
        if let savedName = UserDefaults.standard.string(forKey: userDefaultsKey), !savedName.isEmpty {
            nomeInput = savedName
            Task { await loginOrCreateUser() }
        }
    }

    var isLoggedIn: Bool { currentUser != nil }

    func loginOrCreateUser() async {
        let cleanName = nomeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            errorMessage = "Informe o nome do usuário."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            if let existing = try await service.findUserByName(cleanName) {
                currentUser = existing
            } else {
                currentUser = try await service.createUser(nome: cleanName)
            }
            UserDefaults.standard.set(cleanName, forKey: userDefaultsKey)
        } catch {
            errorMessage = "Falha ao acessar usuário no Firestore: \(error.localizedDescription)"
        }
    }

    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
