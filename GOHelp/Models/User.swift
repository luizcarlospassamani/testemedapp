import Foundation

struct SimpleUser: Identifiable, Codable, Equatable {
    let id: String
    var nome: String
    var createdAt: Date

    init(id: String = UUID().uuidString, nome: String, createdAt: Date = Date()) {
        self.id = id
        self.nome = nome
        self.createdAt = createdAt
    }

    init?(id: String, data: [String: Any]) {
        guard let nome = data["nome"] as? String else { return nil }
        self.id = id
        self.nome = nome
        if let ts = data["createdAt"] as? TimeInterval {
            self.createdAt = Date(timeIntervalSince1970: ts)
        } else {
            self.createdAt = Date()
        }
    }

    var asDictionary: [String: Any] {
        [
            "nome": nome,
            "createdAt": createdAt.timeIntervalSince1970
        ]
    }
}
