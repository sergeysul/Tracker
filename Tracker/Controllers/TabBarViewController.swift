import UIKit

final class TabBarViewController: UITabBarController {
    
    private let trackersName = NSLocalizedString("trackers", comment: "кнопка трекеров")
    private let statsName = NSLocalizedString("statistics", comment: "кнопка статистики")
    private let themeSettings: ThemeSettings = .shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        tabBar.layer.borderColor = themeSettings.tabBarBorder.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.layer.masksToBounds = true
        
        let trackerController = TrackerController()
        trackerController.tabBarItem = UITabBarItem(title: trackersName, image: UIImage(named: "TrackerLogo"), selectedImage: nil )
        
        let statsController = StatsController()
        statsController.tabBarItem = UITabBarItem(title: statsName, image: UIImage(named: "StatsLogo"), selectedImage: nil)
        
        self.viewControllers = [trackerController, statsController]
    }
}

