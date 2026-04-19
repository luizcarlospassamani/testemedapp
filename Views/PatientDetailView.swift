import SwiftUI

struct PatientDetailView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var patientVM: PatientViewModel

    let patient: Patient
    @State private var showEdit = false

    var body: some View {
        List {
            Section("Paciente") {
                row("Nome", patient.nome)
                row("Quarto", patient.quarto)
                row("Setor", patient.setor.rawValue)
                row("Medicação", patient.medicacao.displayName)
                row("Status", patient.statusResolvido ? "Resolvido" : "Ativo")
            }

            Section("Ações") {
                Button("Editar") { showEdit = true }
                if !patient.statusResolvido {
                    Button("Marcar como resolvido") {
                        Task { await patientVM.resolvePatient(patient, changedBy: userVM.currentUser?.nome ?? "Sistema") }
                    }
                    .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle("Detalhes")
        .sheet(isPresented: $showEdit) {
            NavigationStack { PatientFormView(patient: patient) }
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}
