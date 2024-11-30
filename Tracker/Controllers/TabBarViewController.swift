import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tabBar.layer.borderColor = CGColor(gray: 0.5, alpha: 0.5)
        tabBar.layer.borderWidth = 1
        tabBar.layer.masksToBounds = true
        
        let trackerController = TrackerController()
        trackerController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "TrackerLogo"), selectedImage: nil )
        
        let statsController = StatsController()
        statsController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "StatsLogo"), selectedImage: nil)
        
        self.viewControllers = [trackerController, statsController]
    }
}

