import UIKit

final class ThemeSettings {
    
    static let shared = ThemeSettings()
    private init() {}
    
    var tabBarBorder: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .gray
        }
    }
    
    var separatorColor: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .lightGray: .gray
        }
    }
}
