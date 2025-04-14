import Foundation

@objc(UUIDArrayTransformer)
final class UUIDArrayTransformer: ValueTransformer {
    override class func allowsReverseTransformation() -> Bool { true }
    override class func transformedValueClass() -> AnyClass { NSData.self }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [UUID] else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: false)
    }

    override func reverseTransformedValue(_ data: Any?) -> Any? {
        guard let data = data as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [UUID]
    }
}

extension NSValueTransformerName {
    static let uuidArrayTransformerName = NSValueTransformerName(rawValue: "UUIDArrayTransformer")
}
