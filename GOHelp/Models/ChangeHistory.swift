import Foundation

struct ChangeHistory: Identifiable, Codable {
    let id: String
    let patientId: String
    let fieldName: String
    let oldValue: String
    let newValue: String
    let changedAt: Date
    let changedByName: String

    init(
        id: String = UUID().uuidString,
        patientId: String,
        fieldName: String,
        oldValue: String,
        newValue: String,
        changedAt: Date = Date(),
        changedByName: String
    ) {
        self.id = id
        self.patientId = patientId
        self.fieldName = fieldName
        self.oldValue = oldValue
        self.newValue = newValue
        self.changedAt = changedAt
        self.changedByName = changedByName
    }

    init?(id: String, data: [String: Any]) {
        guard
            let patientId = data["patientId"] as? String,
            let fieldName = data["fieldName"] as? String,
            let oldValue = data["oldValue"] as? String,
            let newValue = data["newValue"] as? String,
            let changedByName = data["changedByName"] as? String
        else { return nil }

        self.id = id
        self.patientId = patientId
        self.fieldName = fieldName
        self.oldValue = oldValue
        self.newValue = newValue
        self.changedByName = changedByName
        let ts = data["changedAt"] as? TimeInterval ?? Date().timeIntervalSince1970
        self.changedAt = Date(timeIntervalSince1970: ts)
    }

    var asDictionary: [String: Any] {
        [
            "patientId": patientId,
            "fieldName": fieldName,
            "oldValue": oldValue,
            "newValue": newValue,
            "changedAt": changedAt.timeIntervalSince1970,
            "changedByName": changedByName
        ]
    }
}
