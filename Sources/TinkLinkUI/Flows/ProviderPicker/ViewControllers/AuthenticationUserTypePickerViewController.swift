import TinkLink
import UIKit

/// Example of how to use the provider grouped by credential type
final class AuthenticationUserTypePickerViewController: UITableViewController {
    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    let authenticationUserTypeNodes: [ProviderTree.AuthenticationUserTypeNode]

    init(authenticationUserTypeNodes: [ProviderTree.AuthenticationUserTypeNode]) {
        self.authenticationUserTypeNodes = authenticationUserTypeNodes
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension AuthenticationUserTypePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        tableView.registerReusableCell(ofType: CredentialsKindCell.self)
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
    }
}

// MARK: - UITableViewDataSource

extension AuthenticationUserTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authenticationUserTypeNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = authenticationUserTypeNodes[indexPath.row]
        let icon: Icon = node.authenticationUserType == .business ? .bankID : .password

        let cell = tableView.dequeueReusableCell(ofType: CredentialsKindCell.self, for: indexPath)
        cell.setIcon(icon)

        switch node.authenticationUserType {
        case .business:
            cell.setTitle(text: NSLocalizedString("SelectAuthenticationUserType.Business.Title", comment: "Title for the business authentication user type"))
        case .personal:
            cell.setTitle(text: NSLocalizedString("SelectAuthenticationUserType.Personal.Title", comment: "Title for the personal authentication user type"))
        case .unknown:
            fatalError("Unknow authentication user type")
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let authenticationUserTypeNode = authenticationUserTypeNodes[indexPath.row]
//        providerPickerCoordinator?.didSelectProvider(credentialsKindNode.provider)
    }
}
