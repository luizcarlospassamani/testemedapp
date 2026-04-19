import SwiftUI

struct EntryView: View {
    @EnvironmentObject private var userVM: UserViewModel

    var body: some View {
        NavigationStack {
            Group {
                if userVM.isLoggedIn {
                    PatientsListView()
                } else {
                    loginCard
                }
            }
            .navigationTitle("GOHelp")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var loginCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            TextField("Nome do usuário", text: $userVM.nomeInput)
                .textFieldStyle(.roundedBorder)

            if let error = userVM.errorMessage {
                Text(error).foregroundStyle(.red).font(.footnote)
            }

            Button(action: { Task { await userVM.loginOrCreateUser() } }) {
                if userVM.isLoading {
                    ProgressView()
                } else {
                    Text("Entrar")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
