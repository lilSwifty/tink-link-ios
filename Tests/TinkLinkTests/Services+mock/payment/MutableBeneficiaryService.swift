import Foundation
@testable import TinkLink

class MutableBeneficiaryService: BeneficiaryService {
    private var beneficiaries: [Beneficiary]

    var addBeneficiaryResult: Result<Void, Error> = .success

    init(beneficiaries: [Beneficiary]) {
        self.beneficiaries = beneficiaries
    }

    @discardableResult
    func beneficiaries(completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        completion(.success(beneficiaries))
        return nil
    }

    @discardableResult
    func create(accountNumberKind: AccountNumberKind, accountNumber: String, name: String, ownerAccountID: Account.ID, credentialsID: Credentials.ID, appURI: URL, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(addBeneficiaryResult)
        return nil
    }
}
