import Foundation
import FirebaseFirestore

final class FirestoreService {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Users

    func findUserByName(_ nome: String) async throws -> SimpleUser? {
        let query = db.collection("users").whereField("nome", isEqualTo: nome).limit(to: 1)
        let snapshot = try await query.getDocuments()
        guard let document = snapshot.documents.first else { return nil }
        return SimpleUser(id: document.documentID, data: document.data())
    }

    func createUser(nome: String) async throws -> SimpleUser {
        let user = SimpleUser(nome: nome)
        try await db.collection("users").document(user.id).setData(user.asDictionary)
        return user
    }

    // MARK: - Patients

    func fetchPatients() async throws -> [Patient] {
        let snapshot = try await db.collection("patients").getDocuments()
        return snapshot.documents.compactMap { Patient(id: $0.documentID, data: $0.data()) }
    }

    func createPatient(_ patient: Patient) async throws {
        try await db.collection("patients").document(patient.id).setData(patient.asDictionary)
    }

    func updatePatient(_ patient: Patient) async throws {
        try await db.collection("patients").document(patient.id).updateData(patient.asDictionary)
    }

    func markPatientResolved(patientId: String) async throws {
        try await db.collection("patients").document(patientId).updateData([
            "statusResolvido": true,
            "resolvedAt": Date().timeIntervalSince1970,
            "updatedAt": Date().timeIntervalSince1970
        ])
    }

    func deletePatient(patientId: String) async throws {
        try await db.collection("patients").document(patientId).delete()
    }

    // MARK: - History

    func addHistory(_ history: ChangeHistory, patientId: String) async throws {
        try await db.collection("patients")
            .document(patientId)
            .collection("history")
            .document(history.id)
            .setData(history.asDictionary)
    }

    func fetchHistory(patientId: String) async throws -> [ChangeHistory] {
        let snapshot = try await db.collection("patients")
            .document(patientId)
            .collection("history")
            .getDocuments()

        return snapshot.documents
            .compactMap { ChangeHistory(id: $0.documentID, data: $0.data()) }
            .sorted { $0.changedAt > $1.changedAt }
    }

    func fetchFullHistory(patientIds: [String]) async -> [ChangeHistory] {
        guard !patientIds.isEmpty else { return [] }
        var all: [ChangeHistory] = []

        for patientId in patientIds {
            if let hist = try? await fetchHistory(patientId: patientId) {
                all.append(contentsOf: hist)
            }
        }

        return all.sorted { $0.changedAt > $1.changedAt }
    }
}
