import UIKit

protocol ActionButtonsViewDelegate: AnyObject {
    func didTapCancelButton()
    func didTapCreateButton()
}

final class ActionButtonsView: UIView {
    
    weak var delegate: ActionButtonsViewDelegate?
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .ypWhite)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupCancelButton()
        setupCreateButton()
        setupStackView()
    }
    
    private func setupCancelButton() {
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.title = "Отменить"
        cancelConfig.baseForegroundColor = UIColor(resource: .ypRed)
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        cancelConfig.attributedTitle = AttributedString(
            AppTextStyles.attributed(
                "Отменить",
                style: AppTextStyles.medium16,
                color: UIColor(resource: .ypRed)
            )
        )

        cancelButton.configuration = cancelConfig
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = (UIColor(resource: .ypRed)).cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCreateButton() {
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = AppTextStyles.medium16
        createButton.backgroundColor = UIColor(resource: .ypGray)
        createButton.layer.cornerRadius = 16
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        createButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupStackView() {
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Public Methods
    
    func setCreateButtonEnabled(_ enabled: Bool) {
        createButton.isEnabled = enabled
        createButton.backgroundColor = enabled ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        delegate?.didTapCancelButton()
    }
    
    @objc private func createButtonTapped() {
        delegate?.didTapCreateButton()
    }
}
