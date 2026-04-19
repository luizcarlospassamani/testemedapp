import Foundation

@MainActor
final class PatientViewModel: ObservableObject {
    @Published var patients: [Patient] = []
    @Published var history: [ChangeHistory] = []
    @Published var isLoading = false
    @Published var searchText: String = ""
    @Published var errorMessage: String?

    @Published var selectedSetor: PatientSector?
    @Published var selectedMedication: Medication?
    @Published var selectedQuarto: String = ""

    private let service = FirestoreService.shared
    private let notificationManager = NotificationManager.shared

    func requestNotificationPermission() {
        Task { await notificationManager.requestAuthorization() }
    }

    func loadPatients() async {
        isLoading = true
        defer { isLoading = false }

        do {
            patients = try await service.fetchPatients().sorted { $0.createdAt > $1.createdAt }
            let ids = patients.map(\.id)
            history = await service.fetchFullHistory(patientIds: ids)
        } catch {
            errorMessage = "Erro ao buscar pacientes: \(error.localizedDescription)"
        }
    }

    func addPatient(nome: String, quarto: String, setor: PatientSector, medicacao: Medication, userName: String) async {
        guard !nome.isEmpty, !quarto.isEmpty else {
            errorMessage = "Preencha nome e quarto do paciente."
            return
        }

        let patient = Patient(nome: nome, quarto: quarto, setor: setor, medicacao: medicacao, createdByName: userName)

        do {
            try await service.createPatient(patient)
            notificationManager.scheduleNotifications(for: patient)
            await loadPatients()
        } catch {
            errorMessage = "Erro ao criar paciente: \(error.localizedDescription)"
        }
    }

    func updatePatient(old: Patient, new: Patient, changedBy: String) async {
        do {
            try await service.updatePatient(new)
            try await saveHistoryDiff(old: old, new: new, changedBy: changedBy)
            notificationManager.scheduleNotifications(for: new)
            await loadPatients()
        } catch {
            errorMessage = "Erro ao atualizar paciente: \(error.localizedDescription)"
        }
    }

    func resolvePatient(_ patient: Patient, changedBy: String) async {
        do {
            try await service.markPatientResolved(patientId: patient.id)
            let historyEntry = ChangeHistory(
                patientId: patient.id,
                fieldName: "statusResolvido",
                oldValue: "false",
                newValue: "true",
                changedByName: changedBy
            )
            try await service.addHistory(historyEntry, patientId: patient.id)
            notificationManager.cancelNotifications(for: patient.id)
            await loadPatients()
        } catch {
            errorMessage = "Erro ao resolver paciente: \(error.localizedDescription)"
        }
    }

    func deletePatient(_ patient: Patient) async {
        do {
            try await service.deletePatient(patientId: patient.id)
            notificationManager.cancelNotifications(for: patient.id)
            await loadPatients()
        } catch {
            errorMessage = "Erro ao excluir paciente: \(error.localizedDescription)"
        }
    }

    private func saveHistoryDiff(old: Patient, new: Patient, changedBy: String) async throws {
        let pairs: [(String, String, String)] = [
            ("nome", old.nome, new.nome),
            ("quarto", old.quarto, new.quarto),
            ("setor", old.setor.rawValue, new.setor.rawValue),
            ("medicacao", old.medicacao.rawValue, new.medicacao.rawValue)
        ]

        for (field, oldValue, newValue) in pairs where oldValue != newValue {
            let h = ChangeHistory(
                patientId: old.id,
                fieldName: field,
                oldValue: oldValue,
                newValue: newValue,
                changedByName: changedBy
            )
            try await service.addHistory(h, patientId: old.id)
        }
    }

    var filteredPatients: [Patient] {
        patients.filter { patient in
            let matchesSearch = searchText.isEmpty || patient.nome.localizedCaseInsensitiveContains(searchText)
            let matchesSetor = selectedSetor == nil || patient.setor == selectedSetor
            let matchesMedication = selectedMedication == nil || patient.medicacao == selectedMedication
            let matchesQuarto = selectedQuarto.isEmpty || patient.quarto.localizedCaseInsensitiveContains(selectedQuarto)
            return matchesSearch && matchesSetor && matchesMedication && matchesQuarto
        }
    }

    var activePatients: [Patient] { filteredPatients.filter { !$0.statusResolvido } }
    var resolvedPatients: [Patient] { filteredPatients.filter { $0.statusResolvido } }
}
