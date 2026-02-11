import UIKit

class HomeViewController: UIViewController {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 16
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .black
        label.text = "Player Scenarios"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cases"
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])

        stackView.addArrangedSubview(titleLabel)

        let case1 = makeLinkButton(title: "Case 1: Sequential playback")
        case1.addTarget(self, action: #selector(openCase1), for: .touchUpInside)
        stackView.addArrangedSubview(case1)

        let case2 = makeLinkButton(title: "Case 2: Viewport-aware playback")
        case2.addTarget(self, action: #selector(openCase2), for: .touchUpInside)
        stackView.addArrangedSubview(case2)
    }

    private func makeLinkButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.systemFont(ofSize: 17, weight: .medium)
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.contentHorizontalAlignment = .leading
        return button
    }

    @objc private func openCase1() {
        let controller = ViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func openCase2() {
        let controller = ViewportViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
