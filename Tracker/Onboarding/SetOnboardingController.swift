import UIKit

final class SetOnboardingController: UIViewController {
    
    private var onboardingModel: OnboardingModel?
    
    init(onboardingModel: OnboardingModel){
        self.onboardingModel = onboardingModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var lable = {
        let label = UILabel()
        label.text = onboardingModel?.text
        label.font = .boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var onboardingImage = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        if let image = onboardingModel?.image {
            imageView.image = image
        }else{
            imageView.backgroundColor = .white
        }
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupConstraints()
    }

    private func addSubviews() {
        [
            onboardingImage,
            lable
        ].forEach { [weak self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            self?.view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            lable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 15),
            lable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            lable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            onboardingImage.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            onboardingImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingImage.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
