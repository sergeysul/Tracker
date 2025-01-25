import UIKit

enum OnboardingModel {
    case blue
    case red
    
    var image: UIImage? {
        switch self {
        case .blue:
            return UIImage(named: "blue_image")
        case .red:
            return UIImage(named: "red_image")
        }
    }
    
    var text: String {
        switch self {
        case .blue:
            return "Отслеживайте только то, что хотите"
        case .red:
            return "Даже если это не литры воды и йога"
        }
    }
}
