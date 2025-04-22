import Foundation
import SwiftUI

enum LineType: String, Codable, CaseIterable, Identifiable {
    case article
    case category
    case pageBreak

    var id: String { rawValue }
}

final class QuoteArticle: ObservableObject, Identifiable, Codable {
    let id: UUID

    @Published var designation: String
    @Published var quantity: Int
    @Published var unit: String
    @Published var unitPrice: Double
    @Published var lineType: LineType
    @Published var comment: String?
    @Published var cachedHeight: CGFloat = 22.0

    enum CodingKeys: String, CodingKey {
        case id, designation, quantity, unit, unitPrice, lineType, comment, cachedHeight
    }

    init(
        id: UUID = UUID(),
        designation: String = "",
        quantity: Int = 1,
        unit: String = "u",
        unitPrice: Double = 0.0,
        lineType: LineType = .article,
        comment: String? = nil
    ) {
        self.id = id
        self.designation = designation
        self.quantity = quantity
        self.unit = unit
        self.unitPrice = unitPrice
        self.lineType = lineType
        self.comment = comment
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        designation = try container.decode(String.self, forKey: .designation)
        quantity = try container.decode(Int.self, forKey: .quantity)
        unit = try container.decode(String.self, forKey: .unit)
        unitPrice = try container.decodeIfPresent(Double.self, forKey: .unitPrice) ?? 0.0
        lineType = try container.decode(LineType.self, forKey: .lineType)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        cachedHeight = try container.decodeIfPresent(CGFloat.self, forKey: .cachedHeight) ?? 22.0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(designation, forKey: .designation)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(unit, forKey: .unit)
        try container.encode(unitPrice, forKey: .unitPrice)
        try container.encode(lineType, forKey: .lineType)
        try container.encodeIfPresent(comment, forKey: .comment)
        try container.encode(cachedHeight, forKey: .cachedHeight)
    }

    // MARK: - Calcul
    var totalHT: Double {
        Double(quantity) * unitPrice
    }
}

extension QuoteArticle: Equatable {
    static func == (lhs: QuoteArticle, rhs: QuoteArticle) -> Bool {
        lhs.id == rhs.id &&
        lhs.designation == rhs.designation &&
        lhs.quantity == rhs.quantity &&
        lhs.unit == rhs.unit &&
        lhs.unitPrice == rhs.unitPrice &&
        lhs.lineType == rhs.lineType &&
        lhs.comment == rhs.comment
    }
}
