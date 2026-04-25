import UIKit

final class ScheduleViewController: UIViewController {
    private let contentView = UIView()
    private let tableView = UITableView()
    private let doneButton = UIButton(type: .system)

    var selectedDays: [WeekDay] = []
    var onSave: (([WeekDay]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        view.backgroundColor = UIColor(resource: .ypWhite)
        navigationItem.hidesBackButton = true
        setupNavigationTitle()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupNavigationTitle() {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }

    private func setupLayout() {
        contentView.backgroundColor = UIColor(resource: .ypBackground)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = UIColor(resource: .ypBlack)
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        doneButton.isEnabled = true
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentView)
        contentView.addSubview(tableView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentView.heightAnchor.constraint(equalToConstant: 525),
            
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func didTapDone() {
        onSave?(selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Cell

final class ScheduleCell: UITableViewCell {
    static let identifier = "ScheduleCell"

    let dayLabel = UILabel()
    let daySwitch = UISwitch()
    let separatorView = UIView()

    var onToggle: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        dayLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        dayLabel.textColor = UIColor(resource: .ypBlack)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        daySwitch.onTintColor = UIColor(resource: .ypBlue)
        daySwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        
        separatorView.backgroundColor = UIColor(named: "ypBlack")?.withAlphaComponent(0.3)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.isHidden = false

        contentView.addSubview(dayLabel)
        contentView.addSubview(daySwitch)
        contentView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        selectionStyle = .none
        backgroundColor = UIColor(resource: .ypBackground)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        separatorView.isHidden = false
        onToggle = nil
    }

    @objc private func switchToggled() {
        onToggle?(daySwitch.isOn)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier,
                                                       for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }

        let day = WeekDay.allCases[indexPath.row]
        cell.dayLabel.text = day.title
        cell.daySwitch.isOn = selectedDays.contains(day)
        
        cell.separatorView.isHidden = (indexPath.row == WeekDay.allCases.count - 1)
        
        cell.onToggle = { [weak self] isOn in
            guard let self = self else { return }
            if isOn {
                if !self.selectedDays.contains(day) {
                    self.selectedDays.append(day)
                }
            } else {
                self.selectedDays.removeAll { $0 == day }
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
