import Down
import TinkLink
import UIKit

/// Example of how to update credential
final class UpdateCredentialsViewController: UITableViewController {
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler?

    private let provider: Provider
    private let credentials: Credentials
    private let credentialsContext: CredentialsContext
    private var form: Form
    private var formError: Form.ValidationError? {
        didSet {
            tableView.reloadData()
        }
    }

    private var updateCredentialsTask: UpdateCredentialsTask?
    private var statusViewController: AddCredentialsStatusViewController?
    private lazy var updateBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updateCredential))
    private var didFirstFieldBecomeFirstResponder = false

    private lazy var helpLabel = UITextView()

    init(provider: Provider, credentials: Credentials, credentialsContext: CredentialsContext) {
        self.provider = provider
        self.credentials = credentials
        self.credentialsContext = credentialsContext
        self.form = Form(updatingCredentials: credentials, provider: provider)

        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension UpdateCredentialsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.allowsSelection = false

        navigationItem.prompt = "Update Credentials"
        navigationItem.title = provider.displayName
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = updateBarButtonItem
        navigationItem.rightBarButtonItem?.isEnabled = form.areFieldsValid

        setupHelpFootnote()
        layoutHelpFootnote()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !didFirstFieldBecomeFirstResponder, !form.fields.isEmpty, let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldCell {
            cell.textField.becomeFirstResponder()
            didFirstFieldBecomeFirstResponder = true
        }
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        layoutHelpFootnote()
    }
}

// MARK: - Help Footnote

extension UpdateCredentialsViewController {
    private func setupHelpFootnote() {
        guard let helpText = provider.helpText else { return }
        let markdown = Down(markdownString: helpText)
        helpLabel.attributedText = try? markdown.toAttributedString()
        helpLabel.backgroundColor = .clear
        helpLabel.isScrollEnabled = false
        helpLabel.isEditable = false
        if #available(iOS 13.0, *) {
            helpLabel.textColor = .secondaryLabel
        } else {
            helpLabel.textColor = .gray
        }

        let helpStackView = UIStackView(arrangedSubviews: [helpLabel])
        helpStackView.isLayoutMarginsRelativeArrangement = true

        tableView.tableFooterView = helpStackView
    }

    private func layoutHelpFootnote() {
        let footerLayoutMargins = UIEdgeInsets(top: 0, left: view.layoutMargins.left, bottom: 0, right: view.layoutMargins.right)

        let helpLabelSize = helpLabel.sizeThatFits(CGSize(width: view.bounds.inset(by: footerLayoutMargins).width, height: .infinity))

        tableView.tableFooterView?.layoutMargins = footerLayoutMargins

        tableView.tableFooterView?.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: view.bounds.width,
                height: helpLabelSize.height
            )
        )
    }
}

// MARK: - UITableViewDataSource

extension UpdateCredentialsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return form.fields.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath) as! TextFieldCell
        let field = form.fields[indexPath.section]
        cell.delegate = self
        cell.textField.placeholder = field.attributes.placeholder
        cell.textField.isSecureTextEntry = field.attributes.isSecureTextEntry
        cell.textField.isEnabled = field.attributes.isEditable
        cell.textField.text = field.text
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let field = form.fields[section]
        let suffix = field.validationRules.isOptional ? " - optional" : ""

        return field.attributes.description + suffix
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let field = form.fields[section]
        if let error = formError, let fieldError = error[fieldName: field.name] {
            return fieldError.reason
        } else {
            return field.attributes.helpText
        }
    }
}

// MARK: - Actions

extension UpdateCredentialsViewController {
    @objc private func updateCredential(_ sender: UIBarButtonItem) {
        view.endEditing(false)

        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        do {
            try form.validateFields()
            updateCredentialsTask = credentialsContext.update(
                credentials,
                form: form, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false,
                progressHandler: { [weak self] status in
                    DispatchQueue.main.async {
                        self?.handleProgress(status)
                    }
                },
                completion: { [weak self] result in
                    DispatchQueue.main.async {
                        self?.handleCompletion(result)
                    }
                }
            )
        } catch {
            formError = error as? Form.ValidationError
        }
    }

    private func handleProgress(_ status: UpdateCredentialsTask.Status) {
        switch status {
        case .authenticating:
            showUpdating(status: "Authenticating…")
        case .updating:
            showUpdating(status: "Connecting…")
        case .awaitingSupplementalInformation(let task):
            showSupplementalInformation(for: task)
        case .awaitingThirdPartyAppAuthentication(let task):
            // TODO: Handle QR image
            task.handle()
        }
    }

    private func handleCompletion(_ result: Result<Credentials, Error>) {
        do {
            let credentials = try result.get()
            showCredentialUpdated(for: credentials)
        } catch {
            showAlert(for: error)
        }
    }

    @objc private func cancelRefreshingCredentials(_ sender: Any) {
        updateCredentialsTask?.cancel()
        dismiss(animated: true)
    }
}

// MARK: - Navigation

extension UpdateCredentialsViewController {
    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        hideUpdatingView()
        let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        supplementalInformationViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: supplementalInformationViewController)
        show(navigationController, sender: nil)
    }

    private func showUpdating(status: String) {
        if statusViewController == nil {
            navigationItem.setRightBarButton(updateBarButtonItem, animated: true)
            let statusViewController = AddCredentialsStatusViewController()
            statusViewController.modalTransitionStyle = .crossDissolve
            statusViewController.modalPresentationStyle = .overFullScreen
            present(statusViewController, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.view.tintAdjustmentMode = .dimmed
            }
            self.statusViewController = statusViewController
        }
        statusViewController?.status = status
    }

    private func hideUpdatingView(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard statusViewController != nil else {
            completion?()
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.view.tintAdjustmentMode = .automatic
        }
        dismiss(animated: animated, completion: completion)
        statusViewController = nil
    }

    private func showCredentialUpdated(for credential: Credentials) {
        hideUpdatingView()
        dismiss(animated: true) {
            self.onCompletion?(.success(credential))
        }
    }

    private func showDownloadPrompt(for thirdPartyAppAuthenticationError: ThirdPartyAppAuthenticationTask.Error) {
        let alertController = UIAlertController(title: thirdPartyAppAuthenticationError.errorDescription, message: thirdPartyAppAuthenticationError.failureReason, preferredStyle: .alert)

        if let appStoreURL = thirdPartyAppAuthenticationError.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let downloadAction = UIAlertAction(title: "Download", style: .default, handler: { _ in
                UIApplication.shared.open(appStoreURL)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(downloadAction)
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
        }

        present(alertController, animated: true)
    }

    private func showAlert(for error: Error) {
        let localizedError = error as? LocalizedError
        let alertController = UIAlertController(
            title: localizedError?.errorDescription ?? "Error",
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}

// MARK: - TextFieldTableViewCellDelegate

extension UpdateCredentialsViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        form.fields[indexPath.section].text = text
        navigationItem.rightBarButtonItem?.isEnabled = form.areFieldsValid
    }

    func textFieldCellDidEndEditing(_ cell: TextFieldCell) {
        do {
            try form.validateFields()
        } catch {
            formError = error as? Form.ValidationError
        }
    }
}

// MARK: - SupplementalInformationViewControllerDelegate

extension UpdateCredentialsViewController: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        dismiss(animated: true)
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credentials) {
        dismiss(animated: true)

        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
}
