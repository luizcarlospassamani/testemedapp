import SwiftUI

struct PatientsListView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var patientVM: PatientViewModel
    @State private var showingForm = false

    var body: some View {
        List {
            Section("Ativos") {
                ForEach(patientVM.activePatients) { patient in
                    NavigationLink(destination: PatientDetailView(patient: patient)) {
                        patientRow(patient, highlight: true)
                    }
                    .swipeActions {
                        Button("Resolvido") {
                            Task { await patientVM.resolvePatient(patient, changedBy: userVM.currentUser?.nome ?? "Sistema") }
                        }.tint(.green)
                        Button("Excluir", role: .destructive) {
                            Task { await patientVM.deletePatient(patient) }
                        }
                    }
                }
            }

            Section("Resolvidos") {
                ForEach(patientVM.resolvedPatients) { patient in
                    NavigationLink(destination: PatientDetailView(patient: patient)) {
                        patientRow(patient, highlight: false)
                    }
                }
            }
        }
        .searchable(text: $patientVM.searchText, prompt: "Buscar paciente")
        .overlay {
            if patientVM.isLoading { ProgressView() }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Sair") { userVM.logout() }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink("Painel") { DashboardView() }
                Button { showingForm = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingForm) {
            NavigationStack { PatientFormView(patient: nil) }
        }
        .task {
            patientVM.requestNotificationPermission()
            await patientVM.loadPatients()
        }
        .navigationTitle("Pacientes")
    }

    private func patientRow(_ patient: Patient, highlight: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(patient.nome).font(.headline)
            Text("Quarto: \(patient.quarto) • Setor: \(patient.setor.rawValue)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Medicação: \(patient.medicacao.displayName)").font(.caption)
            Text(highlight ? "Status: Ativo" : "Status: Resolvido")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(highlight ? .blue : .green)
        }
        .padding(.vertical, 4)
    }
}
