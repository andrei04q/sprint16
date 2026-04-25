import UIKit

class StatisticsViewController: UIViewController {
    
    private let placeholderView: UIView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let cryImage = UIImageView(image: UIImage(named: "emptyCry"))
        cryImage.tintColor = UIColor(resource: .ypGray)
        cryImage.contentMode = .scaleAspectFit
        cryImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        cryImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let label = UILabel()
        label.attributedText = AppTextStyles.attributed(
            "Анализируем твою активность...\n\nСтатистика будет готова, когда ты начнешь трекать привычки",
            style: AppTextStyles.medium12,
            lineHeight: 12,
            color: UIColor(resource: .ypGray)
        )
        label.textAlignment = .center
        label.numberOfLines = 0
        
        stack.addArrangedSubview(cryImage)
        stack.addArrangedSubview(label)
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ StatisticsViewController: viewDidLoad")
        
        title = "Статистика"
        view.backgroundColor = UIColor(resource: .ypWhite)
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: AppTextStyles.bold34,
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        
        setupPlaceholder()
    }

    private func setupPlaceholder() {
        view.addSubview(placeholderView)
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
