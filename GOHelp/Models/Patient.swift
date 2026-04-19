import Foundation

enum PatientSector: String, CaseIterable, Codable, Identifiable {
    case admissao = "Admissão"
    case preParto = "Pré-parto"
    case enfermaria = "Enfermaria"
    case centroCirurgico = "Centro cirúrgico"
    case pendenciasGerais = "Pendências gerais"

    var id: String { rawValue }
}

struct Patient: Identifiable, Codable, Equatable {
    let id: String
    var nome: String
    var quarto: String
    var setor: PatientSector
    var medicacao: Medication
    var statusResolvido: Bool
    var createdAt: Date
    var updatedAt: Date
    var createdByName: String
    var resolvedAt: Date?

    init(
        id: String = UUID().uuidString,
        nome: String,
        quarto: String,
        setor: PatientSector,
        medicacao: Medication,
        statusResolvido: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        createdByName: String,
        resolvedAt: Date? = nil
    ) {
        self.id = id
        self.nome = nome
        self.quarto = quarto
        self.setor = setor
        self.medicacao = medicacao
        self.statusResolvido = statusResolvido
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdByName = createdByName
        self.resolvedAt = resolvedAt
    }

    init?(id: String, data: [String: Any]) {
        guard
            let nome = data["nome"] as? String,
            let quarto = data["quarto"] as? String,
            let setorRaw = data["setor"] as? String,
            let setor = PatientSector(rawValue: setorRaw),
            let medRaw = data["medicacao"] as? String,
            let medicacao = Medication(rawValue: medRaw),
            let statusResolvido = data["statusResolvido"] as? Bool,
            let createdByName = data["createdByName"] as? String
        else { return nil }

        self.id = id
        self.nome = nome
        self.quarto = quarto
        self.setor = setor
        self.medicacao = medicacao
        self.statusResolvido = statusResolvido
        self.createdByName = createdByName

        let createdTs = data["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970
        let updatedTs = data["updatedAt"] as? TimeInterval ?? createdTs
        self.createdAt = Date(timeIntervalSince1970: createdTs)
        self.updatedAt = Date(timeIntervalSince1970: updatedTs)

        if let resolvedTs = data["resolvedAt"] as? TimeInterval {
            self.resolvedAt = Date(timeIntervalSince1970: resolvedTs)
        } else {
            self.resolvedAt = nil
        }
    }

    var asDictionary: [String: Any] {
        [
            "nome": nome,
            "quarto": quarto,
            "setor": setor.rawValue,
            "medicacao": medicacao.rawValue,
            "statusResolvido": statusResolvido,
            "createdAt": createdAt.timeIntervalSince1970,
            "updatedAt": updatedAt.timeIntervalSince1970,
            "createdByName": createdByName,
            "resolvedAt": resolvedAt?.timeIntervalSince1970 as Any
        ]
    }
}
