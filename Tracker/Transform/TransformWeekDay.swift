import Foundation

import Foundation

@objc
class TransformWeekDay: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([WeekDay].self, from: data as Data)
    }

    static func register() {
        ValueTransformer.setValueTransformer(
            TransformWeekDay(),
            forName: NSValueTransformerName(rawValue: String(describing: TransformWeekDay.self))
        )
    }
}
