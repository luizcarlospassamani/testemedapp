import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleNotifications(for patient: Patient, occurrences: Int = 12) {
        cancelNotifications(for: patient.id)

        let interval = max(patient.medicacao.intervalSeconds, 60)
        for index in 1...occurrences {
            let content = UNMutableNotificationContent()
            content.title = "GOHelp • Medicação"
            content.body = "Paciente: \(patient.nome) | Medicação: \(patient.medicacao.rawValue) | Quarto: \(patient.quarto)"
            content.sound = .default
            content.threadIdentifier = patient.id

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval * Double(index), repeats: false)
            let request = UNNotificationRequest(
                identifier: "patient-\(patient.id)-\(index)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    func cancelNotifications(for patientId: String) {
        let identifiers = (1...24).map { "patient-\(patientId)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
