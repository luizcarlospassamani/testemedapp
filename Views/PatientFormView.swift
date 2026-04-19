import SwiftUI

struct PatientFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var patientVM: PatientViewModel
    @EnvironmentObject private var userVM: UserViewModel

    let patient: Patient?

    @State private var nome: String = ""
    @State private var quarto: String = ""
    @State private var setor: PatientSector = .admissao
    @State private var medicacao: Medication = .misoprostol

    var body: some View {
        Form {
            Section("Dados") {
                TextField("Nome do paciente", text: $nome)
                TextField("Quarto", text: $quarto)
                Picker("Setor", selection: $setor) {
                    ForEach(PatientSector.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Medicação", selection: $medicacao) {
                    ForEach(Medication.allCases) { Text($0.displayName).tag($0) }
                }
            }

            if let error = patientVM.errorMessage {
                Text(error).foregroundStyle(.red)
            }
        }
        .navigationTitle(patient == nil ? "Novo Paciente" : "Editar Paciente")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") {
                    Task {
                        await save()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            guard let patient else { return }
            nome = patient.nome
            quarto = patient.quarto
            setor = patient.setor
            medicacao = patient.medicacao
        }
    }

    private func save() async {
        guard let userName = userVM.currentUser?.nome else { return }

        if let old = patient {
            let updated = Patient(
                id: old.id,
                nome: nome,
                quarto: quarto,
                setor: setor,
                medicacao: medicacao,
                statusResolvido: old.statusResolvido,
                createdAt: old.createdAt,
                updatedAt: Date(),
                createdByName: old.createdByName,
                resolvedAt: old.resolvedAt
            )
            await patientVM.updatePatient(old: old, new: updated, changedBy: userName)
        } else {
            await patientVM.addPatient(nome: nome, quarto: quarto, setor: setor, medicacao: medicacao, userName: userName)
        }
    }
}
