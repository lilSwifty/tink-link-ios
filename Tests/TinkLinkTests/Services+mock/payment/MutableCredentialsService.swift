import Foundation
@testable import TinkCore

class MutableCredentialsService: CredentialsService {
    private var credentialsByID: [Credentials.ID: Credentials] = [:]

    var createCredentialsKind: Credentials.Kind = .password
    var credentialsStatusAfterUpdate: Credentials.Status = .authenticating
    var credentialsStatusAfterRefresh: Credentials.Status = .authenticating
    var credentialsStatusAfterThirdPartyCallback: Credentials.Status = .authenticating
    var credentialsStatusAfterManualAuthentication: Credentials.Status = .authenticating
    var credentialsStatusAfterSupplementalInformation: Credentials.Status = .updated

    init(credentialsList: [Credentials]) {
        self.credentialsByID = Dictionary(grouping: credentialsList, by: \.id).compactMapValues(\.first)
    }

    func modifyCredentials(id: Credentials.ID, status: Credentials.Status, supplementalInformationFields: [Provider.FieldSpecification] = [], thirdPartyAppAuthentication: Credentials.ThirdPartyAppAuthentication? = nil) {
        let credentials = credentialsByID[id]!

        let modifiedCredentials = Credentials(
            id: credentials.id,
            providerID: credentials.providerID,
            kind: credentials.kind,
            status: status,
            statusPayload: "",
            statusUpdated: Date(),
            updated: Date(),
            fields: credentials.fields,
            supplementalInformationFields: supplementalInformationFields,
            thirdPartyAppAuthentication: thirdPartyAppAuthentication,
            sessionExpiryDate: nil
        )

        credentialsByID[id] = modifiedCredentials
    }

    func credentialsList(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        completion(.success(Array(credentialsByID.values)))
        return nil
    }

    func credentials(id: Credentials.ID, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[id] {
            completion(.success(credentials))
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(id.value)")))
        }
        return nil
    }

    func create(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String: String], appURI: URL?, callbackURI: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        let credentials = Credentials(
            id: Credentials.ID(UUID().uuidString),
            providerID: providerID,
            kind: createCredentialsKind,
            status: .created,
            statusPayload: "",
            statusUpdated: Date(),
            updated: nil,
            fields: fields,
            supplementalInformationFields: [],
            thirdPartyAppAuthentication: nil,
            sessionExpiryDate: nil
        )
        credentialsByID[credentials.id] = credentials
        completion(.success(credentials))
        return nil
    }

    func delete(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if credentialsByID[id] != nil {
            credentialsByID[id] = nil
            completion(.success)
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(id.value)")))
        }
        return nil
    }

    func update(id: Credentials.ID, providerID: Provider.ID, appURI: URL?, callbackURI: URL?, fields: [String: String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[id] {
            let updatedCredentials = Credentials(
                id: credentials.id,
                providerID: credentials.providerID,
                kind: credentials.kind,
                status: credentialsStatusAfterUpdate,
                statusPayload: "",
                statusUpdated: Date(),
                updated: Date(),
                fields: fields,
                supplementalInformationFields: [],
                thirdPartyAppAuthentication: nil,
                sessionExpiryDate: nil
            )
            credentialsByID[id] = updatedCredentials
            completion(.success(updatedCredentials))
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(id.value)")))
        }
        return nil
    }

    func refresh(id: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        modifyCredentials(id: id, status: credentialsStatusAfterRefresh)
        return nil
    }

    func addSupplementalInformation(id: Credentials.ID, fields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[id] {
            let updatedCredentials = Credentials(
                id: credentials.id,
                providerID: credentials.providerID,
                kind: credentials.kind,
                status: credentialsStatusAfterSupplementalInformation,
                statusPayload: "",
                statusUpdated: Date(),
                updated: Date(),
                fields: credentials.fields,
                supplementalInformationFields: [],
                thirdPartyAppAuthentication: nil,
                sessionExpiryDate: nil
            )
            credentialsByID[id] = updatedCredentials
            completion(.success)
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(id.value)")))
        }
        return nil
    }

    func cancelSupplementalInformation(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[id] {
            let updatedCredentials = Credentials(
                id: credentials.id,
                providerID: credentials.providerID,
                kind: credentials.kind,
                status: .authenticationError,
                statusPayload: "",
                statusUpdated: Date(),
                updated: Date(),
                fields: credentials.fields,
                supplementalInformationFields: [],
                thirdPartyAppAuthentication: nil,
                sessionExpiryDate: nil
            )
            credentialsByID[id] = updatedCredentials
            completion(.success)
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(id.value)")))
        }
        return nil
    }

    func enable(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[id] {
            let updatedCredentials = Credentials(
                id: credentials.id,
                providerID: credentials.providerID,
                kind: credentials.kind,
                status: .updated,
                statusPayload: "",
                statusUpdated: Date(),
                updated: Date(),
                fields: credentials.fields,
                supplementalInformationFields: [],
                thirdPartyAppAuthentication: nil,
                sessionExpiryDate: nil
            )
            credentialsByID[id] = updatedCredentials
            completion(.success)
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(id.value)")))
        }
        return nil
    }

    func disable(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[id] {
            let updatedCredentials = Credentials(
                id: credentials.id,
                providerID: credentials.providerID,
                kind: credentials.kind,
                status: .disabled,
                statusPayload: "",
                statusUpdated: Date(),
                updated: Date(),
                fields: credentials.fields,
                supplementalInformationFields: [],
                thirdPartyAppAuthentication: nil,
                sessionExpiryDate: nil
            )
            credentialsByID[id] = updatedCredentials
            completion(.success)
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(id.value)")))
        }
        return nil
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        for id in credentialsByID.keys {
            modifyCredentials(id: id, status: credentialsStatusAfterThirdPartyCallback)
        }
        return nil
    }

    func authenticate(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        modifyCredentials(id: id, status: credentialsStatusAfterManualAuthentication)
        return nil
    }

    func qrCode(id: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }
}
