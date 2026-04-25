import UIKit

protocol TitleSectionViewDelegate: UITextFieldDelegate {
    func titleDidChange(_ text: String)
}

final class TitleSectionView: UIView {
    
    weak var delegate: TitleSectionViewDelegate?
    
    private let titleTextField = UITextField()
    private let errorLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupTitleTextField()
        setupErrorLabel()
        setupConstraints()
    }
    
    private func setupTitleTextField() {
        titleTextField.placeholder = "Введите название трекера"
        titleTextField.font = AppTextStyles.regular17
        titleTextField.borderStyle = .none
        titleTextField.layer.cornerRadius = 18
        titleTextField.clipsToBounds = true
        titleTextField.backgroundColor = UIColor(resource: .ypBackground)
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        titleTextField.leftView = leftPaddingView
        titleTextField.leftViewMode = .always
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .gray
        clearButton.imageView?.contentMode = .scaleAspectFit
        clearButton.contentHorizontalAlignment = .center
        clearButton.contentVerticalAlignment = .center
        clearButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.isHidden = true
        clearButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 8)

        titleTextField.rightView = clearButton
        titleTextField.rightViewMode = .always
        titleTextField.delegate = self
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleTextField)
    }
    
    private func setupErrorLabel() {
        errorLabel.text = "Ограничение 38 символов"
        errorLabel.font = AppTextStyles.regular17
        errorLabel.textColor = .ypRed
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: topAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Public Methods
    
    func getTitle() -> String? {
        let text = titleTextField.text ?? ""
        return text.isEmpty ? nil : text
    }
    
    func showError(_ show: Bool) {
        errorLabel.isHidden = !show
        if show {
            let shake = CABasicAnimation(keyPath: "position")
            shake.duration = 0.1
            shake.repeatCount = 2
            shake.autoreverses = true
            shake.fromValue = NSValue(cgPoint: CGPoint(x: titleTextField.center.x - 5, y: titleTextField.center.y))
            shake.toValue = NSValue(cgPoint: CGPoint(x: titleTextField.center.x + 5, y: titleTextField.center.y))
            titleTextField.layer.add(shake, forKey: "shake")
        }
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange() {
        let text = titleTextField.text ?? ""
        titleTextField.rightView?.isHidden = text.isEmpty
        delegate?.titleDidChange(text)
        
        showError(text.count >= UIConstants.maxTitleLength)
    }

    @objc private func clearTextField() {
        titleTextField.text = ""
        titleTextField.rightView?.isHidden = true
        showError(false)
        titleTextField.becomeFirstResponder()
        delegate?.titleDidChange("")
    }
}

// MARK: - UITextFieldDelegate

extension TitleSectionView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn?(textField) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}
