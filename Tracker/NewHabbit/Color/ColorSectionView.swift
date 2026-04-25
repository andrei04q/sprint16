import UIKit

protocol ColorSectionViewDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

final class ColorSectionView: UIView {
    weak var delegate: ColorSectionViewDelegate?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = AppTextStyles.bold19
        label.textColor = UIColor(resource: .ypBlack)
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 52, height: 52)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private var selectedColor: UIColor?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(containerView)
        containerView.addSubview(collectionView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),

            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            containerView.heightAnchor.constraint(equalToConstant: 180),

            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }

    func getSelectedColor() -> UIColor? {
        selectedColor
    }

    func setSelectedColor(_ color: UIColor?) {
        selectedColor = color
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension ColorSectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        MockData.colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCell.identifier,
            for: indexPath
        ) as? ColorCell else {
            return UICollectionViewCell()
        }

        let color = MockData.colors[indexPath.item]
        let isSelected = selectedColor == color
        cell.configure(with: color, isSelected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedColor = MockData.colors[indexPath.item]
        self.selectedColor = selectedColor
        collectionView.reloadData()
        delegate?.didSelectColor(selectedColor)
    }
}
