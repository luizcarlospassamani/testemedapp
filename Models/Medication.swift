import Foundation

enum Medication: String, CaseIterable, Identifiable, Codable {
    case misoprostol = "Misoprostol"
    case bcf = "BCF"
    case ctg = "CTG"
    case teste = "Teste"

    var id: String { rawValue }

    var intervalSeconds: TimeInterval {
        switch self {
        case .misoprostol: return 4 * 60 * 60
        case .bcf: return 60 * 60
        case .ctg: return 3 * 60 * 60
        case .teste: return 60
        }
    }

    var displayName: String {
        switch self {
        case .misoprostol: return "Misoprostol — 4h"
        case .bcf: return "BCF — 1h"
        case .ctg: return "CTG — 3h"
        case .teste: return "Teste — 1 min"
        }
    }
}
