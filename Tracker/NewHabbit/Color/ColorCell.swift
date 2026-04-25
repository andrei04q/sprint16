import UIKit

final class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"

    let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func setupUI() {
        contentView.addSubview(colorView)
        contentView.addSubview(selectedImageView)

        colorView.translatesAutoresizingMaskIntoConstraints = false
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),

            selectedImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectedImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedImageView.widthAnchor.constraint(equalToConstant: 24),
            selectedImageView.heightAnchor.constraint(equalToConstant: 24)
        ])

        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }

    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color

        contentView.layer.borderWidth = isSelected ? 3 : 0
        contentView.layer.borderColor = isSelected ? color.withAlphaComponent(0.3).cgColor : nil

        selectedImageView.isHidden = !isSelected
    }
}
